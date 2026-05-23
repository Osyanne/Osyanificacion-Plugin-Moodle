# Deployment Guide — Osyanificación Plugin Moodle

> Guía de despliegue del entorno local de desarrollo y de la futura
> exposición pública vía Cloudflare Tunnel.
>
> El **quick start básico** vive en el [`README.md`](../README.md#-quick-start) raíz.
> Este documento profundiza en **troubleshooting**, **operación día a día**
> y **deployment público** (Sprint 5).

## 📋 Tabla de contenidos

- [Entorno local con Docker](#-entorno-local-con-docker)
  - [Prerrequisitos](#prerrequisitos)
  - [Setup paso a paso](#setup-paso-a-paso)
  - [Verificación del stack](#verificación-del-stack)
- [Operación día a día](#-operación-día-a-día)
  - [Comandos útiles](#comandos-útiles)
  - [Cómo resetear el entorno](#cómo-resetear-el-entorno)
- [Troubleshooting](#-troubleshooting)
  - [Docker Desktop no responde](#docker-desktop-no-responde)
  - [Puerto 8080 ocupado](#puerto-8080-ocupado)
  - [Moodle tarda mucho la primera vez](#moodle-tarda-mucho-la-primera-vez)
  - [Permisos de `moodledata` en Windows](#permisos-de-moodledata-en-windows)
  - [WSL2 vs Hyper-V backend](#wsl2-vs-hyper-v-backend)
- [Sprint 5 — Exposición pública](#-sprint-5--exposición-pública)
  - [Cloudflare Tunnel (plan A)](#cloudflare-tunnel-plan-a)
  - [Oracle Cloud Free Tier (plan B)](#oracle-cloud-free-tier-plan-b)

---

## 🐳 Entorno local con Docker

### Prerrequisitos

| Item | Versión mínima | Comentario |
|---|---|---|
| Docker Desktop | 4.x | Windows/Mac/Linux. En Windows, backend WSL2 recomendado. |
| Git | 2.x | Para clonar el repo. |
| RAM libre | ~3 GB | El stack pesa poco, pero Moodle PHP necesita aire. |
| Puertos libres | 8080, 8025, 8443 | Si están ocupados ver [Troubleshooting](#puerto-8080-ocupado). |

### Setup paso a paso

```bash
# 1. Clonar el repo
git clone https://github.com/Osyanne/Osyanificacion-Plugin-Moodle.git
cd Osyanificacion-Plugin-Moodle

# 2. Crear .env con passwords reales
cp .env.example .env
# Editar .env y reemplazar TODOS los CAMBIAME_ por contraseñas fuertes
# (mínimo 16 caracteres aleatorios cada una)

# 3. Verificar Docker
docker info        # debe responder sin error
docker compose version  # debe imprimir versión

# 4. Levantar el stack (background)
docker compose up -d

# 5. Seguir el log hasta que Moodle inicialice
docker compose logs -f moodle
# Esperar mensaje: "moodle XX:XX:XX ** Starting Moodle **"
# Ctrl+C para soltar el log (containers siguen corriendo)
```

### Verificación del stack

| URL | Servicio | Credenciales |
|---|---|---|
| http://localhost:8080 | Moodle | `MOODLE_USERNAME` / `MOODLE_PASSWORD` del `.env` |
| http://localhost:8025 | Mailhog (emails capturados) | Sin auth |

Smoke test mínimo después de bootstrap:

1. Login en http://localhost:8080 con las credenciales del `.env`
2. Site administration → Notifications (debe responder sin errores)
3. Site administration → Plugins → Plugin overview (lista carga)
4. Forgot password de prueba → revisar Mailhog en http://localhost:8025

---

## 🔧 Operación día a día

### Comandos útiles

```bash
docker compose ps                # Estado de servicios
docker compose logs -f moodle    # Logs en vivo de Moodle
docker compose logs --tail=100 mariadb   # Últimas 100 líneas de la BD
docker compose restart moodle    # Reiniciar solo Moodle (no toca BD)
docker compose exec moodle bash  # Shell dentro del container Moodle
docker compose exec mariadb mariadb -uroot -p${MARIADB_ROOT_PASSWORD} bitnami_moodle
docker compose down              # Apagar todo, preserva datos
docker compose stop              # Pausar containers, no los destruye
docker compose start             # Reanudar containers pausados
```

### Cómo resetear el entorno

> ⚠️ **Destruye datos**. Usá solo si necesitás partir limpio (ej. probar
> el bootstrap desde cero, simular instalación fresca del plugin, etc.).

```bash
docker compose down -v             # Apaga + borra volúmenes nombrados
docker volume prune -f             # (opcional) limpia volúmenes huérfanos
docker compose up -d               # Vuelve a bootstrappear desde cero
```

El siguiente `up` tarda otra vez 3-5 minutos porque Moodle reinstala BD.

---

## 🩺 Troubleshooting

### Docker Desktop no responde

**Síntoma**:

```
failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine
The system cannot find the file specified.
```

**Causa**: Docker Desktop está instalado pero el daemon no corre.

**Solución**:
1. Abrir Docker Desktop desde el menú Inicio (Windows) o Applications (Mac)
2. Esperar a que el icono de la bandeja muestre "Docker Desktop is running"
3. Reintentar `docker info`

Si el icono se queda cargando: reiniciar Docker Desktop desde su menú
(`Troubleshoot → Restart`). Si falla, reiniciar Windows.

### Puerto 8080 ocupado

**Síntoma**: `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Causa**: otra app está usando el puerto (típicamente otro contenedor,
Tomcat, o algún dashboard local).

**Solución rápida** (cambiar puerto en `docker-compose.yml`):

```yaml
moodle:
  ports:
    - "8090:8080"   # antes "8080:8080"
```

Luego acceder en http://localhost:8090. Lo mismo aplica para `8025`
(Mailhog) y `8443` (HTTPS Moodle).

**Solución alternativa** (matar lo que ocupa el puerto):

```powershell
# PowerShell
Get-NetTCPConnection -LocalPort 8080 | Select-Object OwningProcess
Stop-Process -Id <PID> -Force
```

### Moodle tarda mucho la primera vez

**Esperado**: 3-5 minutos en arrancar la primera vez. Bitnami descarga
imágenes, crea la BD, instala Moodle, crea el admin y semilla idiomas.

**Cuándo preocuparse**: si pasaron **10+ minutos sin login disponible**,
ver logs:

```bash
docker compose logs --tail=200 moodle
docker compose logs --tail=200 mariadb
```

Errores típicos:
- `MariaDB not ready` → healthcheck no pasó. Ver logs MariaDB.
- `Permission denied: /bitnami/moodledata` → ver siguiente sección.
- `Out of memory` → subir memoria asignada a Docker Desktop
  (Settings → Resources → Memory: subir a ≥ 4 GB).

### Permisos de `moodledata` en Windows

**Síntoma**: errores de `Permission denied` al inicializar Moodle.

**Causa**: en Windows con bind mounts (no es nuestro caso por defecto
porque usamos volúmenes nombrados), Docker puede tener problemas con
permisos POSIX. **Por defecto NO usamos bind mounts en Sprint 0**, así
que esto solo aplica si modificás `docker-compose.yml` activando los
bind mounts comentados.

**Soluciones**:
1. Asegurar que Docker Desktop usa **backend WSL2** (ver siguiente sección)
2. Si seguís con bind mount: hacer el bind a una carpeta dentro de WSL2
   (no `C:\Users\...`) — mucho más rápido y sin problemas de permisos

### WSL2 vs Hyper-V backend

Docker Desktop en Windows puede usar dos backends. **WSL2 es el
recomendado** porque:
- Performance mucho mayor (especialmente con bind mounts)
- Menos consumo de RAM
- Compatibilidad con kernel Linux real

Verificar el backend actual:
1. Docker Desktop → Settings → General
2. Debe estar marcado `Use the WSL 2 based engine`
3. Si no, activarlo y reiniciar Docker Desktop

Si WSL2 no está instalado: `wsl --install` en PowerShell (admin) y
reiniciar.

---

## 🌐 Sprint 5 — Exposición pública

> ⏳ **TODO** — esta sección se completa cuando arranque Sprint 5. Por
> ahora queda como placeholder con el plan A y el plan B documentados a
> alto nivel.

### Cloudflare Tunnel (plan A)

**Objetivo**: exponer el Moodle local bajo URL HTTPS pública sin abrir
puertos, sin firewall, sin SSL setup. **0 costo**.

**Setup express (sin URL fija, suficiente para demos puntuales)**:

```bash
# 1. Instalar cloudflared (Windows con winget)
winget install --id Cloudflare.cloudflared

# 2. Levantar tunnel apuntando al Moodle local
cloudflared tunnel --url http://localhost:8080
```

El comando imprime una URL temporal del tipo:
`https://palabras-random-1234.trycloudflare.com`

Esa URL queda viva mientras el comando esté corriendo y la laptop
prendida. Ideal para mostrar la demo a quien sea sin desplegar nada.

**Setup con URL fija** (opcional, ~USD 1-3/año en dominio):

1. Comprar dominio en Namecheap (ej. `.online` ~USD 1/año)
2. Crear cuenta en Cloudflare (gratis)
3. Apuntar nameservers del dominio a Cloudflare
4. `cloudflared tunnel login`
5. `cloudflared tunnel create demo-fisei`
6. Crear archivo de config en `~/.cloudflared/config.yml`:
   ```yaml
   tunnel: <TUNNEL_ID>
   credentials-file: ~/.cloudflared/<TUNNEL_ID>.json
   ingress:
     - hostname: demo.gamificacion-fisei.online
       service: http://localhost:8080
     - service: http_status:404
   ```
7. `cloudflared tunnel route dns demo-fisei demo.gamificacion-fisei.online`
8. `cloudflared tunnel run demo-fisei`

URL final: `https://demo.gamificacion-fisei.online`

**Operación día de demo (Fase 2)**:
1. Prender laptop + Docker Desktop
2. `docker compose up -d` y esperar bootstrap
3. `cloudflared tunnel run demo-fisei` (en otra terminal)
4. Compartir URL con los stakeholders
5. Al terminar: `Ctrl+C` en el tunnel y `docker compose stop`

### Oracle Cloud Free Tier (plan B)

> **Activar solo si Cloudflare Tunnel resulta limitante en la práctica**
> (ej. necesidad de URL 24/7 sin laptop prendida, latencia mala desde
> el público objetivo, o Cloudflare bloquea la cuenta por uso "comercial"
> del tunnel free).

Procedimiento operativo completo en
[`plan-b-oracle-cloud.md`](plan-b-oracle-cloud.md) — incluye:

- Crear cuenta y provisionar VM ARM Ampere A1 (4 OCPU + 16 GB RAM, **$0**)
- Configurar networking, SSH, swap, hardening básico
- Instalar Docker, clonar repo, levantar el stack
- Caddy como reverse proxy con HTTPS automático (Let's Encrypt)
- DNS apuntando a la VM (Cloudflare DNS o directo)
- Backup diario de MariaDB + snapshots semanales del bloque
- Monitoreo con UptimeRobot / Uptime Kuma / Healthchecks.io
- Cleanup completo si decidimos desactivarlo

**Costo total Plan B**: **USD 0** (o ~USD 1-3/año si se quiere dominio fijo).

**Resumen de capacidad**:

| Recurso | Cuota Always Free |
|---|---|
| Compute ARM (Ampere A1) | 4 OCPU + 24 GB RAM |
| Block storage | 200 GB |
| Tráfico saliente | 10 TB/mes |
| Object storage (backups) | 20 GB + 50K req/mes |

**Caveats principales** (todos detallados en el doc dedicado):
- ARM puede tener quirks con algunas imágenes Docker. La imagen
  `bitnamilegacy/moodle:4.3` que usamos sí soporta `arm64` (verificado
  al 2026-05-22).
- Stock ARM Always Free es muy demandado — puede salir "Out of capacity"
  al provisionar. Hay estrategias de retry en el doc.
- Algunas regiones tienen mejor stock que otras. Para Ecuador, probar
  `us-ashburn-1` o `sa-saopaulo-1`.

---

## 📚 Referencias

- [Bitnami Moodle image docs](https://hub.docker.com/r/bitnami/moodle)
- [Moodle 4.3 admin documentation](https://docs.moodle.org/403/en/Main_page)
- [Cloudflare Tunnel docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/)

## ✅ Verificación del stack (smoke test)

> Último smoke test ejecutado: **2026-05-22** en Windows 11, Docker
> Desktop 29.4.3 con backend WSL2. Resultado documentado abajo.

### Procedimiento

```bash
docker info                                  # daemon respondiendo
cp .env.example .env                         # passwords reales en .env
docker compose up -d                         # levantar stack
# Esperar hasta que Moodle responda 200 (poll cada 15s)
until curl -fsS -o /dev/null -w "%{http_code}" http://localhost:8080 \
  | grep -qE '^(200|302|303)$'; do sleep 15; done
curl -sI http://localhost:8080               # HTTP headers
curl -sI http://localhost:8025               # Mailhog UI
docker compose ps                            # estado containers
```

### Resultados esperados

| Métrica | Valor objetivo | Verificación |
|---|---|---|
| Tiempo total bootstrap | 3-5 min | `docker compose logs moodle` debe terminar en `** Starting Moodle **` |
| HTTP status Moodle | 200 | `curl -I http://localhost:8080` |
| Latencia primera respuesta | < 200 ms en local | `time` del curl |
| `Content-Language` header | `es` | ya viene del `MOODLE_LANG=es` |
| Set-Cookie `MoodleSession` | presente con `HttpOnly` | seguridad básica |
| MariaDB healthcheck | `healthy` | `docker compose ps` |

### Resultados medidos 2026-05-22

```
HTTP 200 | time=0.083769s | size=27218B
Content-Language: es
Set-Cookie: MoodleSession=...; path=/; HttpOnly
MariaDB: Up X minutes (healthy)
```

⚠️ **Pre-requisito**: aplicar [INFRA-001](../KNOWN_ISSUES.md#infra-001) — sin el cambio
`bitnami/*` → `bitnamilegacy/*` el pull falla.

ℹ️ **Mailhog**: el endpoint web devuelve `HTTP 404` en la URL raíz `/`
en algunas versiones — eso es esperado. La UI funcional vive en
`http://localhost:8025/` con la SPA cargada por JS.

## ⚠️ Issues conocidos

Ver [`KNOWN_ISSUES.md`](../KNOWN_ISSUES.md).
