# Status board del equipo

> 🎯 **Propósito**: que los 3 integrantes sepan qué hace cada uno **en
> vivo**, evitando duplicar trabajo o pisar archivos. Actualizar al
> empezar una tarea importante y al cerrar el día.

> **Cómo usar**: edita tu sección, commit con mensaje
> `chore(status): <tu update>` y push directo a `main` (cambios chicos
> de STATUS.md están exentos del flujo de PR — son metadata, no código).

**Última actualización**: 2026-06-01

---

## 🎯 Imanol Miranda — Director + Lead Técnico

**En curso**:
- Cierre de documentación del repo (README/STATUS/seeds al día tras Sprint 2)

**Próximo**:
- **Sprint 3**: arrancar el desarrollo del plugin `local_osyanificacion`:
  - Aplicar el template UTA al leaderboard ±5 nativo (ya está el `.mustache` en el repo)
  - Construir el **nickname elegido por el alumno** (tabla propia + override de
    `anonymise_rank()` vía DI container — esfuerzo S-M, ver `docs/architecture.md`)
- **Sprint 4**: recompensas escalonadas (observer del evento `user_leveledup`)

**Recientemente cerrado**:
- ✅ **Sprint 2 — Verificación de capacidades nativas** (PR #22). Entregable:
  `docs/architecture.md` con data flow del upstream + 3 veredictos verificados en
  vivo + matriz de decisión. Hallazgo clave: el **±5 es nativo** → ahorra el Sprint 3
  original. Seed reutilizable `seeds/sprint2-seed-xp.php` (30 estudiantes vía API Moodle).
- ✅ **Paleta UTA `#233A83` aplicada y consolidada** (PR #20): mockups + template
  Mustache + doc de prep, todo en azul institucional. El pivot a B&N quedó descartado.
- ✅ Sprint 1 visual cerrado (réplica UTA en mockups + paleta en theme Boost).

**Archivos que está tocando (no mergees PRs que los modifiquen sin avisar)**:
- (ninguno — Sprint 2 cerrado y documentación al día)

---

## 🛠️ Álvaro López — Infra & QA

**En curso**:
- Standby. Disponible para code reviews y smoke tests.

**Próximo**:
- **Sprint 3**: descomentar el job `moodle-plugin-ci` en `.github/workflows/ci.yml`
  cuando exista `code/local/osyanificacion/version.php` y el primer test PHPUnit.
- **Sprint 5**: Cloudflare Tunnel + JMeter (50 users, p95 < 500ms). Plan en
  `docs/plan-jmeter-carga.md`. Nota: el ladder con `neighbours=5` devuelve menos
  filas que el completo → debería ser más rápido, validar empíricamente.
- **Sprint 6**: métricas de estabilidad para README + slides.

**Recientemente cerrado (Sprint 0 + adelantos)**:
- ✅ Stack Docker (`docker-compose.yml`), bug INFRA-001 (`bitnamilegacy/*`), deployment.
- ✅ Mejoras CI: secret-scan (gitleaks) + markdown-lint + json-validate.
- ✅ Docs de infra: Cloudflare Tunnel, Oracle Cloud, JMeter, operación CLI (INFRA-002).
- ✅ Combo DX: Makefile + GitHub templates + `.vscode/`.

**Archivos que está tocando**:
- (ninguno)

---

## 🎨 Edison Landeta — UI/UX & Docs

**En curso**:
- Standby tras el cierre del trabajo visual.

**Próximo**:
- **Sprint 3**: ajustes finos del template del leaderboard ±5 (paleta UTA ya aplicada;
  el highlight "TÚ" nativo es amarillo, se lleva al dorado UTA vía CSS).
- **Sprint 4**: UI de recompensas escalonadas (3 niveles).
- **Sprint 6**: video demo 3-5 min (OBS) + slide deck en PDF.

**Recientemente cerrado**:
- ✅ Mockups de réplica UTA (`presentation/mockups/`) y aplicación de la paleta UTA
  al theme Boost (contribuyó a la consolidación del PR #20).

**Archivos que está tocando**:
- (ninguno)

---

## 🚧 Ramas abiertas en remoto

| Rama | Owner | Estado | Acción sugerida |
|---|---|---|---|
| `main` | equipo | Trunk principal, al día (Sprint 2 cerrado) | — |

> Todas las ramas de trabajo se mergean y borran tras su PR. `main` está protegida
> (branch protection + CODEOWNERS = @Osyanne; todo PR requiere review del Director).

---

## ⚠️ Alertas activas

> Cosas que el equipo debe saber antes de empezar trabajo nuevo.

- **Paleta oficial = UTA azul `#233A83`** (decisión final). El pivot a "Santo Domingo
  de Guzmán" B&N quedó descartado. Variables `--uta-*`, acento dorado `#F59E0B` solo
  para el highlight "TÚ". Theme de referencia: `docs/uta-boost-scss.css`.
- **El leaderboard ±5 es NATIVO** (campo `neighbours` de Level Up XP), verificado en
  Sprint 2. NO reimplementar desde cero. Ver `docs/architecture.md`.
- **Wrappeo, no fork**: `local_osyanificacion` extiende Level Up XP vía DI container +
  override de templates. No se modifica el código del plugin base.
- **INFRA-001**: `bitnami/moodle:4.3` no es pulleable sin Bitnami Secure → usamos
  `bitnamilegacy/*` (ver `KNOWN_ISSUES.md`).
- **INFRA-002**: nunca correr `php` como root en el container. Usar
  `docker compose exec -u daemon moodle sh -c '...'` (ver `docs/operacion-cli-moodle.md`).
- **Seeds**: para verificación rápida hay `seeds/sprint2-seed-xp.php` (30 estudiantes
  con XP variado vía API Moodle). El flujo manual de 5 cuentas sigue en `seeds/README.md`.

---

## 📅 Convención de updates

- **Edita tu sección** antes de empezar tarea grande (Sprint 3+)
- **`make status`** muestra este archivo desde la terminal (o `cat STATUS.md`)
- **Commits a STATUS.md**: usar mensaje `chore(status): <qué cambia>` y pushear directo
  a main (excepción al PR flow)
- Si alguien edita STATUS.md al mismo tiempo que vos → resolver merge manualmente
