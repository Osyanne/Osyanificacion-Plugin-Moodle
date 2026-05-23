# Status board del equipo

> 🎯 **Propósito**: que los 3 integrantes sepan qué hace cada uno **en
> vivo**, evitando duplicar trabajo o pisar archivos. Actualizar al
> empezar una tarea importante y al cerrar el día.

> **Cómo usar**: edita tu sección, commit con mensaje
> `chore(status): <tu update>` y push directo a `main` (cambios chicos
> de STATUS.md están exentos del flujo de PR — son metadata, no código).

**Última actualización**: 2026-05-22 (fecha actual al cierre del día)

---

## 🎯 Imanol Miranda — Director + Lead Técnico

**En curso**:
- (sin tarea activa al cierre de Sprint 0)

**Próximo**:
- Sprint 1: réplica visual UTA (theme Boost/Moove + paleta `#233A83` + `format_tiles`)
- Sprint 2: fork de Level Up XP + code reading session con el equipo

**Recientemente cerrado**:
- ✅ Scaffolding inicial del repo
- ✅ `docker-compose.yml` + `.env.example` + CI básico
- ✅ Fix INFRA-001 en paralelo con Álvaro (revertido para que el commit canónico quede a nombre de Álvaro)
- ✅ Seeds (`seeds/users.json`, `seeds/courses.json`, `seeds/README.md`)
- ✅ Refactor genérico: `code/local/rankingfisei/` → `code/local/osyanificacion/` (FISEI removido del naming técnico)

**Archivos que está tocando (no mergees PRs que los modifiquen sin avisar)**:
- (ninguno al cierre del día)

---

## 🛠️ Álvaro López — Infra & QA

**En curso**:
- (cerró su carga de Sprint 0)

**Próximo**:
- Sprint 1-4: standby. Disponible para code reviews y smoke tests si Imanol/Edison piden.
- Adelantar Sprint 5: docs Cloudflare Tunnel (#7) y plan JMeter (#8) cuando haya tiempo
- Sprint 3+: descomentar `moodle-plugin-ci` en `.github/workflows/ci.yml` cuando exista `code/local/osyanificacion/version.php`
- Sprint 5 ejecución real: instalar `cloudflared`, levantar tunnel, correr JMeter

**Recientemente cerrado (Sprint 0)**:
- ✅ `docs/deployment.md` con troubleshooting + smoke test verificado (PR #1)
- ✅ `.editorconfig` (PR #1)
- ✅ Bug crítico **INFRA-001** descubierto y documentado en `KNOWN_ISSUES.md` (PR #1)
- ✅ Smoke test del stack: Moodle responde HTTP 200 en 83ms, bootstrap ~4 min
- ✅ Plan B Oracle Cloud Free Tier en `docs/plan-b-oracle-cloud.md` ~450 líneas (PR #2, adelantado de Sprint 5)
- ✅ Mejoras CI: `secret-scan` (gitleaks) + `markdown-lint` (markdownlint-cli2) + `json-validate` (jq) (PR #6, después de revert previo)
- ✅ Code review de los seeds de Imanol (PR #3) con 4 sugerencias
- ✅ Setup completo de seeds en su Moodle local (6 users + categoría + curso ALG-DEMO + 5 actividades)
- ✅ Este PR: `Makefile` + GitHub templates + `.vscode/` + `STATUS.md`

**Archivos que está tocando**:
- (ninguno al cierre del día)

---

## 🎨 Edison Landeta — UI/UX & Docs

**En curso**:
- (sin tarea activa al cierre de Sprint 0)

**Próximo**:
- Sprint 1: aplicar paleta UTA al theme elegido (junto a Imanol). Screenshots comparativos UTA real vs local.
- Sprint 3: templates Mustache del leaderboard relativo ±5 con highlight "TÚ" en dorado
- Sprint 4: UI de recompensas escalonadas (3 niveles)
- Sprint 6: video demo 3-5 min + slide deck 8-10 slides en PDF

**Recientemente cerrado**:
- (Edison todavía no abrió PRs propios; en Sprint 0 su rol fue mayormente standby)

**Archivos que está tocando**:
- (ninguno al cierre del día)

---

## 🚧 Ramas abiertas en remoto

> Verificar antes de borrar — algunas pueden tener trabajo en progreso.

| Rama | Owner | Estado | Acción sugerida |
|---|---|---|---|
| `main` | equipo | Trunk principal | — |
| `chore/sprint-0-alvaro-infra-qa` | Álvaro | Mergeada (PR #1) | Borrar |
| `chore/sprint-5-preview-alvaro` | Álvaro | Mergeada (PR #2) | Borrar |
| `chore/sprint-0-seeds-imanol` | Imanol | Mergeada (PR #3) | Borrar |
| `chore/ci-secret-scan-mdlint` | Álvaro | Mergeada y revertida (PR #4 → #5) | Borrar |
| `revert-4-chore/ci-secret-scan-mdlint` | Álvaro | Mergeada (PR #5) | Borrar |
| `chore/ci-mejoras-v2` | Álvaro | Mergeada (PR #7 según GitHub) | Borrar |
| `chore/sprint-0-refactor-generico` | Imanol | Mergeada (PR #6 según GitHub) | Borrar |
| `chore/dx-makefile-templates-vscode-status` | Álvaro | En curso (este PR) | Esperar merge |

---

## ⚠️ Alertas activas

> Cosas que el equipo debe saber antes de empezar trabajo nuevo.

- **2026-05-22**: El plugin se renombró de `local_rankingfisei` → `local_osyanificacion` (PR #6 de Imanol). Cualquier referencia vieja en docs/comentarios actualizarla.
- **2026-05-22**: `bitnami/moodle:4.3` ya no es pulleable sin Bitnami Secure. Usamos `bitnamilegacy/*` (ver `KNOWN_ISSUES.md` INFRA-001). Si alguien clona y le falla `docker compose up`, mirá ahí primero.

---

## 📅 Convención de updates

- **Edita tu sección** antes de empezar tarea grande (Sprint 1+)
- **`make status`** muestra este archivo desde la terminal
- **Commits a STATUS.md**: usar mensaje `chore(status): <qué cambia>` y pushear directo a main (excepción al PR flow)
- Si alguien edita STATUS.md al mismo tiempo que vos → resolver merge manualmente (es un md, fácil)
