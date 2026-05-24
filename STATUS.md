# Status board del equipo

> 🎯 **Propósito**: que los 3 integrantes sepan qué hace cada uno **en
> vivo**, evitando duplicar trabajo o pisar archivos. Actualizar al
> empezar una tarea importante y al cerrar el día.

> **Cómo usar**: edita tu sección, commit con mensaje
> `chore(status): <tu update>` y push directo a `main` (cambios chicos
> de STATUS.md están exentos del flujo de PR — son metadata, no código).

**Última actualización**: 2026-05-23

---

## 🎯 Imanol Miranda — Director + Lead Técnico

**En curso**:
- Coordinar arranque de Sprint 1 (réplica visual UTA) con Edison

**Próximo**:
- Sprint 1 (semana 2): apoyar a Edison en aplicar paleta UTA al theme + `format_tiles`
- Sprint 2 (semanas 3-4): fork de Level Up XP + code reading session con el equipo
- Sprint 3 (semanas 5-6): implementar leaderboard relativo ±5 (query SQL + Mustache)

**Recientemente cerrado**:
- ✅ Sprint 0 cerrado oficialmente (todas las tareas de setup)
- ✅ Scaffolding inicial + `docker-compose.yml` + `.env.example` + CI básico
- ✅ Fix INFRA-001 en paralelo con Álvaro (revertido para que el commit canónico quede a nombre de Álvaro)
- ✅ Seeds (`seeds/users.json`, `seeds/courses.json`, `seeds/README.md`) — PR #3
- ✅ Refactor genérico: `code/local/rankingfisei/` → `code/local/osyanificacion/` — PR #6
- ✅ Cambio `MOODLE_SITE_NAME` → "Gamificación demo" — PR #10
- ✅ **`docs/plan-fase-1.md` (545 líneas) + `docs/benchmarking-level-up-xp.md` (168 líneas)** — PR #11
- ✅ Fix line-length en README — PR #12
- ✅ Aplanado de jerarquía y política de lenguaje en `CONTRIBUTING.md` (commit directo a main)

**Archivos que está tocando (no mergees PRs que los modifiquen sin avisar)**:
- (ninguno al cierre del Sprint 0)

---

## 🛠️ Álvaro López — Infra & QA

**En curso**:
- Standby. Disponible para code reviews y smoke tests si Imanol/Edison piden.

**Próximo**:
- Sprint 1-4: standby (Edison/Imanol lideran)
- Sprint 3 (semanas 5-6): descomentar `moodle-plugin-ci` en `.github/workflows/ci.yml` cuando exista `code/local/osyanificacion/version.php` y haya primer test PHPUnit
- Sprint 5 (semana 8):
  - Ejecutar Cloudflare Tunnel: instalar `cloudflared`, levantar tunnel, validar desde celular
  - Correr JMeter contra Docker local: 50 users concurrentes, p95 < 500ms target
  - Optimizaciones de performance: opcache PHP, índices DB
- Sprint 6 (semanas 9-10): aportar métricas de estabilidad para README + slides
- **Opcional pendiente**: PR 3 (doc plan JMeter preview Sprint 5 #8) — sin urgencia

**Recientemente cerrado (Sprint 0 + adelantos Sprint 5)**:
- ✅ `docs/deployment.md` con troubleshooting + smoke test verificado — PR #1
- ✅ `.editorconfig` — PR #1
- ✅ Bug crítico **INFRA-001** descubierto, fixeado y documentado en `KNOWN_ISSUES.md` — PR #1
- ✅ Smoke test del stack: Moodle HTTP 200 en 83ms, bootstrap ~4 min
- ✅ `docs/plan-b-oracle-cloud.md` (~450 líneas, adelantado de Sprint 5 #9) — PR #2
- ✅ Mejoras CI: `secret-scan` (gitleaks) + `markdown-lint` (markdownlint-cli2) + `json-validate` (jq) — PR #6/#7 (revert #4→#5 antes)
- ✅ Code review de los seeds de Imanol (PR #3) con 4 sugerencias S1-S4
- ✅ Setup completo de seeds en Moodle local (6 users + categoría + curso PROG1-DEMO + 5 actividades)
- ✅ Combo DX: `Makefile` + `.github/PULL_REQUEST_TEMPLATE.md` + `.github/ISSUE_TEMPLATE/*` + `.vscode/` + `STATUS.md` — PR #8
- ✅ `docs/plan-a-cloudflare-tunnel.md` (~425 líneas, adelantado de Sprint 5 #7) — PR #9

**Archivos que está tocando**:
- (ninguno al cierre del Sprint 0)

---

## 🎨 Edison Landeta — UI/UX & Docs

**En curso**:
- 🟢 **Lidera Sprint 1** — réplica visual UTA arrancando ahora (próximo paso humano según `docs/plan-fase-1.md`)

**Próximo**:
- Sprint 1 (semana 2): aplicar paleta UTA (`#233A83` primary, `#F2F3F7` bg, `#1D2125` text, border-radius `8px`),
  instalar/configurar `format_tiles`, screenshots comparativos UTA real vs local,
  decisión Boost-custom vs Moove (este último requiere licencia)
- Sprint 3: templates Mustache del leaderboard relativo ±5 con highlight "TÚ" en dorado (paridad con mockups del proyecto)
- Sprint 4: UI de recompensas escalonadas (3 niveles)
- Sprint 6: video demo 3-5 min (OBS) + slide deck 8-10 slides en PDF

**Recientemente cerrado**:
- (Edison todavía no abrió PRs propios; en Sprint 0 su rol fue mayormente standby/aprendizaje)

**Archivos que está tocando**:
- (arrancando, decidir entre Boost o Moove primero)

---

## 🚧 Ramas abiertas en remoto

| Rama | Owner | Estado | Acción sugerida |
|---|---|---|---|
| `main` | equipo | Trunk principal, al día | — |

> Todas las ramas de Sprint 0 fueron mergeadas y borradas. Cuando arranque Sprint 1, Edison creará la rama `feature/theme-uta-paleta` (o similar).

---

## ⚠️ Alertas activas

> Cosas que el equipo debe saber antes de empezar trabajo nuevo.

- **2026-05-22**: `bitnami/moodle:4.3` ya no es pulleable sin Bitnami Secure. Usamos `bitnamilegacy/*`
  (ver `KNOWN_ISSUES.md` INFRA-001). Si alguien clona en frío y le falla `docker compose up`, mirá ahí primero.
- **2026-05-23**: **Sprint 0 oficialmente cerrado**. Próximo paso humano: Edison arranca Sprint 1 (réplica visual UTA). Plan completo en [`docs/plan-fase-1.md`](docs/plan-fase-1.md).
- **2026-05-23**: Lectura obligatoria del equipo antes de Sprint 2: `docs/plan-fase-1.md` (545 líneas, mapa de
  7 sprints) + `docs/benchmarking-level-up-xp.md` (168 líneas, por qué wrappeamos en lugar de fork modificado).
- **2026-05-23**: `MOODLE_SITE_NAME` cambió en `.env.example` a "Gamificación demo". Si querés que tu Moodle
  local muestre el nombre nuevo, actualizá tu `.env` local y `docker compose restart moodle`.

---

## 📅 Convención de updates

- **Edita tu sección** antes de empezar tarea grande (Sprint 1+)
- **`make status`** muestra este archivo desde la terminal
- **Commits a STATUS.md**: usar mensaje `chore(status): <qué cambia>` y pushear directo a main (excepción al PR flow)
- Si alguien edita STATUS.md al mismo tiempo que vos → resolver merge manualmente (es un md, fácil)
