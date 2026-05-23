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

## 📚 Referencias

- Issues abiertos en GitHub: https://github.com/Osyanne/Osyanificacion-Plugin-Moodle/issues
- Documentación oficial Moodle dev: https://moodledev.io/docs/4.x
