# Guía de contribución — Osyanificación Plugin

> Esta guía es para el equipo interno (Imanol, Álvaro, Edison). Una vez
> que el proyecto se haga público en Fase 2, se ampliará para
> contribuyentes externos.

## 🎯 Filosofía

- ✅ **Commits chicos y frecuentes** > commits gigantes
- ✅ **PRs enfocados** (1 PR = 1 feature/fix/refactor)
- ✅ **Tests antes de aprobar** (Sprint 3+)
- ✅ **Communication > silencio** (preguntar > asumir)

## 👥 Jerarquía del equipo

- **Imanol** = Director del Proyecto + Lead Técnico 
- **Álvaro** = Colaborador Infra & QA 
- **Edison** = Colaborador UI/UX & Docs

Decisiones técnicas mayores se discuten antes

## 🌳 Branch strategy: GitHub Flow

```
main (protegida, siempre desplegable)
  ↑
  └── feature/<descripcion-corta>     ← nuevas features
  └── fix/<descripcion-corta>          ← bug fixes
  └── docs/<descripcion-corta>         ← solo documentación
  └── refactor/<descripcion-corta>     ← refactors sin cambio de comportamiento
  └── chore/<descripcion-corta>        ← tooling, CI, deps
```

**Ejemplo**:
```bash
git checkout main
git pull
git checkout -b feature/leaderboard-relativo
# ... trabajar ...
git add .
git commit -m "feat(leaderboard): query relativo +/-5 con RANK()"
git push -u origin feature/leaderboard-relativo
# Abrir PR en GitHub
```

## ✍️ Convención de commits

Usamos **Conventional Commits** con prefijo de scope:

```
<tipo>(<scope>): <descripcion corta en minuscula>

<cuerpo opcional explicando POR QUE, no que>

<footer opcional con BREAKING CHANGE, Closes #N, etc.>
```

**Tipos válidos**:
- `feat` — nueva funcionalidad
- `fix` — bug fix
- `docs` — solo documentación
- `style` — formato (no afecta lógica)
- `refactor` — cambio que no es fix ni feature
- `test` — agregar/modificar tests
- `chore` — tooling, deps, CI

**Scopes válidos** (según área del plugin):
- `leaderboard` — todo lo relacionado al ranking
- `rewards` — recompensas escalonadas
- `ui` — templates Mustache, estilos
- `db` — esquema, migrations
- `infra` — Docker, Cloudflare Tunnel
- `ci` — GitHub Actions
- `docs` — documentación
- `tests` — tests específicos

**Ejemplos**:
```
feat(leaderboard): toggle absoluto vs relativo en config del bloque
fix(rewards): no otorgar duplicado al cruzar threshold dos veces
docs(readme): agregar quick start de Docker
chore(ci): subir cobertura mínima a 70%
refactor(db): renombrar tabla rewards → reward_definitions
test(leaderboard): caso borde con 1 usuario
```

## 🔍 Code reviews

### Para autores del PR
- ✅ Auto-review antes de pedir revisión (mirate tu propio diff)
- ✅ Descripción del PR con: qué cambia, por qué, cómo testearlo
- ✅ Linkear al issue/tarea si existe
- ✅ Marcar como "Draft" si no está listo aún

### Para reviewers
- ✅ Asumir buena intención del autor
- ✅ Comentarios constructivos (preguntar antes de afirmar)
  - ❌ "Esto está mal"
  - ✅ "¿Por qué usás `array_filter` acá en lugar de `foreach`? Si es
    por legibilidad, perfecto; si es por performance, tengo dudas
    porque..."
- ✅ Diferenciar entre **blockers** (bugs, security, scope creep) y
  **nice-to-have** (estilo, micro-optimizaciones)
- ✅ Aprobar cuando esté bien — no nitpickear sin fin

### Reglas de aprobación

- **PRs de Álvaro o Edison** → requieren aprobación de **Imanol** antes de mergear
- **PRs de Imanol** → pueden tener feedback de Álvaro/Edison pero Imanol
  tiene autoridad para mergear si urge
- **Cualquier PR** → CI verde (tests + linter) es requisito mínimo

## 🚨 Cuándo escalar

Si te bloqueás **más de 24h** sin avanzar:
1. **Escalá a Imanol** vía WhatsApp/Discord (no aguantes solo)
2. Pegale: qué intentaste, qué error obtenés, qué pensás que puede ser
3. Imanol decide: pair programming, reasignación, o ayuda externa

No es debilidad pedir ayuda — es eficiencia.

## 💬 Comunicación del equipo

- **Daily async** vía WhatsApp/Discord: cada uno reporta
  - Qué hizo ayer
  - Qué planea hacer hoy
  - Bloqueadores (si hay)
- **Weekly sync** de 1h (día por decidir, ej. viernes) liderada por Imanol
  - Review del sprint en curso
  - Ajuste de tareas si hace falta
  - Planeación del siguiente sprint

## 🧪 Tests

A partir de **Sprint 3**, cualquier PR con código de negocio debe traer
tests. Cobertura objetivo: **≥ 70%** en lógica de negocio.

- **PHPUnit** para tests unitarios y de integración
- **Behat** para E2E (críticos solamente)
- CI corre tests automáticamente en cada PR

## 📝 Documentación

- Cualquier feature nueva → actualizar `docs/` correspondiente
- Cualquier decisión arquitectónica importante → registrar en
  `docs/architecture.md`
- Bugs conocidos → `KNOWN_ISSUES.md` con workaround

## 🔐 Seguridad

- **NUNCA** commitear credenciales, tokens, `.env` con secrets reales
- **NUNCA** desactivar el `.gitignore` para "subir solo esta vez"
- Si por error commiteás un secret: avisá a Imanol inmediatamente y
  rotamos credenciales

## 🤝 Código de conducta

- Respeto siempre. Discusión técnica > ataque personal.
- Las decisiones se justifican técnicamente, no por jerarquía
- Pero cuando hay desacuerdo persistente, Imanol como director decide
  y se respeta

¡Que arranque Sprint 0! 🎮
