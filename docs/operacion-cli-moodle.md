# Operación CLI dentro del container Moodle

> Guía rápida para correr scripts CLI de Moodle (php, composer,
> mariadb, etc.) dentro del container Docker sin romper permisos del
> filesystem.
>
> **Pareja con**: [`KNOWN_ISSUES.md`](../KNOWN_ISSUES.md#infra-002)
> donde está documentado el bug INFRA-002 que motiva esta guía.

## 🔑 Regla de oro

> **Nunca ejecutar `php` (o cualquier comando que escriba en
> `moodledata/`) como usuario `root` dentro del container.**

Cuando `docker compose exec moodle ...` entra al container, lo hace
como `root` por default. Apache corre como `daemon`. Si root crea
archivos en `moodledata/`, daemon pierde permisos y Moodle se rompe
con error **"Invalid permissions detected when trying to create a
directory"** (ver [INFRA-002](../KNOWN_ISSUES.md#infra-002)).

## ✅ Forma correcta

### Opción A: con flag `-u daemon` explícito

```bash
docker compose exec -u daemon moodle sh -c 'php /bitnami/moodle/admin/cli/purge_caches.php'
```

### Opción B: con shortcut `make exec` (recomendado)

```bash
make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php'
```

Equivalente al `-u daemon` explícito, sin tener que recordarlo.

## 📋 Comandos típicos seguros

### Purgar todas las caches

```bash
make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php'
```

### Ejecutar `upgrade.php` después de instalar/actualizar un plugin

```bash
make exec CMD='php /bitnami/moodle/admin/cli/upgrade.php --non-interactive'
```

### Crear usuario admin de emergencia (cuando perdés password)

```bash
make exec CMD='php /bitnami/moodle/admin/cli/reset_password.php --username=admin --password=NuevaPass123!'
```

### Listar plugins instalados

```bash
make exec CMD='php /bitnami/moodle/admin/cli/list_plugins.php'
```

### Backup CLI de un curso

```bash
make exec CMD='php /bitnami/moodle/admin/cli/backup.php --courseid=2 --destination=/tmp/'
```

### Restore CLI de un curso

```bash
make exec CMD='php /bitnami/moodle/admin/cli/restore_backup.php --file=/tmp/backup-XYZ.mbz --categoryid=1'
```

### Bulk install de plugins

```bash
# Bajar el ZIP al container
docker cp plugin.zip osyanificacion-moodle:/tmp/plugin.zip

# Instalar como daemon
make exec CMD='php /bitnami/moodle/admin/cli/install_plugins.php --zip=/tmp/plugin.zip'
```

## ⚠️ Comandos que NO necesitan `-u daemon`

Solo los que **no escriben** en `moodledata/`:

### Consultas a MariaDB

```bash
# El container mariadb no tiene problemas de permisos cross-process
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle -e "SELECT id, shortname FROM mdl_course;"'
```

### Inspección de filesystem (lecturas)

```bash
docker compose exec moodle sh -c 'ls -la /bitnami/moodle/blocks/'
docker compose exec moodle sh -c 'cat /bitnami/moodle/config.php'
```

### Logs y diagnóstico

```bash
docker compose logs moodle
docker compose logs --tail=100 mariadb
```

## 🩹 Si ya rompiste los permisos

```bash
# Fix inmediato
docker compose exec moodle sh -c 'chown -R daemon:daemon /bitnami/moodledata'
docker compose restart moodle

# Esperar ~15 seg y verificar
curl -sI http://localhost:8080 | head -1   # debe devolver "HTTP/1.1 200 OK"
```

Si después de eso sigue rota, el problema puede ser otro. Ver
[`KNOWN_ISSUES.md`](../KNOWN_ISSUES.md) o reportar nuevo bug con
formato INFRA-XXX.

## 🧰 Por qué pasa esto

Bitnami Moodle separa privilegios para reducir el blast radius de un
exploit:

- **Master Apache**: `root` (necesita el privilegio para abrir el
  puerto 80/443)
- **Worker Apaches**: `daemon` (sin privilegios, sirve los requests)
- **Filesystem `moodledata/`**: propiedad de `daemon` con permisos
  775
- **Filesystem `moodle/` (código)**: propiedad de `daemon` con
  permisos 755

Cuando entrás vía `docker compose exec` sin flag `-u`, Docker te
loguea como el `USER` del Dockerfile, que en `bitnamilegacy/moodle:4.3`
es **`root`**. Cualquier archivo que crees queda con owner `root` y los
workers Apache pierden acceso.

El flag `-u daemon` (o `-u $(id -u daemon)` si querés ser estricto)
le dice a Docker que entre como ese usuario directamente — los
archivos que creés quedan con owner `daemon` y todo sigue funcionando.

## 📚 Referencias

- [Docker exec docs (`--user` flag)](https://docs.docker.com/reference/cli/docker/container/exec/)
- [Bitnami Moodle README](https://github.com/bitnami/containers/tree/main/bitnami/moodle)
- [INFRA-002 en KNOWN_ISSUES.md](../KNOWN_ISSUES.md#infra-002)
- [Moodle admin CLI scripts oficial](https://docs.moodle.org/403/en/Command-line_administration_scripts)
