# Osyanificacion-Plugin-Moodle

> Plugin de Moodle 4.x para **gamificación y ranking académico** en
> entornos universitarios. Plugin genérico, instalable en cualquier
> Moodle 4.x institucional. Caso de uso original: FISEI-UTA (ver
> sección [Origen del proyecto](#-origen-del-proyecto)).

## 🎯 ¿Qué hace?

Sistema de Ranking Académico y Gamificación basado en la arquitectura
**PBL+F (Points, Badges, Leaderboards + Feedback)**. Construye sobre
**Level Up XP** y agrega diferenciadores clave validados por
literatura científica:

1. **Leaderboards relativos ±5 posiciones** — evita los efectos
   desmotivadores documentados de rankings absolutos (Hanus & Fox 2015).
   *Disponible nativo en Level Up XP* (config `neighbours`), con la paleta
   institucional UTA aplicada vía template.
2. **Anonimato opcional vía nickname elegido por el alumno** — el estudiante
   decide con qué alias aparece en el ranking (el plugin base solo ofrece
   "nombre real" o "anónimo genérico").
3. **Recompensas institucionales escalonadas en 3 niveles** — más allá
   de badges digitales: certificados, menciones del consejo, vinculación
   con empresas.

## 📌 Estado del proyecto

**Fase actual**: Fase 1 — Validación Técnica (LOCAL) · **Sprint 2 cerrado**
(verificación de capacidades nativas).

Hallazgo clave del Sprint 2 (ver [`docs/architecture.md`](./docs/architecture.md)):
el **leaderboard relativo ±5 ya es nativo** en Level Up XP (campo `neighbours`),
verificado en vivo con 30 estudiantes. El esfuerzo se redirige a los dos
diferenciadores que el plugin base NO cubre: **nickname elegido por el alumno** y
**recompensas escalonadas**.

Roadmap completo en [`docs/plan-fase-1.md`](./docs/plan-fase-1.md).

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
- **Base del plugin**: **wrapper** de
  [Level Up XP](https://github.com/FMCorz/moodle-block_xp) (GPL v3) — extiende vía
  DI container + override de templates, sin forkear ni modificar el core upstream

## 🚀 Quick start

### Prerequisitos

- **Docker Desktop** instalado y corriendo (Windows/Mac/Linux)
- **Git** instalado
- ~3 GB de RAM disponibles
- Puerto 8080 y 8025 libres en tu máquina

### Setup local en 5 pasos

```bash
# 1. Clonar el repo
git clone https://github.com/Osyanne/Osyanificacion-Plugin-Moodle.git
cd Osyanificacion-Plugin-Moodle

# 2. Copiar variables de entorno y editar passwords
cp .env.example .env
# Editar .env y cambiar TODAS las contraseñas que dicen CAMBIAME_

# 3. Asegurarse que Docker Desktop está corriendo
docker info  # debe responder sin error

# 4. Levantar el stack (primera vez tarda ~3-5 min)
docker compose up -d

# 5. Ver logs hasta que Moodle termine de inicializar
docker compose logs -f moodle
# Esperar mensaje: "moodle 09:XX:XX ** Starting Moodle **"
# Ctrl+C para salir del log (sigue corriendo en background)
```

### Acceder a los servicios

| Servicio | URL | Credenciales |
|---|---|---|
| **Moodle** | http://localhost:8080 | `MOODLE_USERNAME` / `MOODLE_PASSWORD` del `.env` |
| **Mailhog** (emails capturados) | http://localhost:8025 | Sin auth |

### Comandos útiles

```bash
docker compose ps                # Ver estado de servicios
docker compose logs -f moodle    # Ver logs de Moodle en tiempo real
docker compose restart moodle    # Reiniciar solo Moodle
docker compose exec moodle bash  # Entrar al container Moodle
docker compose down              # Apagar todo (preserva datos)
docker compose down -v           # ⚠️ Apagar y BORRAR todos los datos
```

> 💡 Hay atajos en el `Makefile` (`make up`, `make logs`, `make exec CMD='...'`)
> si tenés `make` instalado. Para correr comandos PHP/CLI dentro del container de
> forma segura, ver [`docs/operacion-cli-moodle.md`](./docs/operacion-cli-moodle.md).

### Resolver problemas comunes

**"Cannot connect to the Docker daemon"** → Docker Desktop no está corriendo. Abrilo desde el menú Inicio.

**Moodle tarda mucho la primera vez** → Es normal, Bitnami inicializa BD + admin user. Esperá 5 min. Si pasaron 10 min, mirá `docker compose logs moodle`.

**Puerto 8080 ocupado** → Cambialo en `docker-compose.yml` (ej. `"8090:8080"`).

**Quiero empezar de cero** → `docker compose down -v` y volvé al paso 4.

### Plugins del proyecto (Sprint 3+)

El `docker-compose.yml` tiene comentados los bind mounts para los plugins propios
(`code/local/osyanificacion/`). Cuando arranque el desarrollo del plugin (Sprint 3),
se descomentan para montar el código en el container. Level Up XP se instala desde
el directorio de plugins de Moodle (no se forkea — se wrappea, ver
[`docs/architecture.md`](./docs/architecture.md)).

## 👥 Equipo

| Rol | Persona | Responsabilidades |
|---|---|---|
| **Director del Proyecto + Lead Técnico** | Alan Imanol Miranda Garcés ([@Osyanne](https://github.com/Osyanne)) | Arquitectura, PHP core, code reviews, coordinación |
| **Colaborador Infra & QA** | Álvaro López ([@alvarolopezmoya](https://github.com/alvarolopezmoya)) | Docker, Cloudflare Tunnel, JMeter, CI/CD, tests |
| **Colaborador UI/UX & Docs** | Edison Landeta ([@Edison206](https://github.com/Edison206)) | Mustache templates, Chart.js, README, video demo, slides |

Equipo del proyecto académico que dio origen al plugin: Universidad
Técnica de Ambato (UTA) · Carrera de Ingeniería en Software · Materia:
Metodología de la Investigación · Período Enero-Julio 2026.

## 🌱 Origen del proyecto

El plugin nació como proyecto académico de investigación en la Facultad
de Ingeniería en Sistemas, Electrónica e Industrial (FISEI) de la
Universidad Técnica de Ambato (UTA), Ecuador. Sin embargo, **el plugin
en sí es genérico** y está pensado para instalarse en cualquier Moodle
4.x institucional.

Implementación escalonada en 3 fases (plan técnico detallado en [`docs/plan-fase-1.md`](./docs/plan-fase-1.md)):

1. **Fase 1 — Validación Técnica (local)**: desarrollo y testing en
   entorno controlado del equipo
2. **Fase 2 — Piloto Empírico (institución externa)**: ejecución del
   piloto con voluntarios en una institución que adopte el plugin
3. **Fase 3 — Aplicación Institucional UTA**: reintento de adopción
   institucional con evidencia acumulada de Fase 2

El diseño técnico (paleta neutral configurable, formato Tiles
opcional, agnóstico de carrera) refleja esta estrategia de
genericidad.

## 📜 Licencia

**GPL v3** — heredada del proyecto base
[Level Up XP](https://github.com/FMCorz/moodle-block_xp) de Frédéric
Massart (core developer de Moodle).

## 🙏 Créditos

- **Frédéric Massart** y la comunidad de Level Up XP (27.000+ sitios
  Moodle, certificado GDPR)
- **Pimenko** (theme Moove) y **Davo Smith** (format Tiles) — stack que
  emulamos en el entorno local de pruebas
- **Universidad Técnica de Ambato (UTA)** y la **Facultad FISEI** —
  contexto académico original que motivó el proyecto

## 🤝 Cómo contribuir

Ver [`CONTRIBUTING.md`](./CONTRIBUTING.md) para guía del equipo.

## 📚 Documentación

### Para arrancar (leer en orden)

- **[`docs/plan-fase-1.md`](./docs/plan-fase-1.md)** — 🆕 **Plan técnico completo de Fase 1 LOCAL**
  (8-10 semanas, 7 sprints, roles, criterios de salida, riesgos).
  **Lectura obligatoria para todo el equipo antes de tocar código.**
- **[`docs/benchmarking-level-up-xp.md`](./docs/benchmarking-level-up-xp.md)** — 🆕 Análisis del plugin base
  que estamos wrappeando. Explica por qué wrappeo en vez de fork modificado, y cuáles son los 4
  diferenciadores reales.
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — Jerarquía del equipo + GitHub Flow + Conventional Commits + code review rules
- [`KNOWN_ISSUES.md`](./KNOWN_ISSUES.md) — Bugs conocidos con workaround (INFRA-001, etc.)
- [`STATUS.md`](./STATUS.md) — Status board del equipo (qué está haciendo cada uno ahora mismo)

### Arquitectura + verificación

- [`docs/architecture.md`](./docs/architecture.md) — **Cómo wrappeamos Level Up XP**:
  data flow del plugin base, qué features son nativas vs a construir, y la matriz de
  decisión que guía Sprints 3-4 (entregable del Sprint 2).
- [`docs/level-up-xp-deep-dive.md`](./docs/level-up-xp-deep-dive.md) — Esquema de BD y
  estructura interna del plugin base.

### Deployment + infra

- [`docs/deployment.md`](./docs/deployment.md) — Cómo desplegar el stack Docker localmente
- [`docs/operacion-cli-moodle.md`](./docs/operacion-cli-moodle.md) — Correr comandos PHP/CLI dentro del container sin romper permisos (INFRA-002)
- [`docs/plan-a-cloudflare-tunnel.md`](./docs/plan-a-cloudflare-tunnel.md) — Exposición pública opción A (Cloudflare Tunnel, gratis)
- [`docs/plan-b-oracle-cloud.md`](./docs/plan-b-oracle-cloud.md) — Exposición pública opción B (Oracle Cloud Free Tier, gratis)

### Documentación que se completa en sprints futuros

- `docs/user-guide.md` — Sprint 6 (paso a paso para docentes y estudiantes)
- `docs/api-reference.md` — Sprint 6 (hooks, eventos, configuración)
- `docs/research-context.md` — Sprint 6 (marco teórico PBL+F + link al doc académico)

## ⚠️ Issues conocidos

Ver [`KNOWN_ISSUES.md`](./KNOWN_ISSUES.md).
