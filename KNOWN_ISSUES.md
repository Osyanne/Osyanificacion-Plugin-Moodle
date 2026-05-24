# Issues conocidos

> Este archivo lista bugs conocidos del plugin con su workaround. Si
> encontrás algo que rompe, primero buscá acá.

## Formato de entradas

```
## [SHORT-ID] Título del bug
**Sprint donde se detectó**: Sprint X
**Severidad**: Alta / Media / Baja
**Descripción**: qué pasa
**Reproducción**: cómo dispararlo
**Workaround**: cómo evitarlo o mitigarlo
**Tracking**: link al issue de GitHub si aplica
**Status**: open / wip / fixed in vX.Y.Z
```

## [INFRA-001] `bitnami/moodle:4.3` ya no es pulleable sin Bitnami Secure

**Sprint donde se detectó**: Sprint 0 (smoke test del docker-compose.yml)
**Severidad**: Alta (bloquea el bootstrap del entorno local)
**Detectado por**: Álvaro · 2026-05-22

**Descripción**: en agosto 2025, Bitnami movió todas las imágenes
gratuitas a un nuevo namespace (`bitnamilegacy/*`) y dejó el namespace
original `bitnami/*` solo para suscriptores de "Bitnami Secure Images"
(pago). El primer `docker compose up -d` falla con:

```
Error response from daemon: failed to resolve reference
"docker.io/bitnami/moodle:4.3": docker.io/bitnami/moodle:4.3: not found
```

**Reproducción**:
1. Clonar el repo en el commit `252c657` o anterior (antes del fix)
2. `cp .env.example .env`, ajustar passwords
3. `docker compose up -d`
4. Verificar el error de pull

**Workaround / fix**: cambiar el prefijo del registry de `bitnami` a
`bitnamilegacy` en `docker-compose.yml` para ambos servicios:

```yaml
mariadb:
  image: docker.io/bitnamilegacy/mariadb:10.11
moodle:
  image: docker.io/bitnamilegacy/moodle:4.3
```

Las imágenes son las mismas (tag `4.3` apunta a la última 4.3.x
mantenida — 4.3.10 al 2026-05-22). Soportan amd64 y arm64.

**Tracking**: aplicado en rama `chore/sprint-0-alvaro-infra-qa`.
**Status**: fixed (pendiente de merge a `main`).

**Implicancias a futuro**: el namespace `bitnamilegacy/*` no recibe
actualizaciones de seguridad. Para Fase 2-3 evaluar:
- Pagar Bitnami Secure (verificar plan free para uso académico)
- Migrar a otra imagen comunitaria (`lthub/moodle`, `treehouses/moodle`)
- Build propio basado en `php:8.1-apache` + Moodle source

## [INFRA-002] `php` CLI ejecutado como root rompe permisos de moodledata

**Sprint donde se detectó**: Sprint 0 (operación post-merge)
**Severidad**: Alta (Moodle responde HTTP 500 hasta arreglar permisos)
**Detectado por**: Álvaro · 2026-05-23

**Descripción**: ejecutar `docker compose exec moodle sh -c 'php ...'`
entra al container como usuario `root` por default. Cuando ese comando
genera/modifica archivos en `/bitnami/moodledata/` (típicamente
regenerando caches), los archivos quedan propiedad de `root`. Apache
corre como `daemon`, por lo tanto pierde permisos para escribir/leer
esos archivos y Moodle empieza a devolver:

```
Error
Invalid permissions detected when trying to create a directory.
Turn debugging on for further details.
```

(HTTP 500 a nivel app — el frontend muestra el error genérico, los
logs de Apache solo muestran `GET / HTTP/1.1" 500`.)

**Reproducción**:
1. Stack levantado (`make up`)
2. Ejecutar cualquier `php` CLI de Moodle como root:
   ```bash
   docker compose exec moodle sh -c 'php /bitnami/moodle/admin/cli/purge_caches.php'
   ```
3. Refrescar http://localhost:8080 → error de permisos
4. `docker compose logs moodle | tail -5` → `500 1371`

**Workaround / fix inmediato**:
```bash
docker compose exec moodle sh -c 'chown -R daemon:daemon /bitnami/moodledata'
docker compose restart moodle
```

En ~15 segundos Moodle responde 200 de nuevo.

**Cómo evitar**: ejecutar siempre los scripts CLI de Moodle como
usuario `daemon`:

```bash
# MAL (rompe permisos):
docker compose exec moodle sh -c 'php admin/cli/purge_caches.php'

# BIEN (mantiene permisos):
docker compose exec -u daemon moodle sh -c 'php /bitnami/moodle/admin/cli/purge_caches.php'
```

El nuevo target `make exec` del Makefile entra siempre como `daemon`
para evitar este problema. Ver `docs/operacion-cli-moodle.md` para
referencia completa de comandos seguros.

**Tracking**: descubierto durante operación día 2 post-Sprint 0.
**Status**: documentado + workaround en Makefile (`make exec`).

**Implicancias**: cualquier integrante del equipo que ejecute CLI de
Moodle desde el container sin el flag `-u daemon` va a pegarse contra
esto. Si Sprint 2+ requiere correr más scripts (instalar plugins via
CLI, ejecutar `upgrade.php`, etc.) hay que usar siempre `make exec` o
el flag manual.

## 📚 Referencias

- Issues abiertos en GitHub: https://github.com/Osyanne/Osyanificacion-Plugin-Moodle/issues
- Documentación oficial Moodle dev: https://moodledev.io/docs/4.x
