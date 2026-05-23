# Plan A — Cloudflare Tunnel

> **Procedimiento operativo** para exponer el Moodle local bajo URL
> HTTPS pública usando Cloudflare Tunnel. Es el **Plan A** del proyecto
> (default desde Sprint 5). Si resulta limitante, fallback al
> [Plan B Oracle Cloud Free Tier](plan-b-oracle-cloud.md).
>
> **Estado**: documento de referencia. Setup real se ejecuta en Sprint 5.
>
> **Costo total**: **USD 0** (con dominio fijo opcional ~USD 1-3/año).

## 📋 Tabla de contenidos

- [¿Qué es Cloudflare Tunnel?](#-qué-es-cloudflare-tunnel)
- [Plan A vs Plan B](#-plan-a-vs-plan-b-cuándo-usar-cada-uno)
- [Prerrequisitos](#-prerrequisitos)
- [Modo 1 — Tunnel temporal (5 min, URL random)](#-modo-1--tunnel-temporal-5-min-url-random)
- [Modo 2 — Tunnel con URL fija (30 min, requiere dominio)](#-modo-2--tunnel-con-url-fija-30-min-requiere-dominio)
- [Persistencia (correr como servicio Windows)](#-persistencia-correr-como-servicio-windows)
- [Operación día-de-demo](#-operación-día-de-demo)
- [Manejo de credenciales](#-manejo-de-credenciales)
- [Logs y troubleshooting](#-logs-y-troubleshooting)
- [¿Cuándo migrar al Plan B?](#-cuándo-migrar-al-plan-b)
- [Referencias](#-referencias)

## 🌩️ ¿Qué es Cloudflare Tunnel?

Servicio gratuito de Cloudflare que **expone un servicio local bajo una
URL HTTPS pública** sin abrir puertos, sin firewall, sin configurar SSL.

Funciona así:

```
[Internet] → https://demo.osyanificacion.online
                    ↓
            [Cloudflare edge]
                    ↓ (tunnel persistente cifrado)
            [cloudflared en tu laptop]
                    ↓
            [Moodle en localhost:8080]
```

**Ventajas vs otros métodos**:

| Método | Costo | Configuración | URL pública | HTTPS |
|---|---|---|---|---|
| **Cloudflare Tunnel** | $0 | Bajo | ✅ Sí | ✅ Automático |
| Port forward + DDNS | $0 | Alto (router, firewall) | ✅ Sí | ❌ Manual |
| ngrok free | $0 | Bajo | ⚠️ URL cambia cada sesión, banner intrusivo | ✅ Sí |
| Oracle Cloud VPS | $0 | Alto | ✅ Sí | ⚠️ Manual con Caddy |

## 🆚 Plan A vs Plan B (cuándo usar cada uno)

| Criterio | Plan A (Cloudflare Tunnel) | Plan B (Oracle Cloud VPS) |
|---|---|---|
| **Costo** | $0 ($1-3/año dominio opcional) | $0 ($1-3/año dominio) |
| **Setup time** | 5-30 min | 1-2 h |
| **Requiere laptop prendida** | ✅ Sí (mientras se acceda) | ❌ No (24/7 standalone) |
| **Latencia desde Ecuador** | Media-baja (edge Cloudflare global) | Baja-media (depende región Oracle) |
| **Mantenimiento** | Casi nulo | Updates de SO + Docker + monitoring |
| **Cuotas / límites** | Ninguno conocido para uso free legítimo | 200 GB storage, 10 TB egress/mes |
| **Cuándo usarlo** | Demos puntuales, pitch a institución externa | URL permanente 24/7 para uso prolongado |

**Default del proyecto**: **Plan A**. Migrar a Plan B solo si Sprint 5
demuestra que es limitante.

## 📦 Prerrequisitos

| Item | Para qué |
|---|---|
| **Stack Docker corriendo** (`make up`) | El tunnel apunta a `http://localhost:8080` |
| **Windows 10/11 o Linux/macOS** | `cloudflared` corre nativo en los tres |
| **Cuenta Cloudflare gratis** | Solo necesaria para Modo 2 (URL fija). Modo 1 no requiere cuenta. |
| **Dominio propio** (solo Modo 2) | Comprar en Namecheap ~USD 1/año (`.online`, `.xyz`) o similar |
| **Conexión estable a internet** | El tunnel deja de funcionar si se corta |

## ⚡ Modo 1 — Tunnel temporal (5 min, URL random)

Ideal para mostrar la demo a alguien puntualmente. URL del tipo
`https://palabras-random-1234.trycloudflare.com` que vive mientras el
comando esté corriendo.

### Paso 1.1 — Instalar `cloudflared`

**Windows** (PowerShell):

```powershell
winget install --id Cloudflare.cloudflared
```

**Linux** (Debian/Ubuntu):

```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
```

**macOS**:

```bash
brew install cloudflared
```

Verificar:

```bash
cloudflared --version
# cloudflared version 2024.X.X
```

### Paso 1.2 — Levantar el tunnel temporal

Asegurate que Moodle esté corriendo en `http://localhost:8080`
(`make up` y verificar con `curl -I http://localhost:8080`).

```bash
cloudflared tunnel --url http://localhost:8080
```

Output esperado:

```
+--------------------------------------------------------------------------------------------+
|  Your quick Tunnel has been created! Visit it at (it may take some time to be reachable):  |
|  https://palabras-random-1234.trycloudflare.com                                            |
+--------------------------------------------------------------------------------------------+
```

### Paso 1.3 — Verificar desde otro dispositivo

Abrí la URL desde:
- Un celular en datos móviles (no la misma WiFi)
- O un browser en otra red

Debería abrir tu Moodle local.

### Paso 1.4 — Apagar

`Ctrl+C` en la terminal donde corre el tunnel. La URL deja de funcionar.
El stack Docker sigue corriendo (apagar aparte con `make down` si querés).

## 🌐 Modo 2 — Tunnel con URL fija (30 min, requiere dominio)

URL estable tipo `https://demo.osyanificacion.online` que sobrevive a
reinicios y no cambia.

### Paso 2.1 — Comprar dominio (opcional)

**Sugerencia económica**: Namecheap, dominio `.online` por ~USD 1/año.

Alternativas gratuitas:
- **Freenom** (`.tk`, `.ml`, `.ga`): poco confiable, evitar para algo que va a Fase 2
- **DuckDNS** o servicios similares: gratis pero URL menos profesional

Para este proyecto, comprar dominio es la opción recomendada.

### Paso 2.2 — Crear cuenta Cloudflare

1. Ir a https://dash.cloudflare.com/sign-up
2. Crear cuenta con email del proyecto (NO el personal del equipo)
3. Verificar email

### Paso 2.3 — Apuntar el dominio a Cloudflare

1. En Cloudflare Dashboard → **Add a Site**
2. Pegar el dominio comprado (ej. `osyanificacion.online`)
3. Elegir plan **Free**
4. Cloudflare te da 2 nameservers tipo `ana.ns.cloudflare.com` y `bob.ns.cloudflare.com`
5. En el panel de Namecheap (o tu registrador): Domain List → Manage → Nameservers → Custom DNS → pegar los 2 de Cloudflare
6. Esperar propagación (10 min - 24 h, normalmente <1 h)

Verificar:

```bash
dig osyanificacion.online NS +short
# Debe responder con los nameservers de Cloudflare
```

### Paso 2.4 — Autenticar `cloudflared`

```bash
cloudflared tunnel login
```

Esto abre un navegador → seleccionar el dominio → autorizar.
Se descarga un certificado a `~/.cloudflared/cert.pem` (Linux/macOS) o
`%USERPROFILE%\.cloudflared\cert.pem` (Windows).

### Paso 2.5 — Crear el tunnel

```bash
cloudflared tunnel create demo-osyanificacion
```

Output:

```
Tunnel credentials written to /home/user/.cloudflared/<UUID>.json
Created tunnel demo-osyanificacion with id <UUID>
```

Guardá el `<UUID>` — lo necesitás en el siguiente paso.

### Paso 2.6 — Crear archivo de configuración

Crear `~/.cloudflared/config.yml` (Linux/macOS) o
`%USERPROFILE%\.cloudflared\config.yml` (Windows):

```yaml
tunnel: <UUID-del-paso-anterior>
credentials-file: /home/user/.cloudflared/<UUID>.json
# Windows: C:\Users\<user>\.cloudflared\<UUID>.json

ingress:
  - hostname: demo.osyanificacion.online
    service: http://localhost:8080
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```

### Paso 2.7 — Apuntar DNS al tunnel

```bash
cloudflared tunnel route dns demo-osyanificacion demo.osyanificacion.online
```

Esto crea automáticamente un CNAME en Cloudflare apuntando al UUID
del tunnel.

### Paso 2.8 — Correr el tunnel

```bash
cloudflared tunnel run demo-osyanificacion
```

URL final: `https://demo.osyanificacion.online`

Cloudflare emite el certificado HTTPS automáticamente.

## 🔧 Persistencia (correr como servicio Windows)

Para que el tunnel arranque solo al prender la laptop:

```powershell
# PowerShell como Administrador
cloudflared service install
```

Esto registra `cloudflared` como **servicio de Windows**. Verificá:

```powershell
Get-Service cloudflared
# Status: Running
```

Comandos útiles:

```powershell
Stop-Service cloudflared
Start-Service cloudflared
Restart-Service cloudflared
```

Para Linux/macOS:

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

## 🎬 Operación día-de-demo

Asumiendo Modo 2 con servicio Windows ya instalado:

1. **Prender laptop + Docker Desktop**
2. `make up` (levantar stack)
3. Verificar: `curl -I https://demo.osyanificacion.online` → `HTTP/2 200`
4. Compartir URL con stakeholders
5. Al finalizar la demo:
   - `make stop` (pausar containers, datos persisten)
   - **NO apagar el servicio cloudflared** — sigue corriendo en background, sin uso real

Si el tunnel es **Modo 1 (temporal)**:

1. `make up`
2. `cloudflared tunnel --url http://localhost:8080`
3. Copiar URL que imprime y compartir
4. Al finalizar: `Ctrl+C` en la terminal del tunnel

## 🔐 Manejo de credenciales

### Archivos sensibles

| Archivo | Contenido | Acción |
|---|---|---|
| `~/.cloudflared/cert.pem` | Certificado de autenticación Cloudflare | **NO commitear** (ya está en `.gitignore`) |
| `~/.cloudflared/<UUID>.json` | Credenciales del tunnel | **NO commitear** |
| `~/.cloudflared/config.yml` | Config del tunnel (con UUID y paths) | OK si no expone secretos, pero mejor mantener local |

### Rotación de credenciales

Si sospechás compromiso (laptop robada, credentials filtradas):

```bash
# Borrar el tunnel completo
cloudflared tunnel delete demo-osyanificacion

# Re-autenticar
rm ~/.cloudflared/cert.pem
cloudflared tunnel login

# Re-crear tunnel + config + DNS desde el paso 2.5
```

### Buenas prácticas

1. **NO compartir el `cert.pem`** entre integrantes del equipo. Cada
   uno hace su propio `cloudflared tunnel login`.
2. **Una laptop a la vez** corre el tunnel `demo-osyanificacion`. Si
   queremos backup (Imanol y Álvaro), crear 2 tunnels distintos
   (`demo-osyanificacion-alvaro`, `demo-osyanificacion-imanol`) y solo
   uno activo a la vez.

## 🩺 Logs y troubleshooting

### Ver logs del tunnel

**Tunnel temporal (Modo 1)**: los logs se imprimen en la terminal donde
corre `cloudflared tunnel --url ...`. `Ctrl+C` para apagar.

**Tunnel como servicio Windows**:

```powershell
Get-EventLog -LogName Application -Source cloudflared -Newest 20
```

**Tunnel como servicio Linux**:

```bash
sudo journalctl -u cloudflared -f
```

### Problemas comunes

**Síntoma**: tunnel arranca pero la URL responde "Error 1033 Argo Tunnel error"

**Causa**: el origen (`http://localhost:8080`) no responde. Cloudflare
está OK, el problema es Moodle.

**Fix**: `make ps` → confirmar containers UP. `make logs` → revisar
errores de Moodle. Probar `curl -I http://localhost:8080` en la misma
máquina donde corre el tunnel.

---

**Síntoma**: `cloudflared tunnel run` falla con "tunnel already exists"

**Causa**: ya tenés una instancia corriendo (a veces queda zombie).

**Fix**:

```bash
# Linux/macOS
pkill cloudflared
# Windows
Stop-Service cloudflared -Force
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
```

Y volver a correr `cloudflared tunnel run`.

---

**Síntoma**: HTTPS no funciona, el navegador muestra "ERR_CERT_AUTHORITY_INVALID"

**Causa**: el DNS todavía no propagó, Cloudflare no pudo emitir el cert.

**Fix**: esperar 5-15 min más. Verificar `dig demo.osyanificacion.online +short`
debe responder con un IP de Cloudflare. Si no responde nada, revisar paso 2.7.

---

**Síntoma**: la cuenta de Cloudflare se bloquea con mensaje sobre
"uso comercial del Tunnel free tier"

**Causa**: raro pero posible si el tráfico es muy alto y "parece"
producción comercial.

**Fix**: pasar al [Plan B (Oracle Cloud)](plan-b-oracle-cloud.md).

## 🚨 ¿Cuándo migrar al Plan B?

Activar Plan B (VPS Oracle Cloud) si en Sprint 5 alguna de estas se
cumple:

- **Necesidad de URL 24/7 sin laptop prendida**: las demos de Fase 2 a
  institución externa pueden requerir que ellos prueben a su ritmo, no
  solo cuando vos tenés la laptop encendida.
- **Latencia alta desde el público objetivo**: si el primer test
  contra el tunnel desde Ecuador muestra latencia inaceptable, el VPS
  ARM Ampere A1 en `us-ashburn-1` o `sa-saopaulo-1` puede ser más rápido.
- **Cloudflare bloquea la cuenta** por uso "comercial" (raro).
- **Necesidad de tareas programadas / cron jobs** del lado de servidor
  (Cloudflare Tunnel solo expone HTTP, no es un host completo).

## 📚 Referencias

- [Cloudflare Tunnel docs oficiales](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [cloudflared GitHub releases](https://github.com/cloudflare/cloudflared/releases)
- [Cloudflare free tier limits](https://www.cloudflare.com/plans/free/)
- [`docs/plan-b-oracle-cloud.md`](plan-b-oracle-cloud.md) — Plan B operativo
- [`docs/deployment.md`](deployment.md) — guía general de deployment

## ⚠️ Notas importantes

- Este documento es **referencia operativa**, no se ejecutó todavía.
  Cualquier comando se valida solo cuando Álvaro efectivamente instale
  `cloudflared` en Sprint 5.
- Cualquier desviación encontrada → actualizar este doc + entrada en
  [`KNOWN_ISSUES.md`](../KNOWN_ISSUES.md).
- Si Cloudflare cambia su free tier o los comandos de `cloudflared`,
  revisar la [doc oficial](https://developers.cloudflare.com/cloudflare-one/)
  antes de re-ejecutar.
