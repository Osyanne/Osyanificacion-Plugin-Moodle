# Sprint 2 — Verificación de capacidades nativas de Level Up XP — Design

> **Tipo de sprint**: verificación y decisión documentada (NO implementación de código).
> **Fecha**: 2026-05-31
> **Director técnico**: Imanol (ejecuta los comandos; Claude Code guía paso a paso).
> **Estado**: aprobado, listo para plan de implementación.

## Contexto

El proyecto wrappea el plugin Level Up XP (`FMCorz/moodle-block_xp`) en un plugin
propio `local_osyanificacion` para añadir 3 diferenciadores: leaderboard relativo
±5, anonimato vía nickname elegido por el alumno, y recompensas escalonadas.

El deep-dive del upstream (`docs/level-up-xp-deep-dive.md`, Álvaro 2026-05-23)
descubrió que **parte de esos diferenciadores podrían ya existir nativos**:

- El leaderboard ±5 existe vía el campo `neighbours` en `block_xp_config`
  (probado en vivo: `UPDATE ... SET neighbours=5` cambia el ranking a ±5).
- Existe un campo `identitymode` que podría cubrir el anonimato (modos exactos
  desconocidos).
- Las recompensas escalonadas NO parecen existir nativas.

Esto invalida parcialmente el plan original (`docs/plan-fase-1.md`), que asumía
"fork de Level Up XP" en Sprint 2 y "leaderboard ±5 desde cero" en Sprint 3.
Antes de escribir una línea de código de plugin, hay que **verificar qué hace lo
nativo**, para no construir lo que ya existe.

## Objetivo

Producir conocimiento y decisiones, no código. Al cierre del sprint, cada una de
las 3 features tiene un veredicto respaldado por evidencia reproducible (comando
SQL + screenshot): se resuelve activando configuración nativa, o se construye (y
con qué esfuerzo, en qué sprint).

## No-goals (fuera de alcance explícito)

- Crear el plugin `local_osyanificacion` instalable (eso inicia el Sprint 3).
- Escribir tablas, templates nuevos o código PHP.
- Resolver el nickname si resulta no-nativo: solo se **dimensiona**, no se construye.
- Modificar `plan-fase-1.md` más allá de una nota de reconciliación.

## Restricción de rol

Imanol ejecuta los comandos; Claude los explica uno a uno (qué hace, qué output
se espera). El objetivo es que el conocimiento quede en el director, que tiene
que poder explicar el sistema al docente ("¿podría explicárselo al inge en mis
palabras?").

## Arquitectura del sprint

### Las 3 features bajo verificación

| # | Feature | Hipótesis previa | Qué probar |
|---|---------|------------------|------------|
| 1 | Leaderboard ±5 | Existe nativo (`neighbours`) | Que el comportamiento visual matchea el mockup UTA |
| 2 | Anonimato (nickname elegido) | Parcial (`identitymode` existe, modos desconocidos) | Qué modos ofrece; si llega a "alias auto-elegido" |
| 3 | Recompensas escalonadas | NO existe nativo | Confirmar ausencia; dimensionar construcción |

### Pipeline de verificación (idéntico por feature)

`seedear → activar config nativa → observar → decidir`.

**Paso 0 — Seed base (1 vez)**: poblar `PROG1-DEMO` con ~30 estudiantes y XP
variado (con 5 no se aprecia el efecto del ±5). Script SQL idempotente o CLI de
Moodle. Evidencia: `SELECT count(*)` + listado ordenado por XP.

**Feature 1 — Leaderboard ±5 (`neighbours`)**:
1. Activar `neighbours=5` en `block_xp_config` del curso.
2. Loguear como estudiante del medio del ranking; mirar el bloque.
3. Comparar contra el mockup UTA (11 filas, "TÚ" destacado).
4. Decidir: nativo alcanza → solo template (ya hecho en main) · no alcanza →
   query custom en Sprint 3 con los requisitos concretos hallados.

**Feature 2 — Anonimato (`identitymode`)**:
1. Enumerar valores que acepta `identitymode` (leer el PHP del upstream).
2. Probar cada modo; screenshot del ranking.
3. Comparar contra "alias elegido por el alumno".
4. Decidir: sí lo cubre → configurar · no → la feature nickname se construye
   (con boceto de cómo y estimación de esfuerzo).

**Feature 3 — Recompensas escalonadas**:
1. Confirmar ausencia de "rewards por threshold" en el upstream (más allá de badges).
2. Bosquejar las 2 tablas (`local_osyanificacion_rewards`,
   `local_osyanificacion_user_rewards`) y el enganche al evento "subió de nivel".
3. Decidir: confirmado 100% construcción nuestra → estimar tamaño para Sprint 4.

**Orden**: por riesgo decreciente. Parar tras la Feature 1 ya deja valor (la
feature más importante resuelta).

## Caminos alternativos (manejo de incógnitas)

- **Docker no levanta / fricción de entorno**: solo la Feature 1 (±5 visual)
  exige Moodle vivo. Las Features 2 y 3 son parcialmente code-reading del PHP
  upstream, que Claude puede hacer sin Docker. Si Docker no coopera, la Feature 1
  queda "pendiente de validación visual" y se avanza con las otras dos.
- **`neighbours=5` no se ve como el mockup**: no es fracaso, es el hallazgo que
  el sprint busca. Se documenta *en qué difiere* (¿>11 filas con empates? ¿orden
  raro? ¿no destaca al usuario?) → requisitos concretos para Sprint 3.
- **`identitymode` no llega al nickname elegido** (escenario sospechado): code-
  reading quirúrgico del upstream para identificar el punto de extensión (DI
  container / template) donde se inyectaría el alias. Output: mini-boceto + estimación.
- **Hallazgo inesperado** (cheat-guard interfiere con el seed, niveles dinámicos
  rompen el ranking, etc.): se anota como hallazgo y NO se resuelve en este sprint
  → input para replanificar. El riesgo "curva Moodle" está reconocido en el plan.

**Principio**: el sprint puede "fallar en verificar" y aun así ser exitoso. Su
producto es conocimiento + decisiones. Un "no se pudo confirmar X" documentado vale.

## Entregable

### `docs/architecture.md`

1. **Cómo funciona Level Up XP por dentro**: data flow en prosa + diagrama
   simple — XP otorgados (event listeners) → guardados (`block_xp`) → ranking
   calculado (`leaderboard/`) → renderizado (template chain). Permite explicar
   el sistema al docente.
2. **Resultados de verificación**: una subsección por feature (hipótesis, qué se
   probó, evidencia [SQL + screenshot], veredicto).
3. **Decisión de arquitectura**: wrappeo confirmado, con los 3 puntos de
   extensión (CSS override / template override / DI container) y cuál usa cada feature.

### Matriz de decisión (alimenta Sprints 3-4)

| Feature | ¿Nativo? | Esfuerzo si hay que construir | Punto de extensión | Sprint destino |
|---------|----------|-------------------------------|--------------------|----------------|
| Leaderboard ±5 | (a llenar) | (a llenar) | template / DI | 3 |
| Anonimato nickname | (a llenar) | (a llenar) | DI / tabla propia | 3 |
| Recompensas escalonadas | NO (esperado) | (a dimensionar) | tablas + evento | 4 |

### Evidencia cruda

- Screenshots → `presentation/screenshots-referencia/sprint2-verificacion/`
- Outputs SQL → embebidos en `architecture.md` como bloques de código.

### Nota de reconciliación

`architecture.md` reemplaza parcialmente lo que `plan-fase-1.md` decía de Sprints
2-3 (asumían "fork" y "leaderboard desde cero"). Se incluye una nota explícita
*"este hallazgo ajusta el plan original — ver matriz"* para no dejar contradicción
entre documentos (honestidad académica; el docente podría señalarla).

## Criterios de salida (Definition of Done)

1. Las 3 features tienen veredicto en la matriz con evidencia adjunta — o un "no
   se pudo verificar" documentado con su razón.
2. `docs/architecture.md` existe, explica el data flow del upstream, y pasa el
   markdown-lint del CI (líneas <200).
3. La matriz está completa y cada fila apunta a un sprint destino (3 o 4).
4. Hay nota de reconciliación con `plan-fase-1.md`.
5. La evidencia (screenshots + SQL) está en el repo.

## Integración al repo

Rama `docs/sprint2-architecture` → PR a `main` → CI verde → merge (review de
CODEOWNER, o admin override si Imanol trabaja solo). Es un PR de docs, bajo riesgo.

## Referencias

- `docs/level-up-xp-deep-dive.md` — cheatsheet del upstream (hallazgo `neighbours`).
- `docs/plan-fase-1.md` — roadmap general (Sprints 2-4 a reconciliar).
- `docs/benchmarking-level-up-xp.md` — por qué se wrappea.
- Upstream: https://github.com/FMCorz/moodle-block_xp
