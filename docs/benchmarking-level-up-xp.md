# Benchmarking — Level Up XP

> **Por qué este documento**: el plugin **Osyanificación** se construye
> sobre Level Up XP (no desde cero). Este doc explica qué es Level Up
> XP, qué hace, y por qué wrappeamos en vez de empezar de cero o
> simplemente instalar el plugin upstream tal cual.

## Qué es Level Up XP

Plugin de gamificación de Moodle desarrollado por **Frédéric Massart**
(core developer de Moodle). Es el plugin de gamificación más usado
del ecosistema Moodle.

- **Repo GitHub**: https://github.com/FMCorz/moodle-block_xp
- **Documentación oficial**: https://docs.levelup.plus/xp/docs
- **Sitio comercial (XP+ premium)**: https://levelup.plus/xp/

## Cifras

- **27.000+ sitios** lo usan a nivel mundial
- **9+ millones de aprendices** lo han utilizado
- **Certificado GDPR compliant**
- Versión Community gratuita + versiones Pro/Premium/Enterprise

## Funcionalidades que YA tiene

- Atribución automática de puntos por acciones del estudiante (event listeners)
- Bloque visual con nivel actual y barra de progreso
- Leaderboard ("Ladder") — ranking absoluto por defecto
- Notificaciones al subir de nivel
- Personalización de niveles (hasta 99), nombres, descripciones, umbrales
- Reporte para docentes con overview de progreso de estudiantes
- Shortcodes para insertar nivel/progreso/leaderboard en cualquier lugar
- Liberación condicional de contenido según nivel
- Teams (en versión XP+ paga)

## Por qué Level Up XP es la base CORRECTA

✅ **Valida técnicamente** que la gamificación en Moodle es viable
✅ **Valida legalmente** que cumple LOPDP/GDPR (importante para instituciones)
✅ **Destruye el argumento** de "esto va contra normativa" — 27K sitios lo usan
✅ **Hereda cumplimiento legal automáticamente** al wrappearlo
✅ **Licencia GPL** permite forkear/extender (con respeto a la licencia)

## La pregunta crítica

> *"¿Por qué no instalar Level Up XP que ya existe y es gratis?"*

Esta pregunta la va a hacer cualquier docente o director TIC que vea
el proyecto. **NECESITAMOS respuesta clara** para defender el scope.

## Diferenciadores reales de Osyanificación vs Level Up XP vanilla

### 1. Leaderboards relativos (±5 posiciones) — Diferenciador #1

Level Up XP usa **rankings absolutos por defecto**. Esto es exactamente
el problema que el marco teórico del proyecto identifica como nocivo
para la motivación intrínseca:

- **Ortiz-Rojas et al. (2025)** — Confirmó H1 (rendimiento, d=0.84)
  pero NO confirmó H2/H3 (motivación autónoma, autoeficacia) cuando se
  usaron leaderboards absolutos.
- **Hanus & Fox (2015)** — Documentó efectos NEGATIVOS de leaderboards
  absolutos sobre motivación intrínseca a largo plazo.

**Nuestra solución**: leaderboard relativo que muestra solo ±5 posiciones
alrededor del estudiante. Reduce comparación social tóxica preservando
el componente competitivo. Implementado vía `RANK() OVER` con filtro
`BETWEEN (my_pos - 5) AND (my_pos + 5)`.

### 2. Diseño contextualizado para entornos universitarios latinoamericanos

Level Up XP es:
- Genérico
- En inglés primario (traducciones comunitarias variables)
- Sin contexto cultural latinoamericano
- Sin alineación con estándares de calidad regionales (CACES, ARCU-SUR)

Osyanificación está calibrado a:
- Realidad ecuatoriana y/o latinoamericana
- Currículo típico de Ingeniería en Software
- Alineación con indicadores de calidad de la educación superior
  (CACES Subcriterio 5 en Ecuador, equivalentes en otros países)

### 3. Recompensas institucionales tangibles — Diferenciador #2

Level Up XP solo da **badges digitales**. Buen punto de partida, pero
insuficiente para mover comportamiento real.

Osyanificación contempla **recompensas reales escalonadas en 3 niveles**:

| Nivel | Costo | Ejemplos |
|---|---|---|
| **1** | Low | Certificados digitales, Hall of Fame, insignias |
| **2** | Medium | Mención en aula, certificado físico firmado, acceso prioritario a labs |
| **3** | High | Carta del decano, mención en Consejo Universitario, conexión con industria/pasantías |

Modelado con tabla `local_osyanificacion_rewards` (definiciones) +
`local_osyanificacion_user_rewards` (otorgadas). La entrega física de
recompensas Nivel 2-3 requiere flujo manual en la institución que
adopte el plugin — el plugin solo trackea estado digital.

### 4. Componente I+D con diseño cuasiexperimental

Level Up XP es **producto comercial**, no producto de investigación.

Osyanificación es **proyecto académico** con:
- Diseño pre-test / mid-test / post-test
- Effect size target Hedges g ≥ 0.5
- Instrumentos validados: IMI (Intrinsic Motivation Inventory) y SUS
- Mediación estadística analizable vía PROCESS v4.2
- Validación instrumental separada (Cronbach α por bloque temático)

Esto convierte al plugin en algo publicable: *"adaptación cultural de
gamificación open-source al contexto STEM latinoamericano"* es paper
defendible en revistas especializadas.

## Decisión estratégica derivada

**Wrappear Level Up XP en `local_osyanificacion`** es la jugada óptima
para el MVP porque:

1. **Aprovecha código probado** en 27K sitios sin reinventar la rueda
2. **Concentra esfuerzo en lo innovador** (leaderboards relativos +
   recompensas institucionales) en lugar de re-implementar atribución
   de puntos, event listeners, UI básica
3. **Hereda cumplimiento legal** automáticamente (GDPR/LOPDP heredado)
4. **Permite tesis publicable** sobre adaptación cultural, no sobre
   "construimos un plugin nuevo desde cero"
5. **Licencia GPL** del plugin original lo permite (con respeto a la
   licencia, créditos a Frédéric Massart, no relicenciar a propietario)
6. **Minimiza divergencia upstream** — el wrappeo en plugin separado
   sobreescribe queries específicas sin tocar el código de Level Up XP,
   facilita actualizar Level Up XP a versiones nuevas

### Wrappeo vs fork modificado

| Estrategia | Pros | Contras |
|---|---|---|
| **Wrappeo en plugin separado** (`local_osyanificacion` que sobreescribe queries) ✅ | Compatibilidad upstream, fácil de actualizar Level Up XP, separación clara | Limitado a lo que Level Up XP expone (hooks, eventos) |
| Fork modificado directo (modificar `block_xp` upstream) | Control total | Cada update de Level Up XP requiere merge manual; divergencia crece con tiempo |

**Decisión**: wrappeo. Se confirma en Sprint 2 después del code reading.

## Tareas pendientes para benchmarking real (Sprint 2)

- [ ] Descargar Level Up XP en Moodle local
- [x] Instalarlo y probarlo (Sprint 0 — ✅ hecho)
- [ ] Usarlo durante 1-2 semanas con datos reales del equipo
- [ ] Documentar UX, fortalezas y debilidades observadas
- [ ] Mapear gap analysis vs. propuesta Osyanificación
- [ ] Generar matriz comparativa para incluir en `docs/architecture.md`

## Referencias bibliográficas relevantes

- Hanus, M. D. & Fox, J. (2015). Assessing the effects of gamification
  in the classroom: A longitudinal study on intrinsic motivation,
  social comparison, satisfaction, effort, and academic performance.
  *Computers & Education*, 80, 152-161.
- Ortiz-Rojas, M. et al. (2025). How gamification boosts learning in
  STEM higher education: A mixed methods study. *Int. J. STEM Educ.*,
  12(1).
- Li, M., Ma, S. & Shi, Y. (2023). Examining the effectiveness of
  gamification as a tool promoting teaching and learning in educational
  settings: A meta-analysis. *Frontiers in Psychology*, 14.

(Listado parcial — la bibliografía completa vive en el documento
académico del proyecto, no en este repo.)
