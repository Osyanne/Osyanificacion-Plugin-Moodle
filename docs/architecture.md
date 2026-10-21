# Arquitectura — Wrappeo de Level Up XP

> **Entregable del Sprint 2** (verificación). Documenta cómo funciona el plugin
> base Level Up XP por dentro, qué capacidades ya trae nativas, y la decisión
> de wrappeo por cada feature del proyecto. Alimenta los Sprints 3-4.
>
> **Verificado en vivo** el 2026-05-31 sobre el Moodle local (Moodle 4.3 +
> Level Up XP v20.0), curso `PROG1-DEMO` (courseid=2), seedeado con 30
> estudiantes (`verif01`..`verif30`, XP de 2450 a 60).
>
> **Pareja con**: [`level-up-xp-deep-dive.md`](level-up-xp-deep-dive.md) (esquema
> BD del upstream) y [`plan-fase-1.md`](plan-fase-1.md) (roadmap — ver nota de
> reconciliación al final).
>
> ⚠️ **Corrección (2026-10-20)**: la versión inicial de este documento asumía dos
> puntos de extensión que **no existen** (verificado en el código instalado de
> Moodle 4.3.8 y Level Up XP 20.0): un plugin `local_` no puede sobrescribir
> plantillas de otro plugin, y el contenedor DI de `block_xp` no acepta clases
> externas. Ver [Puntos de extensión reales](#puntos-de-extensión-reales-verificados-en-el-código-instalado).
> Los veredictos de verificación (±5 nativo, nickname y recompensas por construir)
> no cambian; cambia **cómo** se construye el nickname.

## 📋 Tabla de contenidos

- [Cómo funciona Level Up XP por dentro](#cómo-funciona-level-up-xp-por-dentro)
- [Resultados de verificación](#resultados-de-verificación)
- [Decisión de arquitectura](#decisión-de-arquitectura)
- [Matriz de decisión](#matriz-de-decisión)
- [Nota de reconciliación con plan-fase-1](#nota-de-reconciliación-con-plan-fase-1)

---

## Cómo funciona Level Up XP por dentro

### Data flow (de la acción del alumno al ranking en pantalla)

```
   [Alumno hace una actividad en Moodle]
                  │
                  ▼
   Moodle dispara un EVENTO de core
   (ej. course_module_completed)
                  │
                  ▼
   block_xp lo escucha vía db/events.php
   (observer_rules_maker, patrón DI dinámico)
                  │
                  ▼
   Suma XP → tabla mdl_block_xp (1 fila por curso×usuario)
                  │
   Si el XP cruza un umbral de nivel:
   block_xp dispara su PROPIO evento → \block_xp\event\user_leveledup
   (carga: relateduserid, courseid, other['level'])
                  │
                  ▼
   Para mostrar el ranking, block_xp arma un "leaderboard"
   componiendo decoradores (patrón decorator):
     course_user_leaderboard   (base: todos los usuarios del curso)
       └─ neighboured_leaderboard   (recorta a ±N vecinos si neighbours>0)
            └─ anonymised_leaderboard  (oculta nombres si identitymode=0)
                  │
                  ▼
   renderer.php + templates/xp-widget.mustache
   → HTML del bloque que ve el alumno
```

### Las 3 piezas que nos importan

| Pieza del upstream | Qué hace | La usamos en |
|--------------------|----------|--------------|
| `mdl_block_xp_config.neighbours` | Recorta el ranking a ±N vecinos | Feature 1 (±5) |
| `classes/local/leaderboard/anonymised_leaderboard.php` | Reemplaza nombres por un texto genérico | Feature 2 (nickname) |
| `classes/event/user_leveledup.php` | Evento que se dispara al subir de nivel | Feature 3 (recompensas) |

### Puntos de extensión reales (verificados en el código instalado)

Level Up XP usa un contenedor de dependencias (`classes/di.php`) y el **patrón
decorator** en el leaderboard, pero ese contenedor **no es un punto de extensión
para plugins de terceros**:

- `di::make_container()` elige entre `\block_xp\local\default_container` y el
  contenedor del addon de pago (`\local_xp\local\container`); no hay forma de
  registrar una clase propia.
- `di::set_container()` lanza `coding_exception` fuera de PHPUnit/Behat.

Tampoco un plugin `local_` puede sobrescribir plantillas de otro componente:
`lib/classes/output/mustache_template_finder.php` (Moodle 4.3) busca la plantilla
solo en `theme/<tema>/templates/<componente>/`, en los temas padre y en la carpeta
del propio componente.

Lo que **sí** permite extender sin tocar el código de `block_xp`:

1. **Tema hijo de Boost** (`theme_osyanificacion`, por crear) — SCSS con la paleta
   UTA y override de plantillas en `theme/osyanificacion/templates/block_xp/`
   (cambios de estructura visual). Los temas también pueden sustituir renderers de
   plugins; si sirve para `block_xp` está por verificar.
2. **Observers de eventos** en `local_osyanificacion/db/events.php` — por ejemplo,
   `\block_xp\event\user_leveledup` para las recompensas.
3. **Componentes propios que leen los datos de `block_xp`** (tablas `block_xp`,
   `block_xp_config`) — por ejemplo, un bloque propio `block_osyanificacion`.
4. **Callback `xp_points_increased`** — `default_state_store_observer.php` llama a
   `get_plugin_list_with_function('block', 'xp_points_increased')`; solo aplica a
   plugins de tipo `block`.

El **wrappeo** (extender sin forkear) sigue siendo viable, pero a través de estos
cuatro mecanismos, no del contenedor DI.

---

## Resultados de verificación

### Feature 1 — Leaderboard relativo ±5 → ✅ NATIVO

**Hipótesis**: el campo `neighbours` de `mdl_block_xp_config` ya implementa el ±5.

**Qué se probó**:

```sql
-- Estado inicial: ranking completo
SELECT neighbours FROM mdl_block_xp_config WHERE courseid=2;  -- → 0

-- Activar ±5
UPDATE mdl_block_xp_config SET neighbours=5 WHERE courseid=2;
```

**Evidencia** (`presentation/screenshots-referencia/sprint2-verificacion/`):

- `02-neighbours5-verif15-medio.png` — logueado como `verif15` (puesto 15 de 30),
  el ranking muestra **exactamente 11 filas: puestos 10 a 20**, con la fila de
  `verif15` resaltada. Es el ±5 perfecto (5 arriba + tú + 5 abajo).
- `01-admin-top5.png` — como admin (sin XP en el curso), muestra solo el top 5
  (el modo relativo no tiene "centro" si el espectador no está rankeado).
- `03-neighbours5-verif04.png` — como `verif04` (puesto 4), muestra del 1 al 9
  (se trunca arriba porque no hay 5 por encima).

**Veredicto**: **NATIVO ALCANZA**. El comportamiento matchea el mockup UTA
(`presentation/mockups/leaderboard-mockup.html`): 11 filas, destaca al usuario
actual, muestra posición/nombre/XP (y de yapa, nivel y barra de progreso). El
highlight nativo es amarillo; el dorado UTA se logra con la plantilla propuesta
(`presentation/mockups/templates/`) aplicada mediante un tema hijo de Boost.
**Esfuerzo de construcción: 0** en lógica; solo presentación.

### Feature 2 — Anonimato (nickname elegido por el alumno) → ⚙️ CONSTRUIR

**Hipótesis**: el campo `identitymode` podría cubrir el anonimato con alias.

**Qué se probó** (código del upstream + visual):

`identitymode` solo tiene **2 valores** (`classes/local/config/course_world_config.php`):

- `IDENTITY_ON = 1` → muestra el nombre real.
- `IDENTITY_OFF = 0` → oculta el nombre, lo reemplaza por el string `someoneelse`
  ("Otra persona" en español).

```sql
UPDATE mdl_block_xp_config SET identitymode=0 WHERE courseid=2;
```

**Evidencia**: `04-identitymode0-anonimo.png` — todos los participantes aparecen
como **"Otra persona"** (texto genérico idéntico para todos, indistinguibles).

**Veredicto**: **NATIVO NO ALCANZA**. El requisito del proyecto es *nickname
elegido por el alumno* (alias propio). Lo nativo solo ofrece todo-o-nada: nombre
real, o anónimo genérico. **Hay que construirlo.**

El nombre se reemplaza en `anonymise_rank(rank $rank)` de
`classes/local/leaderboard/anonymised_leaderboard.php`, pero **no se puede inyectar
una subclase** (ver [Puntos de extensión reales](#puntos-de-extensión-reales-verificados-en-el-código-instalado)).
Alternativas a evaluar en un **spike al inicio del Sprint 3**:

- **A. Tema hijo de Boost**: sustituir el renderer o la plantilla del ranking para
  mostrar el alias. Riesgo: la plantilla `xp-widget` recibe nombres ya resueltos
  (`name`, `picurl`), sin `userid`, así que el alias tendría que resolverse en un
  renderer del tema.
- **B. Bloque propio** (`block_osyanificacion`): construye el ranking relativo
  leyendo los datos de `block_xp` y aplicando el alias; replica la lógica de vecinos
  ±N en lugar de reutilizar el decorator.

Común a ambas:

- Tabla propia: `local_osyanificacion_nickname (userid, courseid, alias)`.
- UI: form mínimo para que el alumno setee su alias.

**Criterio de salida del spike**: el ranking ±5 de `PROG1-DEMO` muestra alias de
prueba sin modificar `block_xp`. **Esfuerzo**: se re-estima tras el spike (la
estimación inicial S-M asumía la vía DI).

### Feature 3 — Recompensas escalonadas → ⚙️ CONSTRUIR (100% nuestro)

**Hipótesis**: no existe nativo un sistema de recompensas reales por umbral.

**Qué se probó** (code-reading del upstream):

- `classes/local/badge/` contiene solo `badge_manager.php` → **iconos visuales de
  nivel**, no recompensas canjeables con estado.
- No hay ninguna tabla ni clase de "rewards / prizes / redeem" con estados
  pending/claimed/redeemed.

**Veredicto**: **NO existe nativo → 100% construcción nuestra**. Pero el enganche
es limpio: el upstream **ya dispara el evento `\block_xp\event\user_leveledup`**
(`classes/event/user_leveledup.php`) con `relateduserid`, `courseid` y
`other['level']`. Diseño tentativo para Sprint 4:

- `local_osyanificacion_rewards (id, level[1/2/3], name, description, xp_threshold, image_url)`
- `local_osyanificacion_user_rewards (id, userid, courseid, reward_id, claimed_at, status[pending/claimed/redeemed])`
- Observer en `db/events.php` que escucha `user_leveledup` → compara XP vs
  thresholds → inserta en `_user_rewards`.
- Página `local/osyanificacion/rewards.php` para ver/canjear.

**Esfuerzo estimado: M** (medio).

---

## Decisión de arquitectura

**Wrappeo confirmado** (no fork modificado): no se modifica el código de
`block_xp`, lo que minimiza el costo de mantenimiento ante updates upstream. La
extensión se hace con tema hijo, observers y componentes propios, no con el
contenedor DI. Punto de extensión por feature:

| Feature | Nivel de customización | Mecanismo concreto |
|---------|------------------------|--------------------|
| ±5 (visual UTA) | Tema hijo de Boost (plantilla + SCSS) | `theme/osyanificacion/templates/block_xp/xp-widget.mustache` (propuesta en `presentation/mockups/templates/`) |
| Nickname | Tema hijo (renderer) o bloque propio — se decide en el spike del Sprint 3 | tabla `local_osyanificacion_nickname` + alias en la presentación del ranking |
| Recompensas | Plugin propio + observer | tablas `_rewards`/`_user_rewards` + observer de `user_leveledup` |

---

## Matriz de decisión

| Feature | ¿Nativo? | Esfuerzo si construir | Punto de extensión | Sprint destino |
|---------|----------|----------------------|--------------------|----------------|
| Leaderboard ±5 | ✅ Sí (`neighbours=5`) | 0 (solo activar + plantilla UTA vía tema hijo) | config + tema hijo | 3 (mínimo) |
| Anonimato nickname | ❌ No (solo "Otra persona") | Por re-estimar tras el spike | tabla propia + tema hijo (renderer) o bloque propio | 3 |
| Recompensas escalonadas | ❌ No (solo badges visuales) | M | tablas + observer de `user_leveledup` | 4 |

---

## Nota de reconciliación con plan-fase-1

Esta verificación **ajusta el plan original** (`plan-fase-1.md`):

- **Sprint 2 ya NO es "fork + code reading"**: se confirmó wrappeo (no fork) y el
  code-reading se cumplió con este documento.
- **Sprint 3 ya NO implementa el ±5 "desde cero"**: es nativo. El Sprint 3 se reduce
  a (a) aplicar el template UTA al ±5 nativo, y (b) construir el nickname (la feature
  que sí requiere código, esfuerzo S-M).
- **Sprint 4 (recompensas) se mantiene**: es 100% construcción, pero ahora con el
  enganche identificado (evento `user_leveledup`).
- **Corrección 2026-10-20**: el Sprint 3 empieza con un spike para elegir cómo
  construir el nickname (tema hijo o bloque propio), porque la vía DI documentada
  originalmente no es viable. La plantilla UTA se aplica mediante un tema hijo de
  Boost, no desde `local_osyanificacion`.

Resultado neto: el proyecto **ahorra** el trabajo más grande que el plan asumía
(±5 desde cero) y redirige ese esfuerzo al nickname y las recompensas, que son los
diferenciadores reales que ningún plugin nativo cubre.
