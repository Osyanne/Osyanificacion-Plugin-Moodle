# Osyanificacion-Plugin-Moodle

> Plugin de Moodle 4.x para **gamificación y ranking académico** en la
> Facultad de Ingeniería en Sistemas, Electrónica e Industrial (FISEI) de
> la Universidad Técnica de Ambato (UTA).

## 🎯 ¿Qué hace?

Sistema de Ranking Académico y Gamificación basado en la arquitectura
**PBL+F (Points, Badges, Leaderboards + Feedback)**. Construye sobre
**Level Up XP** y agrega dos diferenciadores clave validados por
literatura científica:

1. **Leaderboards relativos ±5 posiciones** — evita los efectos
   desmotivadores documentados de rankings absolutos (Hanus & Fox 2015)
2. **Recompensas institucionales escalonadas en 3 niveles** — más allá
   de badges digitales: certificados, menciones del consejo, vinculación
   con empresas

## 📌 Estado del proyecto

**Fase actual**: Fase 1 — Validación Técnica (LOCAL) · Sprint 0 (setup)

Roadmap completo en el documento académico principal del proyecto y en
la nota de Obsidian del equipo (`12-Plan-Fase-1-Local.md`).

### Plan en 3 fases

1. **Fase 1 — Validación Técnica (LOCAL)** ← AHORA
   - 8-10 semanas, Docker local + Cloudflare Tunnel
   - Plugin funcional + tests + video demo
   - Universo de prueba: equipo + 5 cuentas dummy
2. **Fase 2 — Piloto Empírico** (institución externa)
   - 12-24 semanas, estudiantes voluntarios reales
   - Diseño cuasiexperimental, Hedges g ≥ 0.5 target
3. **Fase 3 — Aplicación Institucional UTA** (largo plazo)
   - Reintento con DEaDV con evidencia acumulada

## 🛠️ Stack técnico

- **Plataforma**: Moodle 4.3 LTS (o 4.5)
- **Lenguaje**: PHP 8.1+
- **DB**: MariaDB 10.11
- **Templates**: Mustache
- **Charts**: Chart.js 4.x
- **Tests**: PHPUnit + Behat
- **Infra dev**: Docker + Cloudflare Tunnel ($0 costo)
- **Base del plugin**: fork wrapper de
  [Level Up XP](https://github.com/FMCorz/moodle-block_xp) (GPL v3)

## 🚀 Quick start

> ⚠️ **Sprint 0 en curso** — el `docker-compose.yml` y los plugins se
> agregarán durante el Sprint 0. Por ahora el repo es esqueleto.

Setup completo se documentará en `docs/deployment.md` antes de cerrar
Sprint 1.

## 👥 Equipo

| Rol | Persona | Responsabilidades |
|---|---|---|
| **Director del Proyecto + Lead Técnico** | Alan Imanol Miranda Garcés ([@Osyanne](https://github.com/Osyanne)) | Arquitectura, PHP core, code reviews, coordinación |
| **Colaborador Infra & QA** | Álvaro López ([@alvarolopezmoya](https://github.com/alvarolopezmoya)) | Docker, Cloudflare Tunnel, JMeter, CI/CD, tests |
| **Colaborador UI/UX & Docs** | Edison Landeta ([@Edison206](https://github.com/Edison206)) | Mustache templates, Chart.js, README, video demo, slides |

Universidad Técnica de Ambato (UTA) · Facultad FISEI · Carrera de
Ingeniería en Software · Sem. 2 — Sec. B · Materia: Metodología de la
Investigación · Período Enero-Julio 2026.

## 📜 Licencia

**GPL v3** — heredada del proyecto base
[Level Up XP](https://github.com/FMCorz/moodle-block_xp) de Frédéric
Massart (core developer de Moodle).

## 🙏 Créditos

- **Frédéric Massart** y la comunidad de Level Up XP (27.000+ sitios
  Moodle, certificado GDPR)
- **Pimenko** (theme Moove) y **Davo Smith** (format Tiles) — stack que
  emulamos en el entorno local para replicar UTA
- **Universidad Técnica de Ambato** y la cultura FISEI que motiva este
  proyecto

## 🤝 Cómo contribuir

Ver [`CONTRIBUTING.md`](./CONTRIBUTING.md) para guía del equipo.

## 📚 Documentación

- `docs/architecture.md` — Sprint 2
- `docs/deployment.md` — Sprint 5
- `docs/user-guide.md` — Sprint 6
- `docs/api-reference.md` — Sprint 6
- `docs/research-context.md` — Sprint 6

## ⚠️ Issues conocidos

Ver [`KNOWN_ISSUES.md`](./KNOWN_ISSUES.md).
