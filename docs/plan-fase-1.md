# Plan técnico — Fase 1 LOCAL (Validación Técnica)

> **Objetivo de Fase 1**: tener un plugin de Moodle funcional, instalable,
> con tests, documentado y demostrable, corriendo en un Moodle propio del
> equipo. Sin estudiantes reales todavía — el universo de usuarios son los
> 3 integrantes + ~5 cuentas de prueba. **No es el piloto empírico — es la
> validación técnica que abre Fase 2.**

## 🎯 Resumen ejecutivo

| Dimensión | Decisión |
|---|---|
| **Duración** | 8-10 semanas (~2 meses de trabajo de equipo a tiempo parcial) |
| **Entorno principal** | Moodle 4.x con theme `moove` + `format_tiles` (replica del UTA real) |
| **Hosting** | **Docker local en cada laptop** (todos los sprints) · Cloudflare Tunnel para exponer demo pública cuando se necesite (Sprint 5+) · **0 costo** |
| **Base del plugin** | Fork de [`FMCorz/moodle-block_xp`](https://github.com/FMCorz/moodle-block_xp) (Level Up XP, GPL) — ver [`docs/benchmarking-level-up-xp.md`](./benchmarking-level-up-xp.md) |
| **Stack del plugin** | PHP 8.1+ · Mustache · Chart.js · MariaDB |
| **Equipo** | Imanol (Director + Lead Técnico) + Álvaro (Colaborador Infra/QA) + Edison (Colaborador UI/Docs) |
| **Repositorio** | GitHub privado (futuro público bajo GPL al cierre de Fase 1) |
| **Output final** | Plugin funcional + video demo (3-5 min) + README + tests + métricas estabilidad |
| **Criterio de salida** | ✅ Plugin instalable en Moodle limpio · ✅ Cobertura tests ≥ 70% · ✅ 50 usuarios concurrentes simulados sin crash · ✅ Documentación lista para llevar a institución externa |

## 🧱 Pre-requisitos antes de Sprint 0

Antes de tocar cualquier código, el equipo necesita:

### Conocimiento mínimo (1-2 semanas previas o en paralelo)

- **PHP 8.1+**: sintaxis básica, namespaces, autoloading, tipos estrictos
- **Moodle development**: lectura de [Plugin development docs](https://moodledev.io/docs/4.x) (al menos el capítulo de bloques)
- **Mustache**: templating lógicamente simple (Moodle lo usa)
- **Git con flujo de ramas**: `feature/`, `fix/`, PRs entre el equipo
- **Docker básico**: `docker run`, `docker-compose`, volúmenes

### Recursos de aprendizaje recomendados

| Tema | Recurso | Tiempo estimado |
|---|---|---|
| Moodle plugin types | https://moodledev.io/docs/4.x/apis/plugintypes | 2h lectura |
| Block plugin walkthrough | https://moodledev.io/docs/4.x/apis/plugintypes/blocks | 4h |
| Level Up XP código fuente | https://github.com/FMCorz/moodle-block_xp | 8-12h estudio |
| PHP moderno (8.1+) | PHP The Right Way (https://phptherightway.com) | 4h |
| Mustache en Moodle | https://moodledev.io/docs/4.x/guides/templates | 2h |

### Herramientas en cada laptop del equipo

- ✅ Docker Desktop instalado y funcionando
- ✅ Git + cuenta GitHub
- ✅ VS Code (recomendado) con extensiones: PHP Intelephense, Mustache syntax, Docker
- ✅ Cliente DB (DBeaver o TablePlus) para inspeccionar MariaDB
- ✅ Postman o equivalente para probar APIs de Moodle

## 🏗️ Decisión arquitectónica clave: Docker local + Cloudflare Tunnel

### Propuesta: **0 costo durante toda la Fase 1**

```
SPRINTS 0-4 (semanas 1-7) → Docker local en cada laptop del equipo
  Pros: 0 costo, reset rápido, sin red necesaria, sin riesgo público
  Contras: cada uno trabaja con su propia BD (se sincroniza vía Git + seeds)

SPRINTS 5-6 (semanas 8-10) → Docker local + Cloudflare Tunnel cuando haga falta demo
  Pros: 0 costo, URL HTTPS pública sin abrir puertos, sin firewall, sin SSL setup
  Contras: la demo solo está viva mientras la laptop está prendida con el tunnel
           (mitigación: para Fase 2, prender un rato cuando se presente)
```

**Justificación**: en un proyecto académico de 3 estudiantes en Ecuador,
pagar VPS no se justifica para Fase 1 LOCAL (la palabra "local" está en
el nombre). Cloudflare Tunnel cubre la necesidad real del Sprint 5
("tener URL para mostrar a externos") sin costo y sin admin de servidor.

Ver setup completo en [`docs/plan-a-cloudflare-tunnel.md`](./plan-a-cloudflare-tunnel.md)
y plan B en [`docs/plan-b-oracle-cloud.md`](./plan-b-oracle-cloud.md).

### Stack Docker propuesto

`docker-compose.yml` con 3 servicios + 1 opcional para Sprint 5:

| Servicio | Imagen | Notas |
|---|---|---|
| `moodle` | `bitnamilegacy/moodle:4.3` | Image oficial Bitnami (ver INFRA-001 en `KNOWN_ISSUES.md`) |
| `mariadb` | `bitnamilegacy/mariadb:10.11` | Versión compatible con Moodle 4.x |
| `mailhog` | `mailhog/mailhog:latest` | Capturar emails de prueba sin SMTP real |
| `cloudflared` (Sprint 5+) | `cloudflare/cloudflared:latest` | Opcional, levanta el tunnel cuando hay que mostrar la demo |

Volúmenes:
- `./moodledata` → datos persistentes
- `./code/local/osyanificacion/` → bind mount al plugin propio en desarrollo
- `./code/blocks/xp/` → bind mount al fork de Level Up XP

**Costo total Fase 1**: **$0** (o **USD 1-3** si quieren dominio
opcional para URL fija con Cloudflare).

## 🛠️ Stack técnico exacto

### Plataforma

| Componente | Versión | Justificación |
|---|---|---|
| Moodle | **4.3 LTS o 4.5** | Match con UTA (4.x); LTS para estabilidad larga |
| PHP | **8.1+** | Requerido por Moodle 4.3+ |
| MariaDB | **10.11** | Mejor compatibilidad que MySQL 8 con Moodle |
| Web server | **Apache** (vía Bitnami) | Nginx también va, Apache es más estándar Moodle |
| Theme | **`moove`** premium | Match exacto con UTA (Pimenko, ~€60 anuales o usar fork comunitario) |
| Course format | **`format_tiles`** | Match con UTA (Davo Smith, freemium gratis para básico) |

⚠️ **Sobre theme Moove**: la licencia premium puede ser un costo. Alternativas:
- Versión Boost personalizada con paleta UTA (`#233A83`) → 0 costo, look "parecido" pero no idéntico
- Theme Moove free version (si existe) → comprobar en moodle.org/plugins
- Comprar licencia académica si Pimenko ofrece descuento estudiantil
- **Decisión**: empezar con Boost personalizado, evaluar Moove en Sprint 3 si el look importa para Fase 2

### Plugin propio

| Componente | Tecnología | Notas |
|---|---|---|
| Tipo de plugin | **`local`** + **`block`** | `local` para lógica core, `block` para UI en dashboard/curso |
| Nombre interno | `local_osyanificacion` y `block_osyanificacion` | Convención Moodle: minúsculas, sin guiones |
| Charts | **Chart.js 4.x** | Match con mockups + estándar Moodle 4.x |
| Templating | **Mustache** | Estándar Moodle |
| Tests | **PHPUnit** (vía Moodle) + **Behat** (E2E) | Stack oficial Moodle |
| Build | Sin build step (PHP servido directo) | Sólo `composer` para deps si se usan |

## 📅 Roadmap por sprints

> Cada sprint = ~1 semana de trabajo del equipo en paralelo (tiempo
> parcial, ~10-15h/semana por persona).

### Sprint 0 — Setup (semana 1)

**Objetivo**: todos los integrantes tienen entorno funcionando idéntico.

**Tareas**:
- [x] Repo Git creado en GitHub privado (`Osyanificacion-Plugin-Moodle`)
- [x] README inicial con arquitectura + cómo levantar Docker
- [x] `docker-compose.yml` funcional con Moodle 4.3 + MariaDB + Mailhog
- [x] Cada persona del equipo levanta el stack y accede a `http://localhost:8080`
- [x] Crear cuenta admin + 5 cuentas estudiante de prueba (datos seed)
- [x] Crear 1 curso de prueba en formato Tiles con 3-5 actividades dummy
- [x] Probar Level Up XP base instalado (descargado de moodle.org/plugins)
- [x] Decidir nombre final del plugin propio
- [x] Definir convenciones de código (PSR-12, naming, branch strategy)

**Estado**: ✅ COMPLETADO (23 may 2026)

**Entregable**: cada persona del equipo abre Moodle local y ve Level Up XP funcionando.

### Sprint 1 — Replica visual UTA (semana 2)

**Objetivo**: Moodle local se parece visualmente al de UTA FISEI.

**Tareas**:
- [ ] Decidir Boost-custom vs Moove (ver decisión arquitectónica arriba)
- [ ] Aplicar paleta UTA al theme elegido:
  - Primary: `#233A83`
  - Body bg: `#F2F3F7`
  - Body text: `#1D2125`
  - Card border-radius: `8px`
- [ ] Instalar y configurar `format_tiles` en cursos de prueba
- [ ] Tipografía: system stack (no Google Fonts)
- [ ] Estructura genérica de cursos demo en categoría `DEMO-CAT` (curso `PROG1-DEMO` y similares)
- [ ] Captura de screenshots comparativos UTA real vs local

**Bloqueadores potenciales**:
- Format Tiles puede pedir activación premium para features avanzadas → usar features free
- Theme Moove requiere licencia → fallback Boost

**Entregable**: screenshot comparativo lado-a-lado (UTA vs local) que
demuestre paridad visual razonable.

### Sprint 2 — Fork de Level Up XP + estudio del código (semanas 3-4)

**Objetivo**: el equipo entiende el código de Level Up XP y tiene su fork
operativo.

**Tareas**:
- [ ] Fork de `FMCorz/moodle-block_xp` a la organización del equipo
- [ ] Clonar el fork en `code/blocks/xp/` (bind mount Docker)
- [ ] Renombrar bloque interno si se quiere identidad propia, o mantener
  el original con extensión `local_osyanificacion` que lo wrappea
- [ ] **Code reading session**: el equipo (los 3) lee juntos durante 2-3
  sesiones de 2h:
  - `classes/local/` (lógica core)
  - `db/` (esquema DB: tabla `block_xp` con user_id, courseid, xp)
  - `templates/` (Mustache)
  - `lang/en/` (strings)
- [ ] Documentar en `docs/architecture.md`:
  - Cómo Level Up XP atribuye puntos (event listeners)
  - Cómo calcula leaderboard (query SQL)
  - Cómo renderiza el bloque (template chain)
- [ ] Identificar puntos de extensión (hooks) para no modificar core
- [ ] Decidir estrategia: **¿modificar upstream o wrappear en plugin propio?**
  - Recomendado: **wrappear** en `local_osyanificacion` que sobreescribe
    queries de leaderboard y agrega tabla `local_osyanificacion_rewards`.
    Mantiene compatibilidad upstream.

**Bloqueadores potenciales**:
- Curva de aprendizaje Moodle architecture es la más alta del proyecto
- Si el wrappeo es muy complejo, considerar fork modificado directo
  (asumiendo costo de mantenimiento upstream)

**Entregable**: documento `docs/architecture.md` con diagrama del flujo
de datos en Level Up XP + decisión de wrappeo vs fork modificado.

### Sprint 3 — Leaderboard relativo ±5 (semanas 5-6)

**Objetivo**: el primer diferenciador real del plugin está funcionando.

**Tareas**:
- [ ] Implementar query SQL del leaderboard relativo:
  ```sql
  -- Pseudocódigo
  SELECT user_id, xp, RANK() OVER (ORDER BY xp DESC) as pos
  FROM mdl_block_xp
  WHERE courseid = :courseid
    AND pos BETWEEN (:my_pos - 5) AND (:my_pos + 5)
  ```
- [ ] Template Mustache nuevo: `leaderboard-relative.mustache`
- [ ] Renderizar bloque con leaderboard ±5 destacando "TÚ" en dorado
- [ ] Configuración del bloque: toggle absoluto vs relativo
- [ ] Tests PHPUnit:
  - Test de query con 1 usuario (caso borde: no hay ±5)
  - Test con 100 usuarios (caso normal)
  - Test con empate de XP (RANK debe manejar ties)
- [ ] Tests Behat (E2E):
  - Usuario logueado ve leaderboard ±5
  - Usuario sin XP ve placeholder amigable

**Bloqueadores potenciales**:
- Performance del ranking en cohorts grandes — agregar índice si necesario
- Empates en RANK() pueden mostrar más de 11 filas — definir comportamiento

**Entregable**: plugin con leaderboard relativo funcionando.

### Sprint 4 — Recompensas escalonadas (semana 7)

**Objetivo**: el segundo diferenciador (recompensas reales, no solo
badges digitales) está implementado.

**Tareas**:
- [ ] Diseñar tabla `local_osyanificacion_rewards`:
  - `id`, `level` (1/2/3), `name`, `description`, `xp_threshold`, `image_url`
- [ ] Diseñar tabla `local_osyanificacion_user_rewards`:
  - `id`, `userid`, `reward_id`, `claimed_at`, `claimed_status` (pending/claimed/redeemed)
- [ ] Seed inicial con 6-9 recompensas:
  - Nivel 1 (low cost): Certificado digital, Hall of Fame, Insignia
  - Nivel 2 (medium): Mención en aula, certificado físico firmado
  - Nivel 3 (high): Carta del decano, mención en consejo, etc.
- [ ] UI: página dedicada `local/osyanificacion/rewards.php`
- [ ] Notificación al alcanzar threshold (vía Moodle messages API)
- [ ] Tests PHPUnit:
  - Otorgar reward al cruzar threshold
  - No otorgar duplicado
  - Cálculo correcto de nivel actual

**Bloqueadores potenciales**:
- Las recompensas reales requerirán flujo manual en Fase 2 (entregar
  certificados físicos, etc.). En Fase 1 solo se simula con estado
  digital.

**Entregable**: usuario que acumula XP suficiente ve la recompensa
desbloqueada en su perfil + recibe notificación.

### Sprint 5 — Exposición pública (Cloudflare Tunnel) + estabilización (semana 8)

**Objetivo**: el plugin corre en Docker local con URL HTTPS pública vía
Cloudflare Tunnel, listo para presentar a institución externa en Fase 2.
**0 costo** de infraestructura.

**Tareas**:
- [ ] Instalar `cloudflared` en una laptop del equipo (sugerido: Álvaro)
- [ ] Levantar tunnel temporal: `cloudflared tunnel --url http://localhost:8080`
- [ ] Verificar que la URL temporal abre el Moodle local desde otro dispositivo
  (probar desde celular con datos móviles, no la misma WiFi)
- [ ] Decidir si vale la pena URL fija (~USD 1-3/año en dominio) — opcional
- [ ] Si URL fija: crear cuenta Cloudflare, registrar dominio, crear tunnel
  autenticado, apuntar DNS
- [ ] Carga de prueba **local con JMeter** simulando 50 usuarios concurrentes
  (no necesita ser sobre el tunnel — basta con probar contra Docker local)
- [ ] Optimizaciones de performance: habilitar `opcache` PHP, ajustar
  pool de conexiones MariaDB, agregar índices DB donde falten
- [ ] Documentar setup del tunnel paso a paso en `docs/deployment.md`
  (ya documentado en `docs/plan-a-cloudflare-tunnel.md`)
- [ ] Plan B documentado: `docs/plan-b-oracle-cloud.md` como fallback
  si en Fase 2 hace falta URL 24/7

**Bloqueadores potenciales**:
- Performance de Moodle en laptop de gama media — habilitar `opcache` PHP
  resuelve el 90% de casos
- Si Cloudflare bloquea cuenta por uso de tunnel "comercial" (raro pero
  posible) → activar Plan B Oracle Free Tier

**Entregable**: URL temporal o fija accesible vía Cloudflare Tunnel
que abre Moodle con plugin funcionando, accesible desde cualquier red.

### Sprint 6 — Documentación + video demo (semanas 9-10)

**Objetivo**: paquete completo para llevar a Fase 2.

**Tareas**:
- [ ] **README final** del repo con:
  - Captura del plugin en acción (gif animado)
  - Cómo instalar (Docker quick start + Moodle plugin install)
  - Cómo configurar
  - Roadmap futuro (Fase 2-3 mencionado)
  - Licencia GPL respetada
  - Créditos al equipo (Imanol, Álvaro, Edison) + a Level Up XP upstream
- [ ] **`docs/`** completos:
  - `architecture.md` (Sprint 2)
  - `deployment.md` (Sprint 5)
  - `user-guide.md` (paso a paso para docentes y estudiantes)
  - `api-reference.md` (hooks, eventos, configuración)
  - `research-context.md` (link al doc académico v19.1 + breve resumen
    del marco teórico PBL+F)
- [ ] **Video demo 3-5 min** grabado con OBS:
  - Intro (15s): qué es el proyecto
  - Tour estudiante (90s): registro, hacer actividades, ver XP/level
    aumentar, leaderboard ±5, recompensa desbloqueada
  - Tour docente (60s): ver progreso del curso, configurar puntos
  - Cierre (30s): roadmap a Fase 2, cómo contactar
- [ ] **Slide deck 8-10 slides** para presentar a institución externa
  Fase 2 (apoya el pitch, no lo reemplaza)
- [ ] **Métricas de estabilidad** documentadas:
  - 0 crashes en pruebas de carga
  - p95 response time < 500ms en queries leaderboard
  - Cobertura tests ≥ 70%

**Bloqueadores potenciales**:
- Grabar video con buen audio requiere mic decente (puede pedirse prestado)
- Edición rápida con DaVinci Resolve o Premiere requiere ~4-6h

**Entregable**: repo público (o invitación-only) listo + video subido a
YouTube unlisted + slides en PDF.

## 👥 Distribución de roles del equipo

> **Principio**: Imanol es el **director del proyecto** + lead técnico.
> Coordina, supervisa y toma decisiones finales. Álvaro y Edison son
> colaboradores técnicos especializados que ejecutan bajo su dirección.

### 🎯 Imanol Miranda — Director del Proyecto + Lead Técnico

**Como Director del Proyecto** (coordinación):
- **Decisión final** sobre arquitectura, scope y cronograma
- Planeación general del proyecto y de cada sprint
- Asignación y seguimiento de tareas a Álvaro y Edison
- Daily/weekly check-ins con el equipo, desbloqueos
- Comunicación con asesores externos del proyecto académico
- Validación final antes de cerrar cada sprint
- Representante del proyecto en cualquier presentación (clases,
  reuniones, eventual demo a institución externa Fase 2)
- Mantenimiento de la documentación del proyecto

**Como Lead Técnico** (ejecución):
- Arquitectura del plugin (decisiones de wrappeo vs fork, hooks)
- Implementación del core PHP (queries SQL, lógica del leaderboard
  ±5, recompensas escalonadas)
- Code reviews aprobatorios de PRs de Álvaro y Edison
- Resolución de bloqueadores técnicos del equipo

**Aprendizaje requerido**: PHP 8.1+ profundo, Moodle plugin APIs,
patrones de diseño en PHP, además de habilidades de gestión de
equipos pequeños.

**Carga estimada**: **18-22h/semana** (más alta del equipo por la
doble función).

### 🛠️ Álvaro López — Colaborador Infra & QA

> **Reporta a**: Imanol. Ejecuta tareas asignadas en el plan + ad-hoc
> que surjan del seguimiento del director.

**Responsabilidades primarias**:
- Setup Docker + `docker-compose.yml` (Sprint 0)
- Setup Cloudflare Tunnel (Sprint 5) — instalar `cloudflared`, levantar
  tunnel, documentar uso para demos de Fase 2
- Carga de pruebas con JMeter (local, contra Docker)
- Tests PHPUnit y Behat (corre los tests + reporta resultados a Imanol)
- CI/CD básico (GitHub Actions corriendo tests en cada PR)
- Plan B documentado: instrucciones Oracle Cloud Free Tier por si
  Cloudflare Tunnel resulta limitante
- **Reporta progreso/bloqueos a Imanol** en cada check-in

**Aprendizaje requerido**: Docker, Cloudflare Tunnel CLI, PHPUnit/Behat,
GitHub Actions.

**Carga estimada**: 10-15h/semana.

### 🎨 Edison Landeta — Colaborador UI/UX & Documentación

> **Reporta a**: Imanol. Ejecuta tareas asignadas en el plan + ad-hoc
> que surjan del seguimiento del director.

**Responsabilidades primarias**:
- Templates Mustache + estilos CSS (paridad con mockups del proyecto)
- Chart.js charts (paridad con mockups visuales)
- Documentación técnica y de usuario (README, `user-guide.md`,
  `architecture.md`, `api-reference.md`)
- Video demo 3-5 min (grabación + edición)
- Slide deck Fase 2 (8-10 slides en PDF)
- Soporte testing (smoke tests, UX QA)
- **Reporta progreso/bloqueos a Imanol** en cada check-in

**Aprendizaje requerido**: Mustache, Chart.js, CSS moderno, video editing
básico (DaVinci Resolve free o Premiere).

**Carga estimada**: 10-15h/semana.

## ✅ Criterios de salida de Fase 1

Para considerar Fase 1 COMPLETA y pasar a Fase 2, todo lo siguiente debe
ser ✅:

### Técnicos

- [ ] Plugin instalable en Moodle 4.x limpio en menos de 10 minutos
- [ ] Leaderboard relativo ±5 funcionando (diferenciador #1)
- [ ] Recompensas escalonadas funcionando (diferenciador #2)
- [ ] 0 crashes en pruebas de carga (50 usuarios concurrentes)
- [ ] p95 query response < 500ms en leaderboard
- [ ] Cobertura de tests ≥ 70% en lógica de negocio
- [ ] CI verde en GitHub Actions

### Documentación

- [ ] README completo con quick start
- [ ] `docs/architecture.md`, `deployment.md`, `user-guide.md` completos
- [ ] Video demo 3-5 min subido (YouTube unlisted aceptable)
- [ ] Slide deck 8-10 slides en PDF
- [ ] License GPL declarada + créditos a Level Up XP upstream

### Validación interna

- [ ] Los 3 integrantes probaron como estudiante y como docente
- [ ] Lista de bugs conocidos + workarounds (`KNOWN_ISSUES.md`)

### Output a Fase 2

- [ ] Pitch deck listo para presentar a institución externa candidata
- [ ] URL del demo en vivo + credenciales de prueba documentadas

## ⚠️ Riesgos técnicos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Curva de aprendizaje Moodle APIs más alta de lo esperado | **Alta** | Alto | Sprint 2 dedicado solo a code reading. Buscar mentores en foros Moodle. |
| Fork de Level Up XP rompe en updates upstream | Media | Medio | Estrategia de **wrappeo** en `local_osyanificacion` minimiza divergencia. Documentar cambios. |
| Performance del leaderboard en cohortes grandes | Baja | Medio | Índice DB en `(courseid, xp DESC)`. Caching de resultados por 5 min. |
| Theme Moove requiere licencia paga | Media | Bajo | Fallback a Boost-custom con paleta UTA. La paridad visual perfecta no es bloqueante para Fase 1. |
| Tiempo del equipo se diluye con carga académica regular | **Alta** | Alto | Plan tiene buffer de 2 semanas. Daily updates obligan a movimiento constante. Si se atrasa, mover Sprints 4-5 a paralelo. |
| Conflictos de Git por trabajar todos en archivos cercanos | Media | Bajo | PRs pequeños, branch strategy clara, sync semanal. |
| Pérdida de motivación a mitad de fase | Media | Alto | Sprint 3 (leaderboard ±5) es el más visualmente gratificante — programarlo bien. Celebrar entregables. |
| Cloudflare Tunnel se cae o bloquea cuenta | Baja | Medio | Plan B documentado: Oracle Cloud Free Tier ARM (4 vCPU, 24GB RAM, $0 permanente). Si la demo es importante, tener el setup listo de respaldo. |

## 📁 Estructura del repositorio

```
Osyanificacion-Plugin-Moodle/
├── README.md                          ← entrada principal
├── LICENSE                            ← GPL v3 (heredada de Level Up XP)
├── CONTRIBUTING.md                    ← guía para PRs
├── KNOWN_ISSUES.md                    ← bugs conocidos (INFRA-001, etc.)
├── STATUS.md                          ← status board del equipo
├── docker-compose.yml                 ← stack local
├── Makefile                           ← shortcuts (make up/down/reset/...)
├── .env.example                       ← template variables de entorno
├── .editorconfig                      ← reglas de formato por tipo
├── .markdownlint.jsonc                ← config markdown lint
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   └── feature_request.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── ci.yml                     ← validate-yaml + validate-structure + secret-scan + markdown-lint + json-validate
├── .vscode/
│   ├── extensions.json
│   └── settings.json
├── code/
│   ├── local/
│   │   └── osyanificacion/            ← plugin propio
│   │       ├── version.php
│   │       ├── lang/{es,en}/
│   │       ├── classes/
│   │       ├── db/{install.xml, upgrade.php}
│   │       ├── templates/
│   │       ├── tests/{phpunit, behat}/
│   │       └── README.md
│   └── blocks/
│       └── xp/                        ← fork Level Up XP (submodule o bind)
├── docs/
│   ├── plan-fase-1.md                 ← este documento
│   ├── benchmarking-level-up-xp.md    ← análisis del competidor
│   ├── deployment.md                  ← cómo desplegar
│   ├── plan-a-cloudflare-tunnel.md    ← exposición pública opción A
│   ├── plan-b-oracle-cloud.md         ← exposición pública opción B
│   ├── architecture.md                ← (Sprint 2)
│   ├── user-guide.md                  ← (Sprint 6)
│   ├── api-reference.md               ← (Sprint 6)
│   └── research-context.md            ← (Sprint 6)
├── seeds/
│   ├── users.json
│   ├── courses.json
│   └── README.md                      ← cómo crear seeds en Moodle UI
└── presentation/
    ├── deck-fase-2.pdf                ← (Sprint 6)
    └── video-demo-link.md             ← (Sprint 6)
```

## 🔗 Conexión con Fase 2 y Fase 3

### Salida de Fase 1 → entrada de Fase 2

El output de Fase 1 alimenta directamente la negociación de Fase 2:

- **Video demo** → primer pitch a institución externa candidata
- **URL del demo en vivo** → ellos lo prueban sin instalar nada
- **Métricas de estabilidad** → argumento técnico ("ya está probado")
- **README + docs** → si dicen "muéstrenme cómo se instala", está listo

### Salida de Fase 1 → entrada de Fase 3 (futuro)

Cuando llegue Fase 3 (reintento de adopción institucional en
universidad de origen):

- El paquete de Fase 1 + datos de Fase 2 forman el "apoyo y sustento"
- El plugin probado en producción de otra institución es el argumento más fuerte ante la unidad responsable de plataformas educativas

## 📁 Estado del Sprint 0

| Item | Estado |
|---|---|
| Plan técnico (este documento) | ✅ Publicado (23 may 2026) |
| Sprint 0 (setup) | ✅ Completado al 100% |
| Repo Git creado | ✅ https://github.com/Osyanne/Osyanificacion-Plugin-Moodle |
| Docker stack validado | ✅ Moodle 4.3 + MariaDB + Mailhog corriendo |
| Level Up XP base instalado | ✅ v20.0 validado in-vivo |
| Curso de prueba PROG1-DEMO | ✅ Creado en Moodle local |
| CI pipeline | ✅ 5 jobs verdes (validate-yaml + validate-structure + secret-scan + markdown-lint + json-validate) |
| Decisión Boost vs Moove | ⏳ Pendiente (decidir en Sprint 1) |
| Decisión URL fija (Cloudflare) o temporal | ⏳ Pendiente (decidir en Sprint 5, ~USD 1-3/año si quieren dominio fijo) |

**Próximo paso humano**: arrancar Sprint 1 (réplica visual UTA) con
Edison liderando.
