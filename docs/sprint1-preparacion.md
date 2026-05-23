# Sprint 1 — Material preparatorio

> **Propósito**: dejar listo todo lo necesario para que Edison (UI/UX)
> e Imanol (Lead Técnico) arranquen Sprint 1 sin perder tiempo en
> investigación previa, decisiones técnicas o setup de plugins.
>
> **Alcance**: este doc cubre el **trabajo técnico** (instalación de
> plugins, análisis comparativo de themes, paleta CSS lista para usar,
> mockups y templates propuestos) y deja al equipo las **decisiones
> finales de diseño** (variaciones de mockups, ajustes finos de
> tipografía, decisión Boost vs Moove).
>
> **Preparado por**: Álvaro (Infra/QA) el 2026-05-23.
> **Pareja con**: [`docs/plan-fase-1.md`](plan-fase-1.md) Sprint 1
> (líneas 149-170) y los mockups en
> [`presentation/mockups/`](../presentation/mockups/).

## 📋 Tabla de contenidos

- [🎯 Objetivos del Sprint 1](#-objetivos-del-sprint-1)
- [⚠️ Cambio de paleta vs plan original](#️-cambio-de-paleta-vs-plan-original)
- [1. Decisión: Boost-custom vs Moove](#1-decisión-boost-custom-vs-moove)
- [2. Instalación de `format_tiles`](#2-instalación-de-format_tiles)
- [3. Aplicar `format_tiles` a los cursos](#3-aplicar-format_tiles-a-los-cursos)
- [4. Paleta Santo Domingo de Guzmán (B&N) en CSS variables](#4-paleta-santo-domingo-de-guzmán-bn-en-css-variables)
- [5. Tipografía propuesta](#5-tipografía-propuesta)
- [6. Componentes con paleta SDG aplicada](#6-componentes-con-paleta-sdg-aplicada)
- [7. Mockups y templates Mustache propuestos](#7-mockups-y-templates-mustache-propuestos)
- [8. Checklist visual de comparación SDG vs local](#8-checklist-visual-de-comparación-sdg-vs-local)
- [9. Captura de screenshots de referencia](#9-captura-de-screenshots-de-referencia)
- [10. Troubleshooting](#10-troubleshooting)
- [Próximos pasos para Edison](#-próximos-pasos-para-edison)

---

## 🎯 Objetivos del Sprint 1

Según `docs/plan-fase-1.md` (Sprint 1, semana 2):

- [ ] Decidir Boost-custom vs Moove
- [ ] Aplicar paleta institucional al theme elegido
- [ ] Instalar y configurar `format_tiles` en cursos de prueba
- [ ] Tipografía sobria sin Google Fonts
- [ ] Estructura de cursos con prefijo institucional
- [ ] Captura de screenshots comparativos referencia real vs local

**Entregable**: screenshot comparativo lado-a-lado que demuestre
paridad visual razonable.

---

## ⚠️ Cambio de paleta vs plan original

El `docs/plan-fase-1.md` declara paleta UTA azul (`#233A83`). **Este
doc usa la paleta acordada con Álvaro el 2026-05-23**: la del Moodle
de **Santo Domingo de Guzmán** (blanco y negro, look sobrio /
institucional).

Razón del cambio: la referencia visual real elegida pasa a ser SDG en
lugar de UTA. Las paletas B&N son más versátiles para institución
externa (Fase 2) porque no comprometen branding ajeno.

**Si Imanol prefiere mantener la paleta UTA azul del plan original**:
los snippets y mockups acá son intercambiables — solo hay que
reemplazar las variables CSS `--sdg-*` por sus equivalentes `--uta-*`
y la estética cambia automáticamente.

---

## 1. Decisión: Boost-custom vs Moove

### Tabla comparativa

| Aspecto | Boost-custom | Moove |
|---|---|---|
| **Costo** | $0 (ya viene con Moodle) | Licencia paga (~€60/año) o fork community free (calidad variable) |
| **Mantenimiento upstream** | ✅ Moodle core lo mantiene | Pimenko mantiene la versión paga, community la free |
| **Match visual paleta B&N** | 🟢 95% (Boost por defecto ya es sobrio, fácil de monocromar) | 🟡 60% (Moove tiene look colorido que hay que neutralizar) |
| **Curva de aprendizaje** | ✅ Baja (CSS clásico + variables Bootstrap) | 🟡 Media (estructura propia de Moove) |
| **Documentación** | ✅ Extensa (parte del core) | 🟡 Limitada al sitio comercial |
| **Riesgo legal/licencia** | ✅ Cero (GPL del core) | 🟡 La versión free puede no estar actualizada con seguridad |
| **Tiempo de setup paleta B&N** | ~1h (SCSS personalizado) | ~3-4h (overriding del Moove premium) |

### Recomendación: **Boost-custom**

Con paleta B&N sobria, Boost va a quedar **MEJOR que Moove** porque:

1. Moove está pensado para look colorido/moderno — neutralizar todo a
   B&N es ir contra su diseño base
2. Boost por defecto ya es sobrio, solo hay que ajustar variables
   Bootstrap → blanco/negro
3. **Cero costo** (cabe en proyecto académico)
4. Decisión reversible: cambiar el theme en Moodle = 2 clicks

**Si Imanol decide Moove** (no recomendado para paleta B&N):

1. Comprar licencia en https://moodle.org/plugins/theme_moove
2. Verificar versión compatible con Moodle 4.3
3. Descargar el ZIP
4. Site administration → Extensiones → Instalar plugin desde archivo ZIP
5. Site administration → Apariencia → Themes → Theme selector → Moove
6. Customizar desde el panel del propio Moove

**Decisión final: Imanol** (rol Director). Este doc es propuesta, no
decisión.

---

## 2. Instalación de `format_tiles`

`format_tiles` (Davo Smith) es el course format más usado para look de
tarjetas/mosaicos. Versión free es suficiente para Fase 1.

### Método web (~5 min, recomendado)

1. Login como admin en http://localhost:8080
2. **Administración del sitio** → **Extensiones** → **Instalar plugins**
3. Click en **"Instalar plugins desde el directorio de plugins de Moodle"**
4. Si moodle.org falla por `localhost` no accesible → **Plan B (ZIP manual)**

### Método ZIP manual (siempre funciona)

1. Abrir https://moodle.org/plugins/format_tiles
2. Click en **Download** → elegir versión compatible con Moodle 4.3
3. Se descarga un `.zip` (~3-5 MB)
4. Volver a Moodle: **Administración del sitio** → **Extensiones** →
   **Instalar plugins** → **Instalar plugin desde archivo ZIP**
5. Arrastrar el ZIP al área de upload
6. **Instalar plugin desde archivo ZIP**
7. Confirmar versión + dependencias → **Continuar**
8. **Actualizar base de datos Moodle ahora**
9. Configurar el plugin → dejar defaults → **Guardar**

### Verificar instalación

```bash
docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SHOW TABLES LIKE '"'"'mdl_format_tiles%'"'"';"'

docker compose exec mariadb sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" bitnami_moodle \
   -e "SELECT name, value FROM mdl_config_plugins \
       WHERE plugin = '"'"'format_tiles'"'"' AND name = '"'"'version'"'"';"'
```

---

## 3. Aplicar `format_tiles` a los cursos

### Para el curso ALG-DEMO existente

#### Opción A: Vía UI (recomendado)

1. Entrar al curso `(SOF) Algoritmos y Lógica de Programación - DEMO`
2. **Configuración** (pestaña arriba)
3. Sección **Formato de curso** → desplegable **Formato**
4. Seleccionar **Mosaicos** (Tiles)
5. **Guardar cambios y mostrar**

#### Opción B: Vía SQL (para automatizar)

```sql
UPDATE mdl_course SET format = 'tiles' WHERE shortname = 'ALG-DEMO';
```

Después purgar cache:

```bash
docker compose exec moodle sh -c \
  'php /bitnami/moodle/admin/cli/purge_caches.php'
```

### Para todos los cursos nuevos por default

1. **Administración del sitio** → **Cursos** → **Configuraciones del curso por defecto**
2. **Formato del curso** → **Mosaicos**
3. **Guardar cambios**

---

## 4. Paleta Santo Domingo de Guzmán (B&N) en CSS variables

Paleta sobria, monocromática, institucional. Pensada para ser legible
en cualquier contexto y no comprometer branding ajeno.

```css
:root {
  /* ============================================================ */
  /* Paleta Santo Domingo de Guzmán — escala monocromática        */
  /* ============================================================ */

  /* Escala de grises */
  --sdg-black:         #000000;  /* navbar, headings primarios */
  --sdg-near-black:    #1A1A1A;  /* texto principal */
  --sdg-dark-gray:     #4A4A4A;  /* texto secundario */
  --sdg-mid-gray:      #767676;  /* texto deshabilitado, iconos */
  --sdg-light-gray:    #D9D9D9;  /* bordes, separadores */
  --sdg-very-light:    #F5F5F5;  /* fondos sutiles, hover states */
  --sdg-white:         #FFFFFF;  /* fondo principal de cards */

  /* Acento único para destacar elementos críticos
     (solo cuando es estrictamente necesario:
     "TÚ" en leaderboard, alertas, CTAs primarios) */
  --sdg-accent:        #C5A572;  /* dorado suave (legacy, refinado) */
  --sdg-accent-light:  #E8D9B8;  /* dorado bg para highlights */
  --sdg-accent-dark:   #8B7548;  /* dorado para hover */

  /* Estados (mínimos, monocromáticos) */
  --sdg-success:       #2E7D32;  /* verde solo para "completado" */
  --sdg-danger:        #C62828;  /* rojo solo para errores críticos */

  /* Componentes */
  --sdg-card-radius:   4px;      /* MÁS sobrio que 8px típico */
  --sdg-input-radius:  2px;      /* casi cuadrado, institucional */

  /* Sombras: mínimas, casi planas */
  --sdg-shadow-sm:     0 1px 0 rgba(0, 0, 0, 0.04);
  --sdg-shadow-md:     0 2px 4px rgba(0, 0, 0, 0.06);
  --sdg-shadow-lg:     0 4px 8px rgba(0, 0, 0, 0.08);

  /* Bordes: hairline para look refinado */
  --sdg-border:        1px solid var(--sdg-light-gray);
  --sdg-border-dark:   1px solid var(--sdg-mid-gray);
}
```

### Filosofía de la paleta

- **0 saturación** (excepto acento dorado y estados crítico) = look
  institucional sobrio
- **Sombras casi planas** (no muchos `box-shadow` grandes) = look
  refinado, no "Material Design popero"
- **Border-radius mínimo** (4px) = institucional, no friendly-startup
- **Hairline borders** (1px gris claro) en lugar de sombras = sobrio
- **Acento dorado** muy puntual, no genérico

### Cómo aplicar (en Boost theme)

#### Opción A: SCSS personalizado vía Site administration

1. **Administración del sitio** → **Apariencia** → **Boost** → **Avanzado**
2. Sección **SCSS personalizado al final**
3. Pegar el bloque de arriba + sobreescribir variables Bootstrap:

   ```scss
   :root {
     /* ... bloque de variables --sdg-* de arriba ... */

     /* Override de Bootstrap para que Boost use SDG */
     --bs-body-bg: var(--sdg-white);
     --bs-body-color: var(--sdg-near-black);
     --bs-primary: var(--sdg-black);
     --bs-primary-rgb: 0, 0, 0;
     --bs-secondary: var(--sdg-dark-gray);
     --bs-border-color: var(--sdg-light-gray);
     --bs-border-radius: var(--sdg-card-radius);
   }

   body {
     background-color: var(--sdg-white);
     color: var(--sdg-near-black);
     font-family: var(--sdg-font-stack);
   }

   .navbar {
     background-color: var(--sdg-black) !important;
     border-bottom: 1px solid var(--sdg-dark-gray);
   }

   .navbar .nav-link,
   .navbar .navbar-brand {
     color: var(--sdg-white) !important;
   }

   .btn-primary {
     background-color: var(--sdg-black);
     border-color: var(--sdg-black);
     color: var(--sdg-white);
     border-radius: var(--sdg-card-radius);
   }

   .btn-primary:hover {
     background-color: var(--sdg-near-black);
     border-color: var(--sdg-near-black);
   }

   .card {
     border-radius: var(--sdg-card-radius);
     border: var(--sdg-border);
     box-shadow: var(--sdg-shadow-sm);
   }
   ```

4. **Guardar tema** + purgar cache.

#### Opción B: archivo CSS en plugin propio (Sprint 2+)

Cuando exista `code/local/osyanificacion/`, crear:

```
code/local/osyanificacion/
└── styles.css      ← contenido de :root + overrides
```

Moodle lo carga automáticamente. CSS plano (sin Tailwind/Webpack).

---

## 5. Tipografía propuesta

### Por qué NO Google Fonts

- ✅ **Performance**: 0 requests externos
- ✅ **Privacidad**: no traquea a usuarios (GDPR/LOPDP compliant)
- ✅ **Offline-first**: funciona sin internet
- ✅ **Estética institucional** sin compromisos de hosting de terceros

### Stack propuesto

```css
:root {
  /* Sans serif principal — system stack con preferencia institucional */
  --sdg-font-stack: -apple-system, BlinkMacSystemFont, "Segoe UI",
                    Roboto, Oxygen-Sans, Ubuntu, Cantarell,
                    "Helvetica Neue", Arial, sans-serif;

  /* Serif para títulos formales (opcional, decisión Edison) */
  --sdg-font-serif: Georgia, "Times New Roman", Times, serif;

  /* Monoespaciada para código */
  --sdg-font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco,
                   Consolas, "Liberation Mono", "Courier New", monospace;
}
```

### Escala tipográfica (propuesta sobria)

```css
:root {
  --sdg-text-xs:    0.75rem;   /* 12px - labels, captions */
  --sdg-text-sm:    0.875rem;  /* 14px - texto secundario */
  --sdg-text-base:  1rem;      /* 16px - cuerpo */
  --sdg-text-lg:    1.125rem;  /* 18px - subtítulos */
  --sdg-text-xl:    1.5rem;    /* 24px - títulos sección */
  --sdg-text-2xl:   2rem;      /* 32px - títulos página */
  --sdg-text-3xl:   2.5rem;    /* 40px - hero/landing */

  --sdg-leading-tight:  1.2;
  --sdg-leading-normal: 1.5;
  --sdg-leading-loose:  1.75;

  --sdg-weight-normal:  400;
  --sdg-weight-medium:  500;
  --sdg-weight-bold:    700;
}
```

### Decisión final

**Edison puede ajustar libremente**. La propuesta privilegia:
- **Legibilidad** (cuerpo 16px, leading 1.5)
- **Consistencia** con sistemas operativos (system stack)
- **Sin estética "fancy"** (sin fonts decorativas)

Si Edison prefiere fonts específicas (ej. **Inter**, **Source Sans
Pro**), pueden sumarse al stack como primer fallback antes de
`-apple-system`. Pero **NO Google Fonts hosting** — debería ser
self-hosted.

---

## 6. Componentes con paleta SDG aplicada

Mini snippets ready-to-use. **Edison puede ajustar libremente**.

### Botón primario

```css
.btn-primary {
  background-color: var(--sdg-black);
  border: 1px solid var(--sdg-black);
  color: var(--sdg-white);
  padding: 0.5rem 1.25rem;
  border-radius: var(--sdg-card-radius);
  font-weight: var(--sdg-weight-medium);
  letter-spacing: 0.025em;
  transition: background-color 0.15s, border-color 0.15s;
}

.btn-primary:hover {
  background-color: var(--sdg-near-black);
  border-color: var(--sdg-near-black);
}

.btn-secondary {
  background-color: transparent;
  border: 1px solid var(--sdg-black);
  color: var(--sdg-black);
}

.btn-secondary:hover {
  background-color: var(--sdg-very-light);
}
```

### Card (curso/actividad)

```css
.card {
  background-color: var(--sdg-white);
  border: var(--sdg-border);
  border-radius: var(--sdg-card-radius);
  box-shadow: var(--sdg-shadow-sm);
  padding: 1rem;
  transition: box-shadow 0.2s, border-color 0.2s;
}

.card:hover {
  box-shadow: var(--sdg-shadow-md);
  border-color: var(--sdg-mid-gray);
}

.card-header {
  font-weight: var(--sdg-weight-bold);
  color: var(--sdg-black);
  border-bottom: var(--sdg-border);
  padding-bottom: 0.5rem;
  margin-bottom: 0.75rem;
}
```

### Highlight "TÚ" en leaderboard (Sprint 3)

```css
.leaderboard-row {
  padding: 0.5rem 0.75rem;
  border-bottom: var(--sdg-border);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.leaderboard-row--current-user {
  background-color: var(--sdg-accent-light);
  border-left: 3px solid var(--sdg-accent);
  font-weight: var(--sdg-weight-bold);
  padding-left: 0.5rem;
}

.leaderboard-row--current-user .username::before {
  content: "TÚ → ";
  color: var(--sdg-accent-dark);
  font-weight: var(--sdg-weight-bold);
}

.leaderboard-rank {
  font-family: var(--sdg-font-mono);
  font-size: var(--sdg-text-sm);
  color: var(--sdg-mid-gray);
  min-width: 2rem;
}

.leaderboard-xp {
  margin-left: auto;
  color: var(--sdg-near-black);
  font-weight: var(--sdg-weight-medium);
}
```

### Badge de nivel (XP)

```css
.xp-level-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background-color: var(--sdg-black);
  color: var(--sdg-white);
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 50%;
  font-weight: var(--sdg-weight-bold);
  font-size: var(--sdg-text-lg);
}

.xp-progress-bar {
  width: 100%;
  height: 6px;
  background-color: var(--sdg-light-gray);
  border-radius: 999px;
  overflow: hidden;
  margin-top: 0.5rem;
}

.xp-progress-fill {
  height: 100%;
  background-color: var(--sdg-black);
  transition: width 0.3s ease-out;
}
```

### Navbar (look institucional)

```css
.navbar {
  background-color: var(--sdg-black);
  border-bottom: 1px solid var(--sdg-dark-gray);
  padding: 0.75rem 1rem;
}

.navbar-brand {
  color: var(--sdg-white);
  font-weight: var(--sdg-weight-bold);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  font-size: var(--sdg-text-base);
}

.navbar .nav-link {
  color: var(--sdg-very-light);
  padding: 0.5rem 1rem;
  transition: color 0.15s;
}

.navbar .nav-link:hover,
.navbar .nav-link.active {
  color: var(--sdg-white);
  border-bottom: 2px solid var(--sdg-white);
}
```

---

## 7. Mockups y templates Mustache propuestos

Ver carpeta [`presentation/mockups/`](../presentation/mockups/):

| Archivo | Qué muestra |
|---|---|
| `presentation/mockups/README.md` | Index + cómo abrir los mockups |
| `presentation/mockups/dashboard-mockup.html` | Mockup HTML standalone del Dashboard del curso con bloque XP, paleta SDG aplicada |
| `presentation/mockups/leaderboard-mockup.html` | Mockup del leaderboard ±5 con highlight "TÚ" en dorado SDG |
| `presentation/mockups/templates/xp-widget-osyanificacion.mustache` | Template Mustache **propuesto** para override del `xp-widget.mustache` original cuando exista `local_osyanificacion` |

**Cómo verlos**:

```bash
# Desde la carpeta del repo
start presentation/mockups/dashboard-mockup.html
# (Windows; en Linux/Mac: open o xdg-open)
```

Los mockups son **HTML+CSS standalone** (cero dependencias, no se
abren en el Moodle todavía). Sirven como **referencia visual** para
Edison cuando aplique los SCSS y override de templates.

### Override de templates Mustache: cómo funciona

Moodle 4.x permite **sobrescribir templates de cualquier plugin** sin
modificar el código original. La convención:

```
code/local/osyanificacion/templates/block_xp/<nombre>.mustache
```

Moodle prioriza ese template sobre el de `blocks/xp/templates/<nombre>.mustache`.

**Implicancia**: cuando Sprint 2 cree el plugin propio, Edison puede
copiar los templates de Level Up XP que quiera customizar a la carpeta
`templates/block_xp/` de nuestro plugin y modificarlos sin tocar el
plugin original. Sigue siendo wrappeo limpio, sin fork modificado.

---

## 8. Checklist visual de comparación SDG vs local

Edison usa esta lista para validar que el theme replicado se parece al
SDG real "lo suficiente" para Fase 1.

### Header / Navbar

- [ ] Color de fondo del navbar = `#000000` (negro puro)
- [ ] Logo del sitio visible (placeholder "Osyanificación" si no hay
      logo institucional)
- [ ] Menú principal con items: Página Principal, Área personal, Mis cursos
- [ ] Texto del navbar = `#FFFFFF`
- [ ] Avatar del usuario arriba a la derecha
- [ ] Hover state en links del navbar = border-bottom blanco

### Dashboard (Área personal)

- [ ] Fondo principal `#FFFFFF` o `#F5F5F5`
- [ ] Cards de "Mis cursos" en grilla (no lista)
- [ ] Cada card con: nombre del curso, prefijo `(SOF)` o el institucional
- [ ] Border-radius `4px` en cards (sobrio, no friendly)
- [ ] Border hairline `1px solid #D9D9D9`
- [ ] Sombras CASI planas (`box-shadow: 0 1px 0 rgba(0,0,0,0.04)`)
- [ ] Hover state visible: sombra un poco más fuerte + border más oscuro

### Curso (formato Tiles)

- [ ] Secciones del curso renderizan como mosaicos
- [ ] Mosaicos en grilla responsive (2-4 columnas según ancho)
- [ ] Cada mosaico con: número de sección, título, ícono opcional
- [ ] Mosaicos en B&N (sin colores saturados)
- [ ] Bloque de Level Up XP visible en columna derecha
- [ ] Badge de nivel en círculo negro con número blanco

### Tipografía

- [ ] Texto principal con system stack (sin Google Fonts cargados)
- [ ] Cuerpo 16px (`--sdg-text-base`)
- [ ] Leading 1.5 en párrafos
- [ ] Headings en negro puro (`#000000` o `#1A1A1A`)
- [ ] Sin font-weights raros (solo 400, 500, 700)

### Accesibilidad básica

- [ ] Contraste WCAG **AAA** posible con B&N (verificar con devtools)
- [ ] Focus visible en links y botones (no `outline: none` sin
      reemplazo claro)
- [ ] Tamaño de tap targets ≥ 44x44px en mobile
- [ ] Ancho máximo de texto ≤ 70 caracteres (legibilidad)

### Leaderboard (preview Sprint 3)

- [ ] Filas con border-bottom hairline
- [ ] Fila del usuario actual con bg dorado claro
      (`var(--sdg-accent-light)`) y border-left dorado
- [ ] Prefijo "TÚ → " visible
- [ ] XP alineado a la derecha
- [ ] Rank numérico en mono-font, gris medio

---

## 9. Captura de screenshots de referencia

Edison necesita **screenshots del Moodle real de Santo Domingo de
Guzmán** como referencia visual.

### Si tenés acceso a un Moodle SDG real

1. Capturar **home pública** (sin login) — logo, navbar, layout
2. **Dashboard** del estudiante con varias materias (difuminar nombres)
3. **1 curso completo** con su formato (Tiles si lo usan)
4. **1 actividad** (Quiz, Tarea)

### Si NO tenés acceso

Opciones:
- Pedir a algún contacto de SDG screenshots
- Buscar screenshots en redes sociales / sitio institucional público
- Usar el **Moodle UTA** como fallback (`sistemaseducaciononline.uta.edu.ec`)
  y **rebrandear mentalmente** a B&N

### Carpeta sugerida

```
presentation/
└── screenshots-referencia/
    ├── sdg-real/                    ← capturas del Moodle SDG real
    │   ├── 01-home.png
    │   ├── 02-dashboard.png
    │   ├── 03-curso-tiles.png
    │   └── 04-actividad.png
    └── local-replica/               ← capturas del nuestro tras aplicar paleta
        ├── 01-home.png
        ├── 02-dashboard.png
        └── ...
```

⚠️ **NO commitear screenshots con datos personales reales** (nombres,
emails, fotos de personas reales). Difuminar o tachar antes de
commitear.

---

## 10. Troubleshooting

### `format_tiles` instalado pero no aparece en el dropdown del curso

```bash
docker compose exec moodle sh -c \
  'php /bitnami/moodle/admin/cli/purge_caches.php'
```

Después Ctrl+F5.

### El SCSS custom no se aplica al theme

1. Site administration → Desarrollo → **Purgar todas las cachés**
2. CLI: `docker compose exec moodle sh -c 'php /bitnami/moodle/admin/cli/purge_caches.php'`
3. Ctrl+F5

### Las cards no toman `border-radius`

Selector más específico de Boost ganando. Usar `!important` en SCSS
custom del theme:

```scss
.card {
  border-radius: var(--sdg-card-radius) !important;
}
```

### El navbar no toma color negro

Boost usa `--bs-primary` Bootstrap. Declarar:

```scss
:root {
  --bs-primary: var(--sdg-black);
  --bs-primary-rgb: 0, 0, 0;
}
```

### Formato Tiles muestra "Esta característica requiere XP+"

Features paywalled del plugin premium. Ignorar o configurar el plugin
para desactivar las features premium en Site administration →
Extensiones → format_tiles.

---

## ✅ Próximos pasos para Edison

Cuando arranque Sprint 1 (idealmente con Imanol acompañando las
decisiones de scope):

1. **Leer este doc completo** (~15 min)
2. **Abrir los mockups HTML** en navegador para ver el look propuesto
   (~5 min)
3. **Confirmar decisión Boost-custom** con Imanol (~5 min)
4. **Confirmar paleta SDG B&N** vs UTA azul (~5 min — ya cambió el
   alcance, validar)
5. **Instalar `format_tiles`** siguiendo sección 2 (~5 min)
6. **Aplicar formato Tiles al curso ALG-DEMO** siguiendo sección 3 (~2 min)
7. **Capturar baseline visual** del Moodle ANTES de tocar SCSS (~5 min)
8. **Aplicar paleta SDG** vía SCSS custom siguiendo sección 4 (~30 min)
9. **Capturar after visual** y comparar con baseline (~10 min)
10. **Validar checklist** sección 8 (~20 min)
11. **Screenshots comparativos** sección 9 (~30 min)
12. **Copiar templates Mustache propuestos** de `presentation/mockups/templates/`
    a `code/local/osyanificacion/templates/block_xp/` cuando Imanol haya
    creado el plugin en Sprint 2

**Tiempo total estimado**: ~2.5 horas para todo el Sprint 1 visual.

### Lo que NO está en este doc (Edison decide)

- Variaciones de los mockups propuestos (puede rediseñar)
- Tipografía específica diferente al system stack
- Componentes custom más allá de los snippets sugeridos
- Decisión final entre paleta SDG (propuesta de Álvaro) vs UTA del
  plan original

---

## ⚠️ Notas del autor

- Este doc lo preparó **Álvaro** (rol Infra/QA) cubriendo lo técnico
  porque Edison no estaba disponible. **NO reemplaza a Edison** — solo
  desbloquea su trabajo para que arranque directo en la parte de
  diseño visual.
- **Pivot de paleta**: el plan-fase-1.md oficial dice paleta UTA azul
  (`#233A83`). Por pedido de Álvaro el 2026-05-23 se pivotó a paleta
  Santo Domingo de Guzmán (B&N). Si Imanol prefiere mantener la
  original, los snippets/mockups acá son intercambiables — solo
  reemplazar `--sdg-*` por `--uta-*`.
- Cualquier desviación → ajustar este doc + commit
  `docs(infra): ajustar sprint1-preparacion según feedback`.
