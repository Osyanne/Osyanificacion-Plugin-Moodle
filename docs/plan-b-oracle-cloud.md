# Plan B — Oracle Cloud Free Tier

> Procedimiento operativo para desplegar Osyanificación Plugin Moodle en
> Oracle Cloud Always Free como **fallback** si Cloudflare Tunnel
> (plan A descrito en [`deployment.md`](deployment.md#cloudflare-tunnel-plan-a))
> resulta limitante.
>
> **Estado**: documento de referencia, **NO ejecutado todavía**. Se
> activa solo si Sprint 5 demuestra que el Plan A no alcanza
> (típicamente: necesidad de URL 24/7 sin laptop prendida).
>
> **Costo total**: **USD 0** (con dominio opcional ~USD 1-3/año).

## 📋 Tabla de contenidos

- [¿Cuándo activar el Plan B?](#-cuándo-activar-el-plan-b)
- [Recursos Always Free disponibles](#-recursos-always-free-disponibles)
- [Prerrequisitos](#-prerrequisitos)
- [1. Crear cuenta Oracle Cloud](#1-crear-cuenta-oracle-cloud)
- [2. Provisionar la VM ARM Ampere A1](#2-provisionar-la-vm-arm-ampere-a1)
- [3. Configurar networking (VCN + Security List)](#3-configurar-networking-vcn--security-list)
- [4. Acceso SSH inicial](#4-acceso-ssh-inicial)
- [5. Configuración base del sistema](#5-configuración-base-del-sistema)
- [6. Instalar Docker + Docker Compose](#6-instalar-docker--docker-compose)
- [7. Clonar repo + configurar `.env`](#7-clonar-repo--configurar-env)
- [8. Levantar el stack](#8-levantar-el-stack)
- [9. Reverse proxy con HTTPS (Caddy)](#9-reverse-proxy-con-https-caddy)
- [10. DNS apuntando a la VM](#10-dns-apuntando-a-la-vm)
- [11. Hardening básico](#11-hardening-básico)
- [12. Backup mínimo viable](#12-backup-mínimo-viable)
- [13. Monitoreo gratis](#13-monitoreo-gratis)
- [14. Cleanup (apagar y borrar todo)](#14-cleanup-apagar-y-borrar-todo)
- [Troubleshooting](#-troubleshooting)
- [Referencias](#-referencias)

---

## 🎯 ¿Cuándo activar el Plan B?

Considerar **solo si** alguno de estos casos se da en Sprint 5+:

| Síntoma del Plan A | Implicancia |
|---|---|
| Cloudflare bloquea cuenta por uso "comercial" del tunnel free | URL temporal deja de funcionar |
| Necesidad de URL **24/7 sin laptop prendida** | Demos en Fase 2 a institución externa que querrá probar a su ritmo |
| Latencia muy alta desde el público objetivo (Ecuador → tunnel relay) | Algunas regiones de Cloudflare tienen mejor cobertura LATAM |
| El equipo necesita correr cron jobs / tareas programadas estables | Cloudflare Tunnel solo expone HTTP, no es un host real |

Si ninguno se da → **NO activar el Plan B**, queda con tunnel.

---

## 🆓 Recursos Always Free disponibles

Oracle Cloud Free Tier ofrece (al 2026-05-22):

| Recurso | Cuota gratis permanente |
|---|---|
| **Compute ARM (Ampere A1)** | Hasta **4 OCPU + 24 GB RAM** (divisible en varias VMs) |
| **Compute AMD x86** | 2 VMs Micro (1/8 OCPU + 1 GB RAM cada una — chicas) |
| **Block storage** | 200 GB totales para todas las VMs |
| **Object storage** | 20 GB + 50K requests/mes |
| **Tráfico saliente** | 10 TB/mes (resto del mundo) |
| **Load balancer** | 1 instancia 10 Mbps |
| **Monitoring + Logging** | Básico incluido |

**Para Moodle recomendamos**: 1 VM ARM con 4 OCPU + 16 GB RAM + 100 GB
de bloque. Sobra para los 50 usuarios concurrentes objetivo + headroom.

---

## 📦 Prerrequisitos

- Tarjeta de crédito **válida** (Oracle hace pre-autorización de USD 1
  para verificar — NO cobra, queda como hold y se libera). Sin tarjeta
  no se puede crear cuenta Free.
- Número de teléfono para SMS de verificación.
- Cuenta de email no usada antes en Oracle Cloud (cuentas duplicadas
  son rechazadas).
- ~1 hora para el setup inicial.
- (Opcional) Dominio propio — sin él la URL queda como
  `https://<IP-publica>` sin HTTPS válido. Recomendado comprar un
  dominio en Namecheap (`.online` ~USD 1/año).

---

## 1. Crear cuenta Oracle Cloud

1. Ir a https://signup.cloud.oracle.com
2. Llenar email, país (**Ecuador**), nombre completo
3. Verificar email (link en bandeja)
4. Crear contraseña fuerte (≥ 12 caracteres, mayúsculas, números, símbolos)
5. **Elegir Home Region** con cuidado: NO se puede cambiar después.
   Recomendadas para Ecuador:
   - **`us-ashburn-1`** (Virginia, EE.UU.) — más capacidad ARM disponible
   - **`sa-saopaulo-1`** (São Paulo, Brasil) — menos latencia desde Ecuador pero a veces sin stock ARM
6. Verificar tarjeta de crédito (hold de USD 1)
7. Verificar teléfono (SMS code)
8. Esperar el email "Your OCI account is ready" (5-30 min)

⚠️ **Importante**: durante setup, ELEGIR **"Always Free"** explícitamente
en el dashboard. Si no, Oracle puede asignar recursos Pay-As-You-Go por
defecto.

---

## 2. Provisionar la VM ARM Ampere A1

1. Console OCI → **Compute → Instances → Create Instance**
2. **Name**: `osyanificacion-prod`
3. **Image**: `Canonical Ubuntu 22.04` (LTS, soportado hasta 2027)
4. **Shape**: click **Change shape**
   - Categoría: **Ampere**
   - Shape: **VM.Standard.A1.Flex**
   - OCPUs: **4**
   - Memory (GB): **16** (dejar margen para el resto de cuota free)
5. **Networking**:
   - VCN: crear nueva con CIDR default `10.0.0.0/16`
   - Subnet: pública
   - Assign public IP: **Sí**
6. **SSH keys**: **Generate a key pair for me**
   - **DESCARGAR ambas (.key privada + .key.pub pública)** — Oracle no
     las guarda. Si las perdés, perdés acceso a la VM.
   - Guardar la privada en `C:\Users\Alvaroo\.ssh\osyanificacion-prod.key`
   - Aplicar permisos: en PowerShell:
     ```powershell
     icacls C:\Users\Alvaroo\.ssh\osyanificacion-prod.key /inheritance:r /grant:r "$($env:USERNAME):F"
     ```
7. **Boot volume**: 100 GB (default 47 GB es poco para crecimiento de la BD)
8. Click **Create**

Espera 1-3 minutos a que esté **Running**.

### Si dice "Out of capacity"

Es normal con ARM Always Free — la cuota es muy demandada. Soluciones:
- Probar otra **Availability Domain** del menú (AD-1, AD-2, AD-3)
- Probar a otra hora (a las 2-4 AM UTC suele haber stock)
- Probar otra región (volver al paso 5 de "Crear cuenta" antes de
  cualquier setup — solo se puede cambiar Home Region una vez)
- Script de retry: hay scripts comunitarios en GitHub que reintentan
  cada 30 seg hasta que Oracle libere capacidad (buscar
  "oracle cloud free tier ampere retry script")

---

## 3. Configurar networking (VCN + Security List)

Por defecto, Oracle solo abre el puerto 22 (SSH). Tenemos que abrir
80 (HTTP) y 443 (HTTPS) para que Caddy pueda servir el sitio.

1. Console OCI → **Networking → Virtual Cloud Networks**
2. Click en el VCN creado → **Security Lists** → **Default Security List**
3. **Ingress Rules → Add Ingress Rules**:

   | Source CIDR | IP Protocol | Source Port | Destination Port |
   |---|---|---|---|
   | `0.0.0.0/0` | TCP | All | **80** |
   | `0.0.0.0/0` | TCP | All | **443** |

4. Guardar.

⚠️ Además, **dentro de la VM** Ubuntu trae `iptables` con reglas
restrictivas. Hay que abrir los puertos también ahí (paso 5).

---

## 4. Acceso SSH inicial

Desde la laptop (PowerShell):

```powershell
ssh -i C:\Users\Alvaroo\.ssh\osyanificacion-prod.key ubuntu@<IP-PUBLICA>
```

La IP pública la ves en el detalle de la VM en la console OCI.

Primera conexión va a preguntar `yes/no` para aceptar el fingerprint → `yes`.

Si pide passphrase, es la de tu clave SSH (si la pusiste al generar).

---

## 5. Configuración base del sistema

Dentro de la VM (como `ubuntu`):

```bash
# Actualizar todo
sudo apt update && sudo apt upgrade -y

# Zona horaria Ecuador
sudo timedatectl set-timezone America/Guayaquil

# Abrir puertos HTTP/HTTPS en iptables (Oracle Ubuntu trae reglas estrictas)
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save

# Swap (Oracle Free no trae swap; ayuda con picos de Moodle)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Hostname
sudo hostnamectl set-hostname osyanificacion-prod
```

Verificar:

```bash
free -h            # debe mostrar swap activo
sudo iptables -L INPUT -n | grep -E "(80|443)"   # debe mostrar las reglas
```

---

## 6. Instalar Docker + Docker Compose

```bash
# Instalar Docker (script oficial)
curl -fsSL https://get.docker.com | sh

# Agregar usuario al grupo docker (evita usar sudo)
sudo usermod -aG docker $USER

# Cerrar sesión y reconectar para que tome efecto el grupo
exit
# Volver a hacer ssh

# Verificar
docker --version             # Docker 24+ esperado
docker compose version       # v2+ esperado
docker run hello-world       # smoke test del runtime
```

---

## 7. Clonar repo + configurar `.env`

```bash
# Clonar (al 2026-05-22 el repo es privado, necesita PAT o SSH key de GitHub)
# Opción A: HTTPS con Personal Access Token (PAT) de GitHub
git clone https://<USERNAME>:<PAT>@github.com/Osyanne/Osyanificacion-Plugin-Moodle.git
cd Osyanificacion-Plugin-Moodle

# Opción B: SSH (generar key en la VM y agregarla a GitHub)
ssh-keygen -t ed25519 -C "vm-prod"
cat ~/.ssh/id_ed25519.pub
# Pegar la output en https://github.com/settings/keys
git clone git@github.com:Osyanne/Osyanificacion-Plugin-Moodle.git
cd Osyanificacion-Plugin-Moodle

# Crear .env con passwords reales (NUNCA los mismos que tu laptop)
cp .env.example .env
nano .env   # editar y reemplazar todos los CAMBIAME_ con passwords largas aleatorias
```

Para generar passwords seguras en la VM:

```bash
openssl rand -base64 32   # ejecutar 3 veces, uno por password
```

---

## 8. Levantar el stack

```bash
docker compose up -d
docker compose logs -f moodle   # esperar al "** Starting Moodle **"
# Ctrl+C cuando termine
```

Verificar:

```bash
docker compose ps                            # 3 containers UP
curl -sI http://localhost:8080 | head -3     # HTTP 200
```

⚠️ **Importante**: en este punto Moodle escucha solo en `localhost:8080`
de la VM. El público todavía no puede acceder porque Caddy aún no
está configurado.

---

## 9. Reverse proxy con HTTPS (Caddy)

Caddy es la opción más simple: HTTPS automático con Let's Encrypt en 4
líneas de config.

```bash
# Instalar Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy

# Configurar
sudo nano /etc/caddy/Caddyfile
```

Reemplazar el contenido por:

```caddyfile
# /etc/caddy/Caddyfile
demo.gamificacion-fisei.online {
    reverse_proxy localhost:8080

    # Headers de seguridad
    header {
        Strict-Transport-Security "max-age=31536000;"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "no-referrer-when-downgrade"
    }

    # Logs
    log {
        output file /var/log/caddy/access.log
        format json
    }
}
```

```bash
sudo systemctl reload caddy
sudo systemctl status caddy   # debe estar active (running)
```

Caddy emite el certificado SSL automáticamente la primera vez (~30 seg).

⚠️ **Pre-requisito**: el dominio `demo.gamificacion-fisei.online` debe
estar apuntando a la IP de la VM ANTES de reload (ver paso 10), si no
Caddy no puede emitir el cert.

---

## 10. DNS apuntando a la VM

### Opción A: usando Cloudflare DNS (recomendado, $0)

1. Si todavía no tenés cuenta Cloudflare: https://dash.cloudflare.com (free)
2. Agregar el dominio al panel Cloudflare
3. Cambiar los nameservers del dominio (en Namecheap u otro registrador)
   a los que te asigna Cloudflare (típicamente `*.ns.cloudflare.com`)
4. Esperar la propagación (~10 min - 24 h)
5. En Cloudflare → DNS → Add Record:
   - Type: **A**
   - Name: `demo`
   - IPv4: **`<IP-PUBLICA-VM>`**
   - Proxy status: **DNS only** (gris, NO la nube naranja — porque Caddy
     manejará el SSL)
6. Guardar
7. Verificar:
   ```bash
   dig demo.gamificacion-fisei.online +short
   # debe responder con la IP de la VM
   ```

### Opción B: DNS directo del registrador

Si no usás Cloudflare, panel del registrador → DNS → A record:

- Host: `demo`
- Value: `<IP-PUBLICA-VM>`
- TTL: 300

---

## 11. Hardening básico

Pasos mínimos antes de exponer el sitio al público real:

### 11.1. Deshabilitar password auth en SSH (solo SSH key)

```bash
sudo nano /etc/ssh/sshd_config
# Cambiar/agregar:
# PasswordAuthentication no
# PermitRootLogin no
sudo systemctl restart sshd
```

⚠️ Antes de hacer esto, **verificá que entrás por SSH key sin problemas
desde una segunda terminal**. Si te lockeás, vas a tener que usar el
console serial de Oracle para recuperar.

### 11.2. fail2ban (protege SSH contra brute force)

```bash
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd
```

### 11.3. Actualizaciones automáticas de seguridad

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
# Confirmar "Yes"
```

### 11.4. Limitar SSH a tu IP (opcional pero recomendado)

En Console OCI → VCN → Security List → editar la regla de puerto 22:

| Source CIDR | Antes | Después |
|---|---|---|
| 22 | `0.0.0.0/0` | `<TU-IP-PUBLICA>/32` |

Para conocer tu IP pública: https://ipv4.icanhazip.com

⚠️ Si tu IP es dinámica (ISP residencial), esto te puede dejar afuera
cuando cambie. Alternativa: usar [Tailscale free](https://tailscale.com)
para SSH solo desde VPN.

---

## 12. Backup mínimo viable

Estrategia: **snapshot semanal del bloque + dump diario de la BD a Object Storage**.

### 12.1. Snapshot del bloque (manual en Console OCI)

Console → **Block Storage → Boot Volumes → osyanificacion-prod**
→ **Boot Volume Backups → Create Boot Volume Backup**

Frecuencia recomendada: **antes de cualquier cambio mayor + automático
semanal con Backup Policy**.

Costo: incluido en los 200 GB free.

### 12.2. Dump diario de MariaDB (cron)

```bash
sudo nano /usr/local/bin/backup-moodle-db.sh
```

Contenido:

```bash
#!/bin/bash
set -euo pipefail
TS=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/home/ubuntu/backups
mkdir -p "$BACKUP_DIR"
cd /home/ubuntu/Osyanificacion-Plugin-Moodle
source .env
docker compose exec -T mariadb mariadb-dump \
  -uroot -p"$MARIADB_ROOT_PASSWORD" \
  --all-databases --single-transaction --quick \
  | gzip > "$BACKUP_DIR/moodle_${TS}.sql.gz"

# Retención: conservar últimos 7 días
find "$BACKUP_DIR" -name 'moodle_*.sql.gz' -mtime +7 -delete
```

```bash
sudo chmod +x /usr/local/bin/backup-moodle-db.sh

# Cron diario 03:00 AM (hora Guayaquil)
crontab -e
# Agregar:
0 3 * * * /usr/local/bin/backup-moodle-db.sh >> /var/log/backup-moodle.log 2>&1
```

### 12.3. Sincronizar a Object Storage (opcional)

Si querés que los dumps estén también fuera de la VM:

```bash
# Instalar OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
oci setup config

# Crear bucket en console OCI
# Subir dump
oci os object put --bucket-name osyanificacion-backups \
  --file /home/ubuntu/backups/moodle_${TS}.sql.gz
```

---

## 13. Monitoreo gratis

Tres opciones, todas $0 y compatibles:

### 13.1. UptimeRobot (más simple)

- https://uptimerobot.com → free tier (50 monitors, check cada 5 min)
- Crear monitor HTTPS para `https://demo.gamificacion-fisei.online`
- Alerta por email si cae

### 13.2. Uptime Kuma (self-hosted en la misma VM)

```bash
docker run -d --name uptime-kuma \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --restart unless-stopped \
  louislam/uptime-kuma:latest
```

Acceder en `https://demo.gamificacion-fisei.online:3001` (necesita
exponer puerto 3001 también en Caddy y Security List, o usar subdomain
aparte como `status.gamificacion-fisei.online`).

### 13.3. Healthchecks.io (para validar que el cron de backup corre)

- https://healthchecks.io → free tier (20 checks)
- Agregar al final del script de backup un `curl -fsS <ping-url>`
- Si falla 1 día sin ping → email

---

## 14. Cleanup (apagar y borrar todo)

Si decidimos desactivar el Plan B (porque Cloudflare Tunnel alcanzó):

1. Console OCI → Compute → Instances → osyanificacion-prod → **Terminate**
2. Marcar **Permanently delete the attached boot volume**
3. Networking → VCN → eliminar el VCN si no se usa para nada más
4. (Opcional) cancelar la cuenta Oracle si no se planea usar más

Costo: $0 (no hay penalty por terminar instancias).

---

## 🩺 Troubleshooting

### La VM no acepta conexión SSH

**Causa común**: clave SSH con permisos incorrectos en Windows.

```powershell
icacls C:\Users\Alvaroo\.ssh\osyanificacion-prod.key /inheritance:r /grant:r "$($env:USERNAME):F"
```

### Caddy responde "no such site"

DNS no resuelve a la IP de la VM todavía. Esperar propagación o
verificar con `dig`.

### Caddy emite el certificado pero el sitio carga 502 Bad Gateway

Moodle no está corriendo. Verificar con `docker compose ps`. Si todos
los containers están up, ver `docker compose logs moodle`.

### "Permission denied" en iptables al guardar reglas

Falta `netfilter-persistent`:

```bash
sudo apt install -y iptables-persistent netfilter-persistent
```

### Performance lenta en queries grandes

ARM puede ser hasta 30% más lento que x86 en algunos workloads PHP.
Soluciones:
- Asegurar `opcache` PHP habilitado (ya viene en Bitnami)
- Subir `pm.max_children` de PHP-FPM si Apache satura
- Habilitar query cache en MariaDB

### Cuota Always Free agotada (warning email de Oracle)

Imposible — los recursos free son fijos y no se "agotan". Si recibís
ese email, probablemente alguien creó recursos Pay-As-You-Go por
accidente. Revisar **Console OCI → Governance → Cost Management →
Cost Analysis**.

---

## 📚 Referencias

- [Oracle Cloud Always Free](https://www.oracle.com/cloud/free/)
- [Provisioning Ampere A1 instances](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm#flexible)
- [Caddy reverse proxy docs](https://caddyserver.com/docs/quick-starts/reverse-proxy)
- [MariaDB backup best practices](https://mariadb.com/kb/en/backup-and-restore-overview/)
- [Cloudflare DNS setup](https://developers.cloudflare.com/dns/zone-setups/full-setup/)

---

## ⚠️ Notas importantes

- Este documento es **referencia operativa**, no se ejecutó todavía.
  Cualquier comando se valida solo cuando alguien (Álvaro en Sprint 5+)
  efectivamente provisiona la VM y reporta resultado.
- Cualquier desviación encontrada → actualizar este doc + entrada en
  [`KNOWN_ISSUES.md`](../KNOWN_ISSUES.md).
- Si Oracle cambia su Free Tier o sus shapes, revisar la
  [página oficial](https://www.oracle.com/cloud/free/) antes de
  re-ejecutar.
