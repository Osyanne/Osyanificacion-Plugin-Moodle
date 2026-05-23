# Level Up XP — Deep dive técnico

> **Cheatsheet operativo del plugin base** que vamos a wrappear en
> Sprint 2. Documenta estructura, esquema BD, hallazgos críticos y
> recomendaciones para Sprint 2 (wrappeo) y Sprint 3 (leaderboard ±5).
>
> **Pareja con**: [`docs/benchmarking-level-up-xp.md`](benchmarking-level-up-xp.md)
> (por qué wrappeamos) y [`docs/plan-fase-1.md`](plan-fase-1.md)
> (roadmap general).
>
> **Versión analizada**: Level Up XP v20.0 (`2026042001`), instalada en
> Moodle 4.3 local el 2026-05-23 por Álvaro.

## 📋 Tabla de contenidos

- [🔥 Hallazgos críticos](#-hallazgos-críticos)
- [Estructura del repositorio del plugin](#-estructura-del-repositorio-del-plugin)
- [Esquema de base de datos (6 tablas)](#-esquema-de-base-de-datos-6-tablas)
- [Carpeta `classes/` — lógica de negocio](#-carpeta-classes--lógica-de-negocio)
- [Templates Mustache disponibles](#-templates-mustache-disponibles)
- [Stack de build (no es solo PHP)](#-stack-de-build-no-es-solo-php)
- [Recomendaciones por Sprint](#-recomendaciones-por-sprint)
- [Referencias rápidas](#-referencias-rápidas)

---

## 🔥 Hallazgos críticos

### 1. Leaderboard relativo ±N YA existe nativo (no hace falta reimplementar)

**Evidencia**:

- Campo `neighbours` en `block_xp_config` (línea 17 de `db/install.xml`):

  ```xml
  <FIELD NAME="neighbours" TYPE="int" LENGTH="2" NOTNULL="true"
         DEFAULT="0" SEQUENCE="false"/>
  ```

- Strings en `lang/en/block_xp.php`:

  ```
  'displaynneighbours'   = 'Display {$a} neighbours'
  'displayoneneigbour'   = 'Display one neighbour'
  'displayrelativerank'  = 'Display a relative rank'
  ```

**Probado en vivo el 2026-05-23**:

```sql
-- Estado inicial (default tras instalar)
SELECT courseid, neighbours, rankmode FROM mdl_block_xp_config WHERE courseid = 2;
-- courseid=2, neighbours=0, rankmode=1  → muestra leaderboard COMPLETO

UPDATE mdl_block_xp_config SET neighbours = 5 WHERE courseid = 2;
-- Refrescar el bloque en el navegador → el ranking pasa a mostrar
-- solo los ±5 vecinos del usuario actual.
```

**Implicancia para Sprint 3**:

El plan original ([`docs/plan-fase-1.md`](plan-fase-1.md) líneas
210-218) propone implementar el leaderboard ±5 desde cero con un query
`RANK() OVER ... BETWEEN (my_pos - 5) AND (my_pos + 5)`. **Ese trabajo
puede saltarse o reducirse drásticamente** si el comportamiento nativo
satisface los requerimientos visuales/UX.

**Próximo paso recomendado** (Sprint 2, antes de empezar Sprint 3):

1. Probar `neighbours=5` con un curso seedeado de ~30 estudiantes y
   XP variado
2. Capturar screenshots del comportamiento
3. Comparar contra los mockups del proyecto
4. **Si matchea** → solo customizar el template Mustache (highlight "TÚ"
   en dorado, paleta UTA)
5. **Si NO matchea** → mantener el plan original de query custom, pero
   ahora sabemos que el escaffolding (campo BD, strings, UI básica)
   ya existe y podemos reutilizar todo

### 2. Stack de build moderno: Tailwind + TypeScript + Webpack

**Evidencia** (archivos en `blocks/xp/` root):

- `tailwind.config.js` — Tailwind CSS configurado
- `tsconfig.json` — TypeScript
- `webpack.common.js` + `webpack.dev.js` + `webpack.prod.js` + `webpack.lib.js` — Webpack
- `package.json` + `yarn.lock` — dependencies via yarn
- `postcss.config.js` — PostCSS para procesar CSS

**Implicancia para Edison (UI/UX en Sprint 1, 3, 4)**:

Si Edison va a customizar UI del plugin (templates Mustache o estilos),
**tiene que entender el pipeline de build** antes:

- Editar archivos `*.ts` o `*.css` requiere `yarn build` para generar
  el output que Moodle consume
- El plugin trae `amd/` con código compilado — no editar ahí directo
- Customizaciones cosméticas chicas (colores, espaciados) sí pueden
  hacerse vía CSS override en `code/local/osyanificacion/styles.css`

### 3. Código profesional: Dependency Injection + Strategy pattern

**Evidencia**:

- `classes/di.php` — clase de DI container
- `db/events.php` solo tiene 3 líneas operativas, usa
  `\block_xp\di::get('observer_rules_maker')`
- `classes/local/strategy/` — patrón Strategy para distintos algoritmos
  de cálculo

**Implicancia para Sprint 2 (decisión wrappeo vs fork)**:

El plugin está diseñado para ser extendido sin tocar core. Wrappear en
`local_osyanificacion` es la jugada correcta:

- Podés sobreescribir queries via container DI
- Las "strategies" son intercambiables (ej. el cálculo de niveles)
- Eventos del listener se registran en `observer_rules_maker` — extender
  sin recompilar

---

## 📁 Estructura del repositorio del plugin

```
blocks/xp/
├── AGENTS.md                 ← (sorpresa) prompts para LLMs (Claude/Copilot)
├── README.md
├── CHANGELOG.md
├── LICENSE (GPL v3 implícita en cada header)
│
├── version.php               ← metadata Moodle (version=2026042001, release=20.0)
├── block_xp.php              ← clase principal del bloque
├── lib.php                   ← funciones libres de Moodle
├── renderer.php              ← UI rendering (51 KB!)
├── settings.php              ← config del plugin a nivel site
├── edit_form.php             ← form de config por instancia del bloque
├── ajax.php                  ← endpoint AJAX
├── index.php                 ← entry point
├── styles.css                ← estilos compilados (40 KB)
│
├── db/                       ← esquema BD + eventos + accesos
├── classes/                  ← lógica PHP (10 subcarpetas)
├── templates/                ← Mustache UI (~25 templates)
├── lang/                     ← i18n (en, es, fr, ...)
├── tests/                    ← PHPUnit + Behat
├── cli/                      ← scripts CLI de Moodle
├── backup/                   ← integración con Moodle backup
├── pix/                      ← imágenes (iconos, badges)
├── amd/                      ← JS compilado (NO editar)
├── ui/                       ← código fuente UI (TS antes de compilar)
├── css/                      ← estilos fuente
├── yui/                      ← legacy YUI (deprecated)
│
├── composer.json
├── package.json + yarn.lock  ← deps Node/Yarn
├── webpack.*.js              ← build con Webpack
├── tailwind.config.js
├── tsconfig.json
└── postcss.config.js
```

---

## 🗄️ Esquema de base de datos (6 tablas)

### Las 6 tablas que crea `db/install.xml`

| Tabla | Filas esperadas | Función | Editar en Sprint 3? |
|---|---|---|---|
| `block_xp` | 1 por (curso × user) con XP | **XP acumulado por usuario en curso** | NO (lectura) |
| `block_xp_config` | 1 por curso | **Config del plugin por curso** (incluye `neighbours`) | ⚠️ Sí, activar `neighbours=5` |
| `block_xp_filters` | Variable | Filtros para reglas de asignación | NO |
| `block_xp_rule` | Variable | Reglas (cuántos XP da cada actividad) | Maybe (Sprint 4 recompensas) |
| `block_xp_log` (deprecated) | — | Log viejo de eventos (legacy, retrocompat) | NO |
| `block_xp_logs` | Variable | Log nuevo de puntos otorgados (auditoría) | NO |

### `block_xp` — la tabla del ranking

```sql
CREATE TABLE mdl_block_xp (
  id        INT(10) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  courseid  INT(10) NOT NULL,
  userid    INT(10) NOT NULL,
  xp        INT(20) NOT NULL,
  lvl       INT(10) DEFAULT 1,   -- DEPRECATED desde XP 3.15, leer con PHP
  UNIQUE KEY courseuser (courseid, userid)
);
```

**Notas clave**:

- Índice `UNIQUE (courseid, userid)` → garantiza 1 fila por (curso, user)
- Campo `lvl` está **deprecated**. Usar PHP del plugin para calcular nivel
  desde XP — los niveles son dinámicos por curso
- Para leaderboard: `SELECT * FROM mdl_block_xp WHERE courseid=? ORDER BY xp DESC`

### `block_xp_config` — config crítica del leaderboard

Campos relevantes (no exhaustivo, ver `install.xml` líneas 22-50):

| Campo | Tipo | Default | Para qué |
|---|---|---|---|
| `enabled` | tinyint | 0 | XP activado en el curso |
| `enableladder` | tinyint | 1 | Mostrar leaderboard al estudiante |
| **`neighbours`** | int(2) | **0** | **Cuántos vecinos mostrar (0=todos, 5=±5)** |
| `rankmode` | int(2) | 1 | Modo de cálculo del rank |
| `identitymode` | int(2) | 1 | Mostrar identidad real / anónimo / alias |
| `enablecheatguard` | tinyint | 1 | Limitar XP por acciones repetitivas |
| `maxactionspertime` | int | 10 | Máximo de XP awards por ventana |
| `timeformaxactions` | int | 60 | Ventana de tiempo (segs) |
| `timebetweensameactions` | int | 180 | Tiempo entre acciones idénticas (cheat guard) |
| `enablelevelupnotif` | tinyint | 1 | Notificar al usuario cuando sube de nivel |
| `levelsdata` | text | NULL | JSON con definición de niveles |

### Tip: ver config del curso desde MariaDB

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT * FROM mdl_block_xp_config WHERE courseid = 2\G"'
```

(El `\G` formatea vertical, más legible para tablas con muchas columnas.)

---

## 🧠 Carpeta `classes/` — lógica de negocio

### Subcarpetas de `classes/local/` (39 subcarpetas)

```
classes/local/
├── action/           ← acciones del usuario
├── activity/         ← integración con actividades Moodle
├── availability/     ← reglas de disponibilidad
├── backup/           ← integración backup Moodle
├── badge/            ← gestión de badges/insignias
├── block/            ← lógica del bloque
├── check/            ← health checks
├── compat/           ← capa de compatibilidad cross-version Moodle
├── config/           ← acceso a config
├── container.php
├── controller/       ← controladores HTTP
├── default_container.php
├── division/         ← divisiones (groupings)
├── factory/          ← factories
├── file/             ← upload/download
├── icon/             ← iconos
├── indicator/        ← métricas
├── iterator/         ← iterators
├── leaderboard/      ← ⭐ LÓGICA DEL LADDER (lo que extendemos Sprint 3)
├── logger/           ← logging
├── notification/     ← notificaciones
├── observer/         ← event observers
├── permission/       ← permisos
├── plugin/           ← metadata del plugin
├── privacy/          ← GDPR / privacy API
├── reason/           ← motivos por los que se otorgaron XP
├── routing/          ← rutas internas
├── rule/             ← reglas
├── rulefilter/       ← filtros de reglas
├── ruletype/         ← tipos de reglas
├── serializer/       ← serialización JSON / API
├── setting/          ← settings UI
├── shortcode/        ← shortcodes (filter Moodle)
├── sql/              ← queries SQL directas
├── strategy/         ← patrones strategy
├── task/             ← tareas cron Moodle
├── userfilter/       ← filtros de usuario para ladder
├── utils/            ← helpers varios
├── world.php
└── xp/               ← lógica core de XP
```

### Las 3 carpetas más relevantes para nosotros

| Carpeta | Por qué importa | Sprint |
|---|---|---|
| `leaderboard/` | Aquí vive la lógica del ranking. Acá vamos a wrappear/sobreescribir para customizar el ±5 si la config nativa no alcanza | 3 |
| `rule/` + `rulefilter/` + `ruletype/` | Reglas de cuántos XP da cada acción. Si queremos sumar puntos por recompensas custom de Osyanificación, extender acá | 4 |
| `xp/` | Cálculo core. Ver antes de tocar nada del leaderboard | 2-3 |

---

## 🎨 Templates Mustache disponibles

Hay ~25 templates en `templates/`. Los que probablemente toque Edison:

| Template | Para qué | Sprint |
|---|---|---|
| `xp-widget.mustache` | El bloque principal del XP en el curso | 1 (paleta UTA), 3 (highlight ±5) |
| `level-badge.mustache` | Estrella central con número del nivel | 1 (visual) |
| `progress-bar.mustache` | Barra de progreso al próximo nivel | 1 (visual) |
| `navbar-widget.mustache` | Widget XP en navbar top | Opcional |
| `recent-activity.mustache` | Lista de actividades recientes que dieron XP | 4 |
| `shortcode-xpladder-embed.mustache` | Ladder embebible en cualquier pagina | Sprint 6 (demo) |

**Templates que NO conviene tocar** (más complejos / internos):

- `table/*` (tablas internas de filtros)
- `modal-*` (modales internos del plugin)
- `rules-page-loading-*` (estados de carga)
- `addon-*` (relacionados con add-ons premium del plugin)

---

## 🏗️ Stack de build (no es solo PHP)

Level Up XP **no es un plugin Moodle clásico** de solo PHP + Mustache.
Usa un pipeline moderno:

```
Source:
├── ui/*.ts          ← TypeScript
├── css/*.css        ← CSS con Tailwind directives

Build (via Webpack):
└── amd/build/*.js   ← compilado, lo que Moodle consume
└── styles.css       ← CSS compilado con Tailwind

Herramientas:
- yarn               ← package manager (no npm)
- webpack            ← bundler
- tailwindcss        ← utility CSS
- typescript         ← typed JS
- postcss            ← procesamiento CSS
- eslint             ← lint JS/TS
```

### Para customizar UI desde nuestro wrapper

3 niveles de customización, de menor a mayor invasivo:

| Nivel | Cómo | Cuándo usar |
|---|---|---|
| **1. CSS override** | Agregar `styles.css` en `local_osyanificacion` con !important | Cambios cosméticos (paleta UTA) |
| **2. Template override** | Crear `templates/block_xp/<nombre>.mustache` en nuestro plugin que Moodle prioriza | Cambios estructurales de UI |
| **3. PHP override** | Sobrescribir clases via DI container del plugin | Lógica de negocio (queries, cálculos) |

---

## 🎯 Recomendaciones por Sprint

### Sprint 2 — Fork + code reading

**Decisión arquitectónica**: **Wrappeo confirmado** (en lugar de fork
modificado del upstream). El plugin está diseñado para extensión.

**Code reading priorizado** (4-6h totales):

1. `classes/di.php` y `classes/local/container.php` — entender el DI container (1h)
2. `classes/local/leaderboard/` — toda la carpeta (2h)
3. `db/install.xml` — esquema completo (30 min, ya cubierto en este doc)
4. `templates/xp-widget.mustache` + `renderer.php` (50 KB!) — relación template↔render (1h)
5. `lang/en/block_xp.php` grep de `ladder`, `rank`, `level` — strings que vamos a override (30 min)

### Sprint 3 — Leaderboard ±5

**Antes de escribir código**:

1. Crear seeds con 30+ estudiantes y XP variado (no solo los 5 actuales)
2. Activar `neighbours=5` en `block_xp_config` del curso de prueba
3. Validar visualmente si el comportamiento nativo basta

**Si basta** → trabajo de Sprint 3 reducido a:

- Customizar `templates/xp-widget.mustache` con paleta UTA + highlight "TÚ" en dorado
- Tests Behat: usuario logueado ve ±5
- Tests Behat: usuario sin XP ve placeholder amigable

**Si NO basta** → plan original del query custom, pero ahora:

- Sobreescribir el método del leaderboard via DI container (no monkey-patch)
- Mantener compatibilidad con el campo `neighbours` (si admin quiere desactivarlo, fallback al ranking absoluto)

### Sprint 4 — Recompensas escalonadas

Acoplar con el sistema de `rule/` + `rulefilter/` de Level Up XP en
lugar de crear sistema paralelo:

- Las recompensas escalonadas se otorgan **al cruzar un threshold de XP**
- Eso se puede modelar como una **rule** del propio Level Up XP que
  dispara un evento → nuestro `local_osyanificacion` lo captura y
  registra en `local_osyanificacion_user_rewards`

### Sprint 5 — Load testing

Para JMeter, escenarios prioritarios basados en el esquema:

- Login (`/login/index.php`)
- Cargar bloque XP en dashboard de un curso (`/course/view.php?id=X`)
- Cargar ladder completo (`/blocks/xp/index.php?courseid=X`)

El ladder con `neighbours=5` debería ser **más rápido** que el ladder
completo (menos rows en el response). Validar empíricamente.

---

## 📚 Referencias rápidas

### Comandos útiles (Docker shell)

```bash
# Ver código del plugin
docker compose exec moodle sh -c 'ls /bitnami/moodle/blocks/xp/'

# Ver tablas creadas
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SHOW TABLES LIKE '"'"'mdl_block_xp%'"'"';"'

# Ver XP de usuarios en un curso
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT u.username, x.xp FROM mdl_block_xp x \
       JOIN mdl_user u ON u.id=x.userid \
       WHERE x.courseid=2 ORDER BY x.xp DESC;"'

# Activar neighbours ±5 en un curso
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "UPDATE mdl_block_xp_config SET neighbours=5 WHERE courseid=2;"'
```

### Enlaces externos

- Repo upstream: https://github.com/FMCorz/moodle-block_xp
- Doc oficial: https://docs.levelup.plus/xp/docs
- Plugin en Moodle.org: https://moodle.org/plugins/block_xp
- Versión premium (XP+): https://levelup.plus/xp/

### Docs relacionados del proyecto

- [`docs/plan-fase-1.md`](plan-fase-1.md) — roadmap general
- [`docs/benchmarking-level-up-xp.md`](benchmarking-level-up-xp.md) — por qué wrappeamos
- [`docs/architecture.md`](architecture.md) — TBD Sprint 2

---

## ⚠️ Notas del autor

- Este doc fue armado por **Álvaro** el 2026-05-23 explorando el plugin
  instalado en el Moodle local. La estructura y esquema BD son hechos
  verificados. Las recomendaciones son **propuestas** que Imanol valida
  o revierte en Sprint 2.
- El hallazgo más importante es el **#1 (neighbours nativo)**. Si en
  Sprint 2 confirmamos que basta con activarlo, ajustar el plan de
  Sprint 3 en consecuencia (`docs/plan-fase-1.md` líneas 206-234).
- Cualquier desviación encontrada al hacer code reading o tests reales
  → actualizar este doc.
