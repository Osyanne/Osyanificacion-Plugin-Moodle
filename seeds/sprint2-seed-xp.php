<?php
// =====================================================================
// seeds/sprint2-seed-xp.php
// =====================================================================
// Seed de verificación para Sprint 2: crea 30 estudiantes, los matricula
// en el curso PROG1-DEMO y les asigna XP variado para poder verificar el
// leaderboard relativo ±5 (campo `neighbours` de Level Up XP).
//
// Usa las APIs OFICIALES de Moodle (no SQL directo) para que usuarios y
// matrículas queden consistentes. El XP se setea con la API del propio
// plugin block_xp si está disponible; si no, cae a un INSERT seguro en
// la tabla {block_xp} (tabla simple, sin side-effects).
//
// IDEMPOTENTE: re-ejecutarlo no duplica usuarios ni matrículas; actualiza
// el XP a los valores definidos abajo.
//
// USO (desde el host, como daemon para no romper permisos — INFRA-002):
//   docker cp seeds/sprint2-seed-xp.php osyanificacion-moodle:/tmp/seed.php
//   docker compose exec -u daemon moodle sh -c 'php /tmp/seed.php'
//
// Parámetros fijos de este entorno (verificados 2026-05-31):
//   - Curso destino: shortname PROG1-DEMO (courseid=2)
//   - 30 estudiantes: verif01..verif30
// =====================================================================

define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');
require_once($CFG->dirroot . '/user/lib.php');
require_once($CFG->dirroot . '/lib/enrollib.php');
require_once($CFG->dirroot . '/lib/moodlelib.php');

global $DB, $CFG;

$COURSE_SHORTNAME = 'PROG1-DEMO';
$NUM_STUDENTS     = 30;

// --- XP variado, sin empates, distribución realista (descendente) ---
// 30 valores espaciados de forma irregular para que el ±5 se vea claro.
$xp_values = [
    2450, 2280, 2105, 1990, 1875, 1740, 1620, 1510, 1395, 1280,
    1175, 1080,  995,  910,  840,  765,  690,  625,  560,  500,
     445,  390,  340,  295,  250,  210,  170,  135,  100,   60,
];

// ---------------------------------------------------------------------
// 1. Resolver el curso
// ---------------------------------------------------------------------
$course = $DB->get_record('course', ['shortname' => $COURSE_SHORTNAME]);
if (!$course) {
    fwrite(STDERR, "ERROR: no existe el curso con shortname '$COURSE_SHORTNAME'.\n");
    exit(1);
}
echo "Curso encontrado: id={$course->id} shortname={$course->shortname}\n";

// ---------------------------------------------------------------------
// 2. Resolver el método de matrícula manual del curso
// ---------------------------------------------------------------------
$enrol_plugin = enrol_get_plugin('manual');
$instances = enrol_get_instances($course->id, true);
$manual_instance = null;
foreach ($instances as $inst) {
    if ($inst->enrol === 'manual') {
        $manual_instance = $inst;
        break;
    }
}
if (!$manual_instance) {
    // Crear instancia de matrícula manual si el curso no la tiene.
    $instanceid = $enrol_plugin->add_instance($course);
    $manual_instance = $DB->get_record('enrol', ['id' => $instanceid]);
    echo "Creada instancia de matrícula manual (id={$manual_instance->id}).\n";
}

// Rol 'student' (archetype estándar de Moodle).
$studentrole = $DB->get_record('role', ['shortname' => 'student'], '*', MUST_EXIST);

// ---------------------------------------------------------------------
// 3. Crear/actualizar los 30 estudiantes + matricular + asignar XP
// ---------------------------------------------------------------------
$created = 0; $reused = 0; $xp_set = 0;

// ¿Está disponible la API del plugin block_xp para setear XP?
$use_block_xp_api = class_exists('\\block_xp\\di');

for ($i = 1; $i <= $NUM_STUDENTS; $i++) {
    $username = sprintf('verif%02d', $i);
    $xp = $xp_values[$i - 1];

    $user = $DB->get_record('user', ['username' => $username, 'mnethostid' => $CFG->mnet_localhost_id]);
    if (!$user) {
        $u = new stdClass();
        $u->auth         = 'manual';
        $u->confirmed    = 1;
        $u->mnethostid   = $CFG->mnet_localhost_id;
        $u->username     = $username;
        $u->password     = 'Verif.' . sprintf('%02d', $i) . '.demo';
        $u->firstname    = 'Verif';
        $u->lastname     = sprintf('Estudiante %02d', $i);
        $u->email        = $username . '@osyanificacion.local';
        $u->lang         = 'es';
        $u->city         = 'Ambato';
        $u->country      = 'EC';
        $u->id = user_create_user($u, true, false);
        $user = $DB->get_record('user', ['id' => $u->id]);
        $created++;
    } else {
        $reused++;
    }

    // Matricular como estudiante (idempotente: si ya está, no duplica).
    $enrol_plugin->enrol_user($manual_instance, $user->id, $studentrole->id);

    // Asignar XP.
    if ($use_block_xp_api) {
        // API oficial del plugin: respeta niveles, logs, etc.
        $world = \block_xp\di::get('course_world_factory')->get_world($course->id);
        $store = $world->get_store();
        $state = $store->get_state($user->id);
        $current = $state->get_xp();
        $delta = $xp - $current;
        if ($delta !== 0) {
            $store->set($user->id, $xp); // set absoluto
        }
        $xp_set++;
    } else {
        // Fallback: INSERT/UPDATE directo en {block_xp} (tabla simple).
        $existing = $DB->get_record('block_xp', ['courseid' => $course->id, 'userid' => $user->id]);
        if ($existing) {
            $existing->xp = $xp;
            $DB->update_record('block_xp', $existing);
        } else {
            $rec = new stdClass();
            $rec->courseid = $course->id;
            $rec->userid   = $user->id;
            $rec->xp       = $xp;
            $rec->lvl      = 1; // deprecated, el plugin recalcula
            $DB->insert_record('block_xp', $rec);
        }
        $xp_set++;
    }
}

echo "Estudiantes creados:   $created\n";
echo "Estudiantes reusados:  $reused\n";
echo "XP asignado a:         $xp_set estudiantes\n";
echo "Método XP:             " . ($use_block_xp_api ? 'API block_xp (oficial)' : 'INSERT directo (fallback)') . "\n";
echo "Listo. Purgá caches: docker compose exec -u daemon moodle sh -c 'php /bitnami/moodle/admin/cli/purge_caches.php'\n";
