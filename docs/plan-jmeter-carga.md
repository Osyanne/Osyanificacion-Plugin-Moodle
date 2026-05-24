# Plan Carga JMeter — Sprint 5

> Procedimiento operativo para correr **pruebas de carga con Apache
> JMeter** sobre el Moodle local + plugin Osyanificación en Sprint 5,
> validando los criterios de salida de Fase 1.
>
> **Estado**: documento de referencia, **NO ejecutado todavía**. Se
> activa en Sprint 5 (semana 8) cuando Imanol haya implementado el
> leaderboard ±5 y las recompensas escalonadas.
>
> **Pareja con**:
> [`docs/plan-a-cloudflare-tunnel.md`](plan-a-cloudflare-tunnel.md)
> y [`docs/plan-b-oracle-cloud.md`](plan-b-oracle-cloud.md) —
> completa la trilogía de docs Sprint 5.

## 📋 Tabla de contenidos

- [🎯 Objetivos y criterios de salida](#-objetivos-y-criterios-de-salida)
- [📦 Prerrequisitos](#-prerrequisitos)
- [1. Instalación de JMeter](#1-instalación-de-jmeter)
- [2. Escenarios de prueba](#2-escenarios-de-prueba)
- [3. Configuración del Thread Group](#3-configuración-del-thread-group)
- [4. Cómo correr el plan](#4-cómo-correr-el-plan)
- [5. Métricas a capturar](#5-métricas-a-capturar)
- [6. Plantilla de reporte para Imanol](#6-plantilla-de-reporte-para-imanol)
- [7. Plan de remediación si falla algún target](#7-plan-de-remediación-si-falla-algún-target)
- [8. Troubleshooting](#8-troubleshooting)
- [📚 Referencias](#-referencias)

---

## 🎯 Objetivos y criterios de salida

Según `docs/plan-fase-1.md` Sprint 5 (líneas 265-295) y criterios de
salida (líneas 410-441):

| Métrica | Target | Validación |
|---|---|---|
| **Usuarios concurrentes** | 50 sin crash | Thread Group 50 users, ramp-up 30s |
| **p95 response time** | < 500ms en queries del leaderboard | Aggregate Report de JMeter |
| **Error rate** | 0% | Listener: Summary Report |
| **Throughput** | ≥ 10 req/sec sostenido | Aggregate Report |
| **Cobertura** | endpoints críticos del flow estudiante | Ver sección 2 |

Si alguna de estas falla → ver sección 7 (plan de remediación).

## 📦 Prerrequisitos

| Item | Para qué |
|---|---|
| Stack levantado (`make up`) | JMeter golpea Moodle local en `localhost:8080` |
| **Plugin `osyanificacion` instalado y configurado** | Sprint 2-4 ya completados |
| Seeds con **al menos 30 estudiantes con XP variado** | Probar leaderboard ±5 con cohorte grande |
| Curso ALG-DEMO con `neighbours=5` en `block_xp_config` | Validar el filtro relativo |
| JMeter 5.6+ | Tool del benchmark (free, open source) |
| Java 11+ | Requisito de JMeter |
| ~2 GB RAM libre | JMeter es Java, necesita aire |
| ~30 min para el primer run + análisis | Test no es bloqueante |

## 1. Instalación de JMeter

### Windows (recomendado: winget)

```powershell
winget install Apache.JMeter
```

O descargar manual: https://jmeter.apache.org/download_jmeter.cgi
(elegir `apache-jmeter-X.Y.Z.zip`, descomprimir en `C:\jmeter\`).

### Linux

```bash
sudo apt update
sudo apt install openjdk-11-jre-headless
wget https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz
sudo mv apache-jmeter-5.6.3 /opt/jmeter
echo 'export PATH=$PATH:/opt/jmeter/bin' >> ~/.bashrc
source ~/.bashrc
```

### macOS

```bash
brew install jmeter
```

### Verificar

```bash
jmeter --version
# Apache JMeter 5.6.3 (esperado)
```

## 2. Escenarios de prueba

5 escenarios que simulan el flujo típico de un estudiante. Cada
"thread" de JMeter ejecuta los 5 en secuencia con think time entre
ellos (simula tiempo de lectura humano).

### Escenario 1 — Login

| HTTP | Method | URL | Body / Params |
|---|---|---|---|
| `GET` | login form | `/login/index.php` | Capturar token CSRF del HTML |
| `POST` | login submit | `/login/index.php` | `username=estudiante{N}` + `password=Estudiante{N}.demo` + `logintoken={token}` |

**Validación**: response 302 (redirect a Dashboard) o 200 con cookie
`MoodleSession` seteada.

**Think time**: 2 segundos después.

### Escenario 2 — Dashboard

| HTTP | Method | URL |
|---|---|---|
| `GET` | dashboard | `/my/` |

**Validación**: response 200 + contiene el texto `(SOF) Algoritmos`
(confirma que ve sus cursos).

**Think time**: 3 segundos (el usuario escanea sus cursos).

### Escenario 3 — Ver bloque XP en el curso

| HTTP | Method | URL |
|---|---|---|
| `GET` | curso ALG-DEMO | `/course/view.php?id=2` |

**Validación**: response 200 + contiene el bloque `block_xp` rendered
(grep por `xp-widget` o `osy-xp-widget`).

**Métrica crítica**: este endpoint dispara la query del leaderboard
±5. Es el que tiene que estar p95 < 500ms.

**Think time**: 5 segundos.

### Escenario 4 — Abrir una actividad

| HTTP | Method | URL |
|---|---|---|
| `GET` | tarea Tema 1 | `/mod/assign/view.php?id={cmid}` |

**Validación**: response 200. **Bonus**: trigger XP award via event
`mod_assign_course_module_viewed` (Sprint 3+ confirma esto).

**Think time**: 4 segundos.

### Escenario 5 — Ver leaderboard completo

| HTTP | Method | URL |
|---|---|---|
| `GET` | ladder full | `/blocks/xp/index.php?courseid=2` |

**Validación**: response 200 (con sesión autenticada — sin auth
devolvió 404 en el smoke test E2E).

**Métrica crítica**: este endpoint hace `SELECT * FROM mdl_block_xp
WHERE courseid=2 ORDER BY xp DESC` + ranking. Stress real al motor de
ranking.

**Think time**: 3 segundos.

## 3. Configuración del Thread Group

| Parámetro | Valor | Razón |
|---|---|---|
| **Number of Threads (users)** | 50 | Match con criterio de salida del plan |
| **Ramp-up Period (seconds)** | 30 | Llegar gradualmente a 50 users en 30s (~1.67 users/seg) |
| **Loop Count** | 10 | Cada user hace los 5 escenarios 10 veces = 500 ciclos |
| **Total requests** | 50 × 5 × 10 = **2500** | Volumen suficiente para p95 estadísticamente confiable |
| **Duration estimada** | ~10 min | Con think times incluidos |

### Configuración de Users vs Cyclic

Los 50 users deben corresponder a 50 estudiantes seedeados. Como hoy
solo tenemos 5 (`estudiante01..05`), Sprint 5 va a requerir generar
**al menos 30 estudiantes adicionales** (idealmente 50+) antes de
correr JMeter.

Posibles approaches:

1. **Script CLI** (recomendado) que genere usuarios, matriculaciones
   y XP variado vía Moodle API. Sprint 3+ trabajo, pero referenciado
   en este plan.
2. **SQL directo** (rápido pero menos limpio) que inserte filas en
   `mdl_user`, `mdl_user_enrolments`, `mdl_block_xp`.

## 4. Cómo correr el plan

### Paso 4.1 — Crear el `.jmx` (plan de prueba)

Estructura sugerida:

```
Test Plan
├── HTTP Request Defaults (server: localhost, port: 8080, protocol: http)
├── HTTP Cookie Manager (Clear cookies each iteration: false)
├── CSV Data Set Config (estudiantes.csv → username, password)
│
├── Thread Group "Estudiantes Concurrentes"
│   ├── HTTP Request — Login GET (extrae logintoken)
│   ├── HTTP Request — Login POST
│   ├── HTTP Request — Dashboard
│   ├── HTTP Request — Curso ALG-DEMO
│   ├── HTTP Request — Abrir actividad
│   ├── HTTP Request — Ladder
│   ├── Constant Timer (1-5s) entre requests
│   └── Listeners:
│       ├── Aggregate Report
│       ├── Summary Report
│       └── View Results Tree (solo dev; deshabilitar en run real)
```

### Paso 4.2 — Crear `estudiantes.csv`

```csv
username,password
estudiante01,Estudiante01.demo
estudiante02,Estudiante02.demo
estudiante03,Estudiante03.demo
...
estudiante50,Estudiante50.demo
```

(50 filas cuando Sprint 5 ya tenga los seeds extendidos.)

### Paso 4.3 — Run modo CLI (no GUI, mejor performance)

```bash
jmeter -n -t plan.jmx -l results.jtl -e -o report/
```

| Flag | Para qué |
|---|---|
| `-n` | Non-GUI mode (más rápido, menos memoria) |
| `-t plan.jmx` | Test plan a ejecutar |
| `-l results.jtl` | Output raw de resultados (CSV-ish) |
| `-e -o report/` | Genera reporte HTML al final en `report/` |

### Paso 4.4 — Abrir el reporte

```bash
# Linux/Mac
xdg-open report/index.html

# Windows
start report/index.html
```

El reporte HTML tiene gráficos de:
- Throughput por segundo
- Response times por percentil (p50, p90, **p95**, p99)
- Error rate por endpoint
- Latency vs duration

## 5. Métricas a capturar

### Métricas obligatorias (para reporte a Imanol)

| Métrica | Cómo se obtiene en JMeter | Target |
|---|---|---|
| **Throughput sostenido** | Aggregate Report → columna `Throughput` | ≥ 10 req/sec |
| **p95 response time** | Aggregate Report → columna `95% Line` | < 500ms |
| **p99 response time** | Aggregate Report → columna `99% Line` | < 1000ms |
| **Error rate global** | Summary Report → columna `Error %` | 0% |
| **Tasa de crashes 500** | Filtrar response code en JTL | 0 |

### Métricas por endpoint (granular)

Aggregate Report te da una fila por cada HTTP Request en el plan.
Capturar específicamente:

- `GET /course/view.php?id=2` (renderiza bloque XP — query leaderboard)
- `GET /blocks/xp/index.php?courseid=2` (ladder completo)

Esas son las dos que cargan más BD y son las que tienen que
mantenerse bajo p95 < 500ms.

### Métricas del lado server (Moodle/MariaDB)

Mientras JMeter corre, capturar en paralelo:

```bash
# CPU y memoria del container Moodle
docker stats osyanificacion-moodle --no-stream

# Slow queries de MariaDB
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SHOW PROCESSLIST;" | head -20'

# Conexiones activas
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SHOW STATUS LIKE '"'"'Threads_connected'"'"';"'
```

## 6. Plantilla de reporte para Imanol

Crear `presentation/jmeter-runs/run-YYYYMMDD-HHMM/` con:

```
run-20260801-1500/
├── plan.jmx                   ← copia del plan ejecutado
├── results.jtl                ← raw output JMeter
├── report/                    ← reporte HTML auto-generado
│   └── index.html
├── docker-stats.log           ← CPU/RAM del Moodle durante el run
├── slow-queries.log           ← Queries lentas de MariaDB
└── REPORT.md                  ← este resumen, ver plantilla abajo
```

### Plantilla `REPORT.md`

```markdown
# JMeter run YYYY-MM-DD HH:MM

**Ejecutado por**: Álvaro
**Fecha**: 2026-XX-XX
**Duración**: ~10 min
**Moodle commit**: [SHA del main al momento del run]
**Plugin osyanificacion versión**: [release del plugin]
**Estado del stack**: 50 estudiantes seedeados, neighbours=5, ALG-DEMO con N actividades

## Resultados vs targets

| Métrica | Target | Resultado | ✅/❌ |
|---|---|---|---|
| Usuarios concurrentes sin crash | 50 | XX | |
| p95 response time | < 500ms | XX ms | |
| p99 response time | < 1000ms | XX ms | |
| Error rate global | 0% | XX% | |
| Throughput sostenido | ≥ 10 req/s | XX req/s | |

## Endpoints más lentos

| Endpoint | p95 | p99 | Throughput |
|---|---|---|---|
| `GET /course/view.php?id=2` | XX | XX | XX |
| `GET /blocks/xp/index.php?courseid=2` | XX | XX | XX |

## Errores encontrados

(Si hay, listar acá con HTTP code, frecuencia, hipótesis de causa.)

## Recomendaciones

(Tomar referencia de la sección 7 si algo falló.)
```

## 7. Plan de remediación si falla algún target

### Caso A — p95 > 500ms en `/course/view.php`

**Causa probable**: query del leaderboard sin índice apropiado.

**Fix**:

```sql
-- Verificar índices actuales
SHOW INDEX FROM mdl_block_xp;

-- Si falta el índice compuesto:
CREATE INDEX idx_xp_course_xp_desc
ON mdl_block_xp (courseid, xp DESC);
```

Re-correr el test. Si sigue > 500ms, evaluar caching del bloque XP
con `cachestore_file` por 5 min (`config.php` o Moodle settings UI).

### Caso B — Error rate > 0%

**Causa probable**: timeout PHP o memoria insuficiente bajo carga.

**Fix**:

1. Aumentar `memory_limit` PHP en `php.ini` del container Bitnami:
   ```bash
   docker compose exec moodle sh -c \
     'echo "memory_limit = 256M" >> /opt/bitnami/php/etc/php.ini'
   docker compose restart moodle
   ```
2. Habilitar **opcache PHP** si no está (debería estar en Bitnami):
   ```ini
   opcache.enable = 1
   opcache.memory_consumption = 128
   opcache.max_accelerated_files = 10000
   ```
3. Aumentar pool MariaDB:
   ```bash
   docker compose exec mariadb sh -c \
     'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" \
      -e "SET GLOBAL max_connections = 200;"'
   ```

### Caso C — Throughput < 10 req/s

**Causa probable**: bottleneck en CPU del container o disk I/O.

**Fix**:

1. Aumentar recursos asignados a Docker Desktop (Settings → Resources)
2. Verificar que `moodledata` esté en SSD (no HDD)
3. Si persiste, evaluar moverlo a Plan B Oracle Cloud (ARM Ampere
   tiene 4 OCPU dedicadas)

### Caso D — Crashes / restarts del container

**Causa probable**: OOM (Out of Memory) o segfault.

**Fix**:

```bash
# Ver últimos eventos del container
docker compose events --until 10m

# Ver logs justo antes del crash
docker compose logs --since 10m moodle

# Aumentar memoria del container en docker-compose.yml:
services:
  moodle:
    deploy:
      resources:
        limits:
          memory: 2G
```

## 8. Troubleshooting

### JMeter no captura el `logintoken` del HTML

Moodle 4.x usa `logintoken` como CSRF. Para capturarlo en JMeter:

1. Después del GET de `/login/index.php`, agregar un
   **Regular Expression Extractor**
2. Expression: `name="logintoken" value="(.+?)"`
3. Reference Name: `logintoken`
4. Usarlo en el POST como `${logintoken}`

### Cookies no se mantienen entre requests del mismo thread

Asegurar que el **HTTP Cookie Manager** esté antes del Thread Group
(no dentro). Y que tenga `Clear cookies each iteration: false` para
que la sesión persista entre las N iteraciones del mismo user.

### El test corre rápido pero responses son todas 200 vacías

JMeter sigue los redirects 302 por default. Si querés ver el final
real, agregar un **Response Assertion** que valide el contenido (ej.
`Contains: ALG-DEMO`).

### Cómo correr contra el tunnel Cloudflare en lugar de localhost

Reemplazar el HTTP Request Defaults:
- Server: `demo.osyanificacion.online`
- Port: `443`
- Protocol: `https`

Pero **no recomendado para benchmarking** — la latencia del tunnel
agrega ruido. Mejor JMeter contra localhost directo + capturar
métricas server-side.

## 📚 Referencias

- [Apache JMeter docs oficiales](https://jmeter.apache.org/usermanual/)
- [JMeter Best Practices](https://jmeter.apache.org/usermanual/best-practices.html)
- [Moodle performance tuning](https://docs.moodle.org/403/en/Performance)
- [MariaDB query optimization](https://mariadb.com/kb/en/optimization-and-tuning/)
- [`docs/plan-fase-1.md`](plan-fase-1.md) — roadmap Sprint 5
- [`docs/level-up-xp-deep-dive.md`](level-up-xp-deep-dive.md) — esquema del plugin
- [`docs/smoke-test-e2e.md`](smoke-test-e2e.md) — baseline previa
- [`docs/plan-a-cloudflare-tunnel.md`](plan-a-cloudflare-tunnel.md) — exposición pública
- [`docs/plan-b-oracle-cloud.md`](plan-b-oracle-cloud.md) — fallback de exposición

## ⚠️ Notas del autor

- Este doc es **referencia operativa**, no ejecutado todavía.
  Se ejecuta en Sprint 5 (semana 8) cuando el plugin esté implementado.
- Los **targets** salen del plan oficial (`docs/plan-fase-1.md`
  líneas 420-423). Si Imanol decide ajustarlos, este doc se actualiza.
- Los **escenarios** son propuesta basada en el flujo de estudiante
  típico. Si Sprint 3-4 agregan endpoints clave (ej. recompensas
  escalonadas), agregarlos como escenarios 6+.
- Cualquier desviación al ejecutar → actualizar este doc + entrada
  en `KNOWN_ISSUES.md` con formato `INFRA-XXX`.
