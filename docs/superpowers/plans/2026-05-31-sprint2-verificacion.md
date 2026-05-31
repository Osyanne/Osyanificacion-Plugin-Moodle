# Sprint 2 — Verificación de capacidades nativas — Implementation Plan

> **For agentic workers:** Este NO es un plan TDD de código. Es un **runbook de
> verificación human-in-the-loop**. Cada tarea sigue el patrón: Claude da un
> comando exacto → **Imanol lo corre y pega el output** → Claude lo interpreta y
> registra el veredicto. Claude NO ejecuta los comandos Docker/SQL (corren en el
> PC de Imanol). Los pasos de code-reading del upstream SÍ los hace Claude. Steps
> usan checkbox (`- [ ]`) para tracking.

**Goal:** Determinar, con evidencia reproducible, si el leaderboard ±5, el
anonimato (nickname) y las recompensas escalonadas ya existen nativos en Level Up
XP, y cerrar en `docs/architecture.md` + matriz de decisión que alimenta Sprints 3-4.

**Architecture:** Sprint de verificación, cero código de plugin. Pipeline por
feature: seedear ~30 estudiantes → activar config nativa → observar → decidir.
Imanol ejecuta comandos, Claude guía e interpreta.

**Tech Stack:** Docker Compose (Moodle 4.3 + MariaDB 10.11 bitnamilegacy), SQL
sobre `bitnami_moodle` (prefijo `mdl_`), Level Up XP v20.0, Playwright (screenshots).

**Datos de entorno (verificados en repo):**
- Containers: `osyanificacion-moodle`, `osyanificacion-mariadb`.
- DB: `bitnami_moodle`, prefijo de tablas `mdl_`.
- Moodle en http://localhost:8080. Admin: `MOODLE_USERNAME`/`MOODLE_PASSWORD` del `.env`.
- ⚠️ INFRA-002: nunca correr `php` como root en el container. Usar `make exec CMD='...'`
  (corre como `daemon`). SQL no necesita `-u daemon`.
- Curso DEMO: `PROG1-DEMO` (su `courseid` se descubre en Task 1, NO asumir que es 2).

---

## Task 0: Preparar entorno y rama de trabajo

**Files:**
- Branch ya creada: `docs/sprint2-architecture` (contiene el spec).

- [ ] **Step 1: Confirmar rama**

Claude verifica que estamos en la rama correcta.
Run: `git -C "C:\Users\osyanne\Documents\Claude\Projects\Osyanificacion-Plugin-Moodle" branch --show-current`
Expected: `docs/sprint2-architecture`

- [ ] **Step 2: Imanol levanta el stack Docker**

Imanol corre y pega output:
```bash
make up
docker compose ps
```
Expected: 3 servicios `Up` — `osyanificacion-moodle`, `osyanificacion-mariadb` (healthy),
`osyanificacion-mailhog`. Si Moodle recién arranca, esperar ~3-5 min al primer bootstrap.

- [ ] **Step 3: Si el stack no levanta — rama alternativa**

Si `docker compose ps` no muestra los 3 `Up`, o `curl -sI http://localhost:8080`
no da `200`: registrar el problema y **saltar a las partes code-reading** (Task 4 y
Task 6 no necesitan Docker). Las verificaciones visuales (Task 2, 3, 5) quedan
"pendiente de validación visual" en la matriz. Continuar, no bloquear.

---

## Task 1: Descubrir courseid del curso DEMO y estado inicial

**Files:** ninguno (solo lectura de BD).

- [ ] **Step 1: Imanol corre — descubrir courseid de PROG1-DEMO**

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT id, shortname, fullname FROM mdl_course WHERE shortname=\"PROG1-DEMO\";"'
```
Expected: una fila con el `id` del curso. **Ese id es el `<COURSEID>` para todo el resto.**
Si devuelve vacío: el curso no fue seedeado — ver Task 1 Step 3.

- [ ] **Step 2: Imanol corre — ver estado del bloque XP en ese curso**

Reemplazar `<COURSEID>` por el id del Step 1:
```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT courseid, enabled, enableladder, neighbours, identitymode, rankmode \
       FROM mdl_block_xp_config WHERE courseid=<COURSEID>\G"'
```
Expected: una fila con los valores actuales. Claude registra `neighbours` e
`identitymode` iniciales (probablemente `neighbours=0`, ranking completo).
Si no hay fila: el bloque XP nunca se configuró en ese curso — Imanol agrega el
bloque "Sube de nivel XP" dentro del curso vía UI primero, luego repite.

- [ ] **Step 3: Imanol corre — contar estudiantes con XP en el curso**

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT count(*) AS estudiantes_con_xp FROM mdl_block_xp WHERE courseid=<COURSEID>;"'
```
Expected: probablemente 0-5. Si <30, hace falta el seed masivo (Task 2). Claude
registra el número.

- [ ] **Step 4: Claude registra el estado inicial**

Claude anota en notas de trabajo: courseid, neighbours inicial, identitymode
inicial, nº estudiantes con XP. Sin esto, los pasos siguientes no tienen baseline.

---

## Task 2: Seed de ~30 estudiantes con XP variado

**Files:**
- Create: `seeds/sprint2-seed-xp.sql` (script idempotente de seed para verificación)

- [ ] **Step 1: Claude escribe el script de seed**

Claude crea `seeds/sprint2-seed-xp.sql`. El script: (a) crea 30 usuarios
`verif01..verif30` si no existen, (b) los matricula como estudiantes en el curso,
(c) inserta filas en `mdl_block_xp` con XP variado y sin empates artificiales (para
ver el ±5 limpio), idempotente vía `INSERT ... ON DUPLICATE KEY UPDATE`.

> NOTA: el script real se escribe en este paso durante la ejecución, porque
> depende del `<COURSEID>` (Task 1) y del id de rol "student" del entorno. Claude
> lo genera parametrizado y se lo pasa a Imanol con los valores ya sustituidos.
> El enfoque exacto (SQL directo vs `admin/cli` de Moodle) se decide en el Step 2
> según si insertar matrículas por SQL es seguro en este Moodle (ver decisión abajo).

- [ ] **Step 2: Decidir vía-SQL vs vía-CLI para matrículas**

Claude lee si el seed de matrículas por SQL directo es seguro o si conviene el
enrol API. Insertar XP en `mdl_block_xp` por SQL ES seguro (tabla simple, sin
side-effects). Matricular usuarios por SQL directo NO es ideal (Moodle usa
`enrol` + `user_enrolments` + `role_assignments`). **Decisión:** XP por SQL
directo; usuarios+matrícula por el CLI de Moodle si existe, o por SQL en las 3
tablas si no. Claude documenta cuál usó.

- [ ] **Step 3: Imanol corre el seed**

```bash
docker cp seeds/sprint2-seed-xp.sql osyanificacion-mariadb:/tmp/seed.sql
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle < /tmp/seed.sql'
```
Expected: sin errores. Si hay error de FK o de rol, pegar el mensaje completo —
Claude ajusta el script y se repite (es idempotente).

- [ ] **Step 4: Imanol verifica el seed — listado ordenado**

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT u.username, x.xp FROM mdl_block_xp x \
       JOIN mdl_user u ON u.id=x.userid \
       WHERE x.courseid=<COURSEID> ORDER BY x.xp DESC LIMIT 40;"'
```
Expected: ~30+ filas, XP descendente, variado. Claude registra el listado como
evidencia (va al architecture.md).

- [ ] **Step 5: Imanol purga caches (para que el bloque refleje el seed)**

```bash
make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php'
```
Expected: "Purging all caches..." sin error. (Usa `make exec` = daemon, evita INFRA-002.)

- [ ] **Step 6: Commit del script de seed**

```bash
git add seeds/sprint2-seed-xp.sql
git commit -m "chore(seeds): script SQL de seed para verificación Sprint 2 (30 estudiantes XP variado)"
```

---

## Task 3: Verificar Feature 1 — Leaderboard ±5 (`neighbours`)

**Files:**
- Evidence: `presentation/screenshots-referencia/sprint2-verificacion/01-neighbours-completo.png`,
  `02-neighbours-5.png`

- [ ] **Step 1: Imanol captura el ranking ANTES (neighbours=0, completo)**

Imanol, logueado como `verif15` (un estudiante del medio), entra al curso y abre
el bloque XP / la página del ladder. Saca screenshot →
`01-neighbours-completo.png`. Expected: ranking completo (~30 filas).

- [ ] **Step 2: Imanol activa neighbours=5**

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "UPDATE mdl_block_xp_config SET neighbours=5 WHERE courseid=<COURSEID>;"'
make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php'
```
Expected: `Query OK, 1 row affected`.

- [ ] **Step 3: Imanol captura el ranking DESPUÉS (neighbours=5)**

Refrescar el bloque (Ctrl+Shift+R) como `verif15`. Screenshot → `02-neighbours-5.png`.
Expected: el ranking pasa a mostrar ~11 filas (±5 alrededor de verif15).

- [ ] **Step 4: Claude compara contra el mockup UTA y decide**

Claude mira ambos screenshots y los compara con el mockup
`presentation/mockups/leaderboard-mockup.html` (en main). Preguntas a responder:
¿muestra 11 filas? ¿destaca al usuario actual? ¿el orden es correcto? ¿cómo maneja
empates de XP? Veredicto: **NATIVO ALCANZA** (→ solo template, ya hecho) o **NO
ALCANZA** (→ documentar en qué difiere, requisitos para query custom Sprint 3).
Claude escribe el veredicto + razón.

- [ ] **Step 5: Commit de evidencia Feature 1**

```bash
git add presentation/screenshots-referencia/sprint2-verificacion/01-neighbours-completo.png \
        presentation/screenshots-referencia/sprint2-verificacion/02-neighbours-5.png
git commit -m "docs(sprint2): evidencia Feature 1 (neighbours ±5) — antes/después"
```

---

## Task 4: Verificar Feature 2 — Anonimato (`identitymode`) [code-reading + visual]

**Files:**
- Evidence: `presentation/screenshots-referencia/sprint2-verificacion/03-identitymode-*.png`

- [ ] **Step 1: Claude lee el upstream para enumerar los modos de `identitymode`**

Claude inspecciona el plugin instalado (sin Docker write):
```bash
docker compose exec moodle sh -c \
  'grep -rn "identitymode\|IDENTITY_" /bitnami/moodle/blocks/xp/classes/ | head -40'
```
(Imanol corre este grep read-only y pega output; o Claude lee el upstream en
GitHub: `FMCorz/moodle-block_xp`.) Objetivo: listar las constantes reales (p.ej.
`IDENTITY_ON` = nombre real, `IDENTITY_OFF` = anónimo, `IDENTITY_ANONYMOUS`...) y
si alguna soporta alias/nickname elegido por el alumno.

- [ ] **Step 2: Claude registra los modos encontrados**

Claude documenta cada valor numérico de `identitymode` y qué muestra. Esto es la
base para decidir si el "nickname elegido" es nativo.

- [ ] **Step 3: Imanol prueba cada modo (visual)**

Para cada valor M encontrado (ej. 0,1,2):
```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "UPDATE mdl_block_xp_config SET identitymode=M WHERE courseid=<COURSEID>;"'
make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php'
```
Refrescar como `verif15`, screenshot → `03-identitymode-M.png`. Expected: el
ranking cambia cómo muestra los nombres.

- [ ] **Step 4: Claude decide contra el requisito "nickname elegido por el alumno"**

¿Algún modo nativo permite que el ESTUDIANTE elija su alias (no solo "anónimo" o
"iniciales")? Veredicto: **NATIVO ALCANZA** (configurar y listo) o **NO ALCANZA**
→ ir a Step 5 (dimensionar construcción).

- [ ] **Step 5 (condicional): Claude dimensiona el nickname custom**

Solo si Step 4 = NO ALCANZA. Claude lee `classes/local/leaderboard/` del upstream
e identifica el punto de extensión (DI container que arma las filas del ladder, o
el template) donde se inyectaría un alias guardado en una tabla propia
`local_osyanificacion_nickname (userid, courseid, alias)`. Output: mini-boceto
(qué clase se sobrescribe vía DI, qué tabla, qué UI mínima) + estimación de esfuerzo
(S/M/L). NO se construye nada — solo se dimensiona.

- [ ] **Step 6: Restaurar identitymode al default y commit evidencia**

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "UPDATE mdl_block_xp_config SET identitymode=<INICIAL> WHERE courseid=<COURSEID>;"'
git add presentation/screenshots-referencia/sprint2-verificacion/03-identitymode-*.png
git commit -m "docs(sprint2): evidencia Feature 2 (identitymode) — modos nativos"
```
(`<INICIAL>` = valor registrado en Task 1 Step 2.)

---

## Task 5: Verificar Feature 3 — Recompensas escalonadas [code-reading]

**Files:** ninguno (solo lectura del upstream).

- [ ] **Step 1: Claude confirma ausencia de "rewards por threshold" nativo**

Imanol corre el grep read-only y pega output:
```bash
docker compose exec moodle sh -c \
  'grep -rniE "reward|prize|redeem|threshold" /bitnami/moodle/blocks/xp/classes/ | head -40'
docker compose exec moodle sh -c \
  'ls /bitnami/moodle/blocks/xp/classes/local/badge/ 2>/dev/null'
```
Objetivo: confirmar que el upstream solo tiene badges/niveles, NO un sistema de
recompensas escalonadas reales (certificado/mención/carta) con estado
pending/claimed/redeemed. Claude interpreta.

- [ ] **Step 2: Claude bosqueja las 2 tablas y el enganche**

Claude documenta (sin crear nada) el diseño tentativo para Sprint 4:
- `local_osyanificacion_rewards (id, level[1/2/3], name, description, xp_threshold, image_url)`
- `local_osyanificacion_user_rewards (id, userid, courseid, reward_id, claimed_at, status[pending/claimed/redeemed])`
- Enganche: el upstream dispara un evento al subir de nivel / acumular XP →
  `local_osyanificacion` lo observa (`db/events.php`) → compara XP vs thresholds →
  inserta en `_user_rewards`. Claude verifica qué evento expone el upstream
  (grep `\\core\\event` / `xp_acquired` en `db/events.php` del plugin).

- [ ] **Step 3: Claude registra veredicto + esfuerzo**

Veredicto esperado: **NO existe nativo → 100% construcción nuestra**. Esfuerzo
estimado (S/M/L) para Sprint 4. Si por sorpresa SÍ hay algo nativo reutilizable,
documentarlo.

---

## Task 6: Escribir `docs/architecture.md` (entregable principal)

**Files:**
- Create: `docs/architecture.md`

- [ ] **Step 1: Claude escribe la sección "Cómo funciona Level Up XP por dentro"**

Data flow en prosa + diagrama ASCII simple: XP otorgados (event listeners en
`db/events.php` → `observer`) → guardados (`mdl_block_xp`) → ranking calculado
(`classes/local/leaderboard/`) → renderizado (`renderer.php` → `templates/
xp-widget.mustache`). Basado en `level-up-xp-deep-dive.md` + lo hallado en Tasks 4-5.

- [ ] **Step 2: Claude escribe la sección "Resultados de verificación"**

Una subsección por feature (1 ±5, 2 anonimato, 3 recompensas). Cada una: hipótesis,
qué se probó, evidencia (bloque SQL + ref al screenshot), veredicto. Pega los
outputs SQL reales registrados en Tasks 3-5.

- [ ] **Step 3: Claude escribe la sección "Decisión de arquitectura"**

Wrappeo confirmado + los 3 puntos de extensión (CSS override / template override /
DI container) y cuál usa cada feature según los veredictos.

- [ ] **Step 4: Claude escribe la matriz de decisión**

Tabla completa, cada fila con sprint destino:
```
| Feature | ¿Nativo? | Esfuerzo si construir | Punto de extensión | Sprint |
```
con los veredictos reales de Tasks 3-5 (sin `(a llenar)`).

- [ ] **Step 5: Claude escribe la nota de reconciliación con plan-fase-1.md**

Párrafo explícito: qué de los Sprints 2-3 del plan original queda ajustado por
estos hallazgos (ej. "Sprint 3 ya no implementa ±5 desde cero porque es nativo").

- [ ] **Step 6: Verificar markdown-lint (CI gate)**

Run: `awk 'length>200 {print NR": "length}' docs/architecture.md`
Expected: sin output (ninguna línea >200, salvo tablas/code que el config excluye).
Si hay líneas largas de prosa, Claude las parte.

- [ ] **Step 7: Commit del architecture.md**

```bash
git add docs/architecture.md
git commit -m "docs(sprint2): architecture.md — data flow Level Up XP + verificación nativa + matriz de decisión"
```

---

## Task 7: Reconciliar referencias y cerrar el sprint

**Files:**
- Modify: `docs/level-up-xp-deep-dive.md` (referencia `architecture.md` ya no es TBD)
- Modify: `docs/plan-fase-1.md` (nota de reconciliación mínima)

- [ ] **Step 1: Claude actualiza la referencia TBD en deep-dive**

En `docs/level-up-xp-deep-dive.md` la línea `docs/architecture.md — TBD Sprint 2`
pasa a apuntar al doc ya creado. Edit puntual.

- [ ] **Step 2: Claude agrega nota de reconciliación en plan-fase-1.md**

Una nota breve al inicio de la sección Sprint 2/3 del `plan-fase-1.md`: "Ver
`docs/architecture.md` — la verificación del Sprint 2 ajustó este plan (±5 y
posiblemente anonimato son nativos)." NO reescribir el plan, solo el puntero.

- [ ] **Step 3: Commit de reconciliación**

```bash
git add docs/level-up-xp-deep-dive.md docs/plan-fase-1.md
git commit -m "docs(sprint2): reconciliar referencias a architecture.md en plan y deep-dive"
```

- [ ] **Step 4: Imanol restaura neighbours al estado deseado para demos**

Decisión: dejar `neighbours=5` (es el comportamiento del proyecto) o volver a 0.
Claude recomienda dejar `=5` si el veredicto fue "nativo alcanza". Imanol corre el
UPDATE final si aplica.

- [ ] **Step 5: Push y PR**

```bash
git push origin docs/sprint2-architecture
gh pr create -R Osyanne/Osyanificacion-Plugin-Moodle --base main \
  --title "docs(sprint2): verificación de capacidades nativas + architecture.md" \
  --body "Cierra Sprint 2 (verificación). Ver docs/architecture.md + matriz de decisión."
```
Expected: PR creado. CI corre los 5 checks. Merge tras review (CODEOWNER) o admin
override si Imanol trabaja solo.

---

## Definition of Done (criterios de salida del spec)

- [ ] Las 3 features tienen veredicto en la matriz con evidencia — o "no verificable" con razón.
- [ ] `docs/architecture.md` existe, explica el data flow, pasa markdown-lint.
- [ ] La matriz está completa, cada fila apunta a Sprint 3 o 4.
- [ ] Hay nota de reconciliación con `plan-fase-1.md`.
- [ ] Evidencia (screenshots + SQL) en el repo.
- [ ] PR mergeado a `main`.
