<!--
Plantilla por defecto de PRs del proyecto Osyanificación.
Borrá los comentarios HTML y secciones que no apliquen a tu PR.
-->

## Resumen

<!-- 1-3 frases: qué cambia este PR y por qué. -->

## Cambios

<!-- Tabla o bullets con los archivos/áreas tocados. Ejemplo: -->

| Archivo | Cambio |
|---|---|
| `path/al/archivo` | Qué pasa |

## Por qué

<!-- Motivación. Si hay un issue, link. Si es por feedback, link al comentario. -->

## Cómo testearlo

<!-- Pasos concretos. El reviewer debería poder seguirlos sin contexto extra. -->

1. `git checkout <esta-rama>`
2. ...
3. Verificar que ...

## Auto-review

<!-- Marcá lo que aplique. Si no aplica, dejá la línea o borrala. -->

- [ ] Diff revisado en local antes de pedir review
- [ ] Conventional commit con scope correcto (ej. `feat(leaderboard):`, `chore(infra):`)
- [ ] Sin secretos en el repo (`.env` real está en `.gitignore`)
- [ ] No toqué áreas fuera de mi scope sin avisar
- [ ] CI verde (o explicación de qué falla y por qué)
- [ ] Docs actualizados si aplica (`docs/`, `README.md`, `KNOWN_ISSUES.md`)
- [ ] Tests agregados/actualizados si aplica (Sprint 3+)

## Tareas del plan cubiertas

<!-- Linkear a las tareas del plan Fase 1 (Obsidian) o número de issue interno -->

- [ ] #N — descripción

## Pendientes / notas para el reviewer

<!-- Cosas que dejaste fuera del PR intencionalmente, o dudas que querés que mire. -->

---

🤖 Generated with assistance from [Claude Code](https://claude.com/claude-code)
