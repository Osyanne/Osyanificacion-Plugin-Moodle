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

> 🎨 **DECISIÓN DE PALETA — FINAL (2026-05-29)**: la paleta oficial es
> **UTA azul `#233A83`** (la del `plan-fase-1.md` original). El breve
> pivot a "Santo Domingo de Guzmán" (B&N) del 2026-05-23 quedó
> **descartado**. Este documento fue actualizado a UTA: variables
> `--uta-*`, navbar/botones/badges en azul `#233A83`, texto en
> `#1D2125` y acento dorado `#F59E0B` reservado para el highlight "TÚ".

## 📋 Tabla de contenidos

- [🎯 Objetivos del Sprint 1](#-objetivos-del-sprint-1)
- [⚠️ Cambio de paleta vs plan original](#️-cambio-de-paleta-vs-plan-original)
- [1. Decisión: Boost-custom vs Moove](#1-decisión-boost-custom-vs-moove)
- [2. Instalación de `format_tiles`](#2-instalación-de-format_tiles)
- [3. Aplicar `format_tiles` a los cursos](#3-aplicar-format_tiles-a-los-cursos)
- [4. Paleta UTA (azul #233A83) en CSS variables](#4-paleta-uta-azul-233a83-en-css-variables)
- [5. Tipografía propuesta](#5-tipografía-propuesta)
- [6. Componentes con paleta UTA aplicada](#6-componentes-con-paleta-uta-aplicada)
- [7. Mockups y templates Mustache propuestos](#7-mockups-y-templates-mustache-propuestos)
- [8. Checklist visual de comparación UTA vs local](#8-checklist-visual-de-comparación-uta-vs-local)
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

## ⚠️ Paleta: decisión final (UTA)

El `docs/plan-fase-1.md` declara paleta **UTA azul (`#233A83`)** y esa
es la **decisión final** confirmada por Imanol el 2026-05-29.

Historia breve: el 2026-05-23 se exploró un pivot a una paleta B&N tipo
"Santo Domingo de Guzmán" (más neutra para una eventual institución
externa en Fase 2). Ese pivot se **descartó**: para Fase 1 la
referencia es UTA y el azul institucional da identidad clara a la demo.

Todos los snippets y mockups de este documento ya usan las variables
`--uta-*`. El acento dorado (`#F59E0B`) se mantiene, pero solo para
destacar al usuario actual ("TÚ") en el leaderboard.

---

## 1. Decisión: Boost-custom vs Moove

### Tabla comparativa

| Aspecto | Boost-custom | Moove |
|---|---|---|
| **Costo** | $0 (ya viene con Moodle) | Licencia paga (~€60/año) o fork community free (calidad variable) |
| **Mantenimiento upstream** | ✅ Moodle core lo mantiene | Pimenko mantiene la versión paga, community la free |
| **Match visual paleta UTA** | 🟢 90% (Boost recolorea a azul UTA con variables Bootstrap) | 🟡 60% (Moove trae su propio look que hay que sobrescribir) |
| **Curva de aprendizaje** | ✅ Baja (CSS clásico + variables Bootstrap) | 🟡 Media (estructura propia de Moove) |
| **Documentación** | ✅ Extensa (parte del core) | 🟡 Limitada al sitio comercial |
| **Riesgo legal/licencia** | ✅ Cero (GPL del core) | 🟡 La versión free puede no estar actualizada con seguridad |
| **Tiempo de setup paleta UTA** | ~1h (SCSS personalizado) | ~3-4h (overriding del Moove premium) |

### Recomendación: **Boost-custom**

Con la paleta UTA, Boost va a quedar **MEJOR que Moove** porque:

1. Moove trae su propio look/branding — sobrescribirlo al azul UTA es
   ir contra su diseño base
2. Boost es neutro de fábrica, solo hay que ajustar variables
   Bootstrap → azul UTA `#233A83`
3. **Cero costo** (cabe en proyecto académico)
4. Decisión reversible: cambiar el theme en Moodle = 2 clicks

**Si Imanol decide Moove** (no recomendado para la paleta UTA):

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

## 4. Paleta UTA (azul #233A83) en CSS variables

Paleta institucional UTA: azul `#233A83` sobre fondo claro, con un
acento dorado reservado para el highlight "TÚ". Misma paleta que el
theme real en [`docs/uta-boost-scss.css`](uta-boost-scss.css).

```css
:root {
  /* ============================================================ */
  /* Paleta UTA — Universidad Técnica de Ambato (#233A83)         */
  /* ============================================================ */

  /* Azules UTA */
  --uta-primary:       #233A83;  /* navbar, botones, badges, links */
  --uta-primary-light: #2E4BA8;  /* hover claro, detalles */
  --uta-primary-dark:  #1A2D66;  /* hover/bordes oscuros */

  /* Escala de neutros */
  --uta-black:         #1D2125;  /* headings y texto principal */
  --uta-dark-gray:     #4A4F55;  /* texto secundario */
  --uta-mid-gray:      #6B7280;  /* texto deshabilitado, iconos */
  --uta-light-gray:    #D1D5DB;  /* bordes, separadores */
  --uta-very-light:    #F2F3F7;  /* fondos sutiles, hover states */
  --uta-white:         #FFFFFF;  /* fondo principal de cards */

  /* Acento dorado SOLO para destacar al usuario actual ("TÚ") */
  --uta-gold:          #F59E0B;  /* dorado highlight */
  --uta-gold-light:    #FEF3C7;  /* dorado bg para highlights */
  --uta-gold-dark:     #D97706;  /* dorado para hover/texto */

  /* Estados */
  --uta-success:       #10B981;  /* verde "completado" */
  --uta-danger:        #EF4444;  /* rojo errores críticos */

  /* Componentes */
  --uta-card-radius:   8px;      /* sobrio institucional */
  --uta-input-radius:  4px;

  /* Sombras suaves */
  --uta-shadow-sm:     0 1px 3px rgba(0, 0, 0, 0.10), 0 1px 2px rgba(0, 0, 0, 0.06);
  --uta-shadow-md:     0 4px 6px rgba(0, 0, 0, 0.10), 0 2px 4px rgba(0, 0, 0, 0.06);
  --uta-shadow-lg:     0 10px 15px rgba(0, 0, 0, 0.10), 0 4px 6px rgba(0, 0, 0, 0.05);

  /* Bordes */
  --uta-border:        1px solid var(--uta-light-gray);
  --uta-border-dark:   1px solid var(--uta-mid-gray);
}
```

### Filosofía de la paleta

- **Azul UTA dominante** (`#233A83`) en navbar, botones y badges = identidad institucional clara
- **Fondo claro** (`#F2F3F7` / blanco) para legibilidad
- **Acento dorado** (`#F59E0B`) reservado al highlight "TÚ", no genérico
- **Border-radius 8px** alineado al theme real (`uta-boost-scss.css`)
- **Sombras suaves** + hairline borders para un look limpio

### Cómo aplicar (en Boost theme)

#### Opción A: SCSS personalizado vía Site administration

1. **Administración del sitio** → **Apariencia** → **Boost** → **Avanzado**
2. Sección **SCSS personalizado al final**
3. Pegar el bloque de arriba + sobreescribir variables Bootstrap:

   ```scss
   :root {
     /* ... bloque de variables --uta-* de arriba ... */

     /* Override de Bootstrap para que Boost use la paleta UTA */
     --bs-body-bg: var(--uta-white);
     --bs-body-color: var(--uta-black);
     --bs-primary: var(--uta-primary);
     --bs-primary-rgb: 35, 58, 131;
     --bs-secondary: var(--uta-dark-gray);
     --bs-border-color: var(--uta-light-gray);
     --bs-border-radius: var(--uta-card-radius);
   }

   body {
     background-color: var(--uta-very-light);
     color: var(--uta-black);
     font-family: var(--uta-font-stack);
   }

   .navbar {
     background-color: var(--uta-primary) !important;
     border-bottom: 1px solid var(--uta-primary-dark);
   }

   .navbar .nav-link,
   .navbar .navbar-brand {
     color: var(--uta-white) !important;
   }

   .btn-primary {
     background-color: var(--uta-primary);
     border-color: var(--uta-primary);
     color: var(--uta-white);
     border-radius: var(--uta-card-radius);
   }

   .btn-primary:hover {
     background-color: var(--uta-primary-dark);
     border-color: var(--uta-primary-dark);
   }

   .card {
     border-radius: var(--uta-card-radius);
     border: var(--uta-border);
     box-shadow: var(--uta-shadow-sm);
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
  --uta-font-stack: -apple-system, BlinkMacSystemFont, "Segoe UI",
                    Roboto, Oxygen-Sans, Ubuntu, Cantarell,
                    "Helvetica Neue", Arial, sans-serif;

  /* Serif para títulos formales (opcional, decisión Edison) */
  --uta-font-serif: Georgia, "Times New Roman", Times, serif;

  /* Monoespaciada para código */
  --uta-font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco,
                   Consolas, "Liberation Mono", "Courier New", monospace;
}
```

### Escala tipográfica (propuesta sobria)

```css
:root {
  --uta-text-xs:    0.75rem;   /* 12px - labels, captions */
  --uta-text-sm:    0.875rem;  /* 14px - texto secundario */
  --uta-text-base:  1rem;      /* 16px - cuerpo */
  --uta-text-lg:    1.125rem;  /* 18px - subtítulos */
  --uta-text-xl:    1.5rem;    /* 24px - títulos sección */
  --uta-text-2xl:   2rem;      /* 32px - títulos página */
  --uta-text-3xl:   2.5rem;    /* 40px - hero/landing */

  --uta-leading-tight:  1.2;
  --uta-leading-normal: 1.5;
  --uta-leading-loose:  1.75;

  --uta-weight-normal:  400;
  --uta-weight-medium:  500;
  --uta-weight-bold:    700;
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

## 6. Componentes con paleta UTA aplicada

Mini snippets ready-to-use. **Edison puede ajustar libremente**.

### Botón primario

```css
.btn-primary {
  background-color: var(--uta-primary);
  border: 1px solid var(--uta-primary);
  color: var(--uta-white);
  padding: 0.5rem 1.25rem;
  border-radius: var(--uta-card-radius);
  font-weight: var(--uta-weight-medium);
  letter-spacing: 0.025em;
  transition: background-color 0.15s, border-color 0.15s;
}

.btn-primary:hover {
  background-color: var(--uta-primary-dark);
  border-color: var(--uta-primary-dark);
}

.btn-secondary {
  background-color: transparent;
  border: 1px solid var(--uta-primary);
  color: var(--uta-primary);
}

.btn-secondary:hover {
  background-color: var(--uta-very-light);
}
```

### Card (curso/actividad)

```css
.card {
  background-color: var(--uta-white);
  border: var(--uta-border);
  border-radius: var(--uta-card-radius);
  box-shadow: var(--uta-shadow-sm);
  padding: 1rem;
  transition: box-shadow 0.2s, border-color 0.2s;
}

.card:hover {
  box-shadow: var(--uta-shadow-md);
  border-color: var(--uta-mid-gray);
}

.card-header {
  font-weight: var(--uta-weight-bold);
  color: var(--uta-black);
  border-bottom: var(--uta-border);
  padding-bottom: 0.5rem;
  margin-bottom: 0.75rem;
}
```

### Highlight "TÚ" en leaderboard (Sprint 3)

```css
.leaderboard-row {
  padding: 0.5rem 0.75rem;
  border-bottom: var(--uta-border);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.leaderboard-row--current-user {
  background-color: var(--uta-gold-light);
  border-left: 3px solid var(--uta-gold);
  font-weight: var(--uta-weight-bold);
  padding-left: 0.5rem;
}

.leaderboard-row--current-user .username::before {
  content: "TÚ → ";
  color: var(--uta-gold-dark);
  font-weight: var(--uta-weight-bold);
}

.leaderboard-rank {
  font-family: var(--uta-font-mono);
  font-size: var(--uta-text-sm);
  color: var(--uta-mid-gray);
  min-width: 2rem;
}

.leaderboard-xp {
  margin-left: auto;
  color: var(--uta-black);
  font-weight: var(--uta-weight-medium);
}
```

### Badge de nivel (XP)

```css
.xp-level-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background-color: var(--uta-primary);
  color: var(--uta-white);
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 50%;
  font-weight: var(--uta-weight-bold);
  font-size: var(--uta-text-lg);
}

.xp-progress-bar {
  width: 100%;
  height: 6px;
  background-color: var(--uta-light-gray);
  border-radius: 999px;
  overflow: hidden;
  margin-top: 0.5rem;
}

.xp-progress-fill {
  height: 100%;
  background-color: var(--uta-primary);
  transition: width 0.3s ease-out;
}
```

### Navbar (look institucional)

```css
.navbar {
  background-color: var(--uta-primary);
  border-bottom: 1px solid var(--uta-primary-dark);
  padding: 0.75rem 1rem;
}

.navbar-brand {
  color: var(--uta-white);
  font-weight: var(--uta-weight-bold);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  font-size: var(--uta-text-base);
}

.navbar .nav-link {
  color: rgba(255, 255, 255, 0.82);
  padding: 0.5rem 1rem;
  transition: color 0.15s;
}

.navbar .nav-link:hover,
.navbar .nav-link.active {
  color: var(--uta-white);
  border-bottom: 2px solid var(--uta-white);
}
```

---

## 7. Mockups y templates Mustache propuestos

Ver carpeta [`presentation/mockups/`](../presentation/mockups/):

| Archivo | Qué muestra |
|---|---|
| `presentation/mockups/README.md` | Index + cómo abrir los mockups |
| `presentation/mockups/dashboard-mockup.html` | Mockup HTML standalone del Dashboard del curso con bloque XP, paleta UTA aplicada |
| `presentation/mockups/leaderboard-mockup.html` | Mockup del leaderboard ±5 con highlight "TÚ" en dorado |
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

## 8. Checklist visual de comparación UTA vs local

Edison usa esta lista para validar que el theme replicado se parece a
la referencia UTA "lo suficiente" para Fase 1.

### Header / Navbar

- [ ] Color de fondo del navbar = `#233A83` (azul UTA)
- [ ] Logo del sitio visible (placeholder "Osyanificación" si no hay
      logo institucional)
- [ ] Menú principal con items: Página Principal, Área personal, Mis cursos
- [ ] Texto del navbar = `#FFFFFF`
- [ ] Avatar del usuario arriba a la derecha
- [ ] Hover state en links del navbar = border-bottom blanco

### Dashboard (Área personal)

- [ ] Fondo principal `#FFFFFF` o `#F2F3F7`
- [ ] Cards de "Mis cursos" en grilla (no lista)
- [ ] Cada card con: nombre del curso, prefijo `(SOF)` o el institucional
- [ ] Border-radius `8px` en cards (sobrio institucional)
- [ ] Border hairline `1px solid #D1D5DB`
- [ ] Sombras suaves (`box-shadow: 0 1px 3px rgba(0,0,0,0.10)`)
- [ ] Hover state visible: sombra un poco más fuerte + border más oscuro

### Curso (formato Tiles)

- [ ] Secciones del curso renderizan como mosaicos
- [ ] Mosaicos en grilla responsive (2-4 columnas según ancho)
- [ ] Cada mosaico con: número de sección, título, ícono opcional
- [ ] Mosaicos con número en círculo azul UTA (sin colores chillones extra)
- [ ] Bloque de Level Up XP visible en columna derecha
- [ ] Badge de nivel en círculo azul UTA con número blanco

### Tipografía

- [ ] Texto principal con system stack (sin Google Fonts cargados)
- [ ] Cuerpo 16px (`--uta-text-base`)
- [ ] Leading 1.5 en párrafos
- [ ] Headings en `#1D2125` (`--uta-black`)
- [ ] Sin font-weights raros (solo 400, 500, 700)

### Accesibilidad básica

- [ ] Contraste WCAG **AA** en azul UTA sobre blanco (verificar con devtools)
- [ ] Focus visible en links y botones (no `outline: none` sin
      reemplazo claro)
- [ ] Tamaño de tap targets ≥ 44x44px en mobile
- [ ] Ancho máximo de texto ≤ 70 caracteres (legibilidad)

### Leaderboard (preview Sprint 3)

- [ ] Filas con border-bottom hairline
- [ ] Fila del usuario actual con bg dorado claro
      (`var(--uta-gold-light)`) y border-left dorado
- [ ] Prefijo "TÚ → " visible
- [ ] XP alineado a la derecha
- [ ] Rank numérico en mono-font, gris medio

---

## 9. Captura de screenshots de referencia

Edison necesita **screenshots del Moodle de referencia UTA**
(`sistemaseducaciononline.uta.edu.ec`) como guía visual.

### Si tenés acceso al Moodle UTA

1. Capturar **home pública** (sin login) — logo, navbar, layout
2. **Dashboard** del estudiante con varias materias (difuminar nombres)
3. **1 curso completo** con su formato (Tiles si lo usan)
4. **1 actividad** (Quiz, Tarea)

> ⚠️ El WAF de la UTA bloquea ráfagas de requests. Navegá manual y
> despacio; no automatices capturas en paralelo.

### Si NO tenés acceso

Opciones:
- Pedir a algún contacto screenshots del Moodle UTA
- Buscar screenshots en redes sociales / sitio institucional público
- Tomar el azul institucional UTA (`#233A83`) como referencia de marca
  y aplicarlo sobre el Boost base

### Carpeta sugerida

```
presentation/
└── screenshots-referencia/
    ├── uta-real/                    ← capturas del Moodle UTA de referencia
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
  border-radius: var(--uta-card-radius) !important;
}
```

### El navbar no toma el color azul UTA

Boost usa `--bs-primary` de Bootstrap. Declarar:

```scss
:root {
  --bs-primary: var(--uta-primary);
  --bs-primary-rgb: 35, 58, 131;
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
4. **Paleta confirmada: UTA azul `#233A83`** (decisión final 2026-05-29)
5. **Instalar `format_tiles`** siguiendo sección 2 (~5 min)
6. **Aplicar formato Tiles al curso ALG-DEMO** siguiendo sección 3 (~2 min)
7. **Capturar baseline visual** del Moodle ANTES de tocar SCSS (~5 min)
8. **Aplicar paleta UTA** vía SCSS custom siguiendo sección 4 (~30 min)
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
- Ajustes finos de tono dentro de la familia azul UTA (`#233A83`)

---

## ⚠️ Notas del autor

- Este doc lo preparó **Álvaro** (rol Infra/QA) cubriendo lo técnico
  porque Edison no estaba disponible. **NO reemplaza a Edison** — solo
  desbloquea su trabajo para que arranque directo en la parte de
  diseño visual.
- **Paleta**: el plan-fase-1.md oficial dice paleta UTA azul
  (`#233A83`) y esa es la **decisión final** (Imanol, 2026-05-29). El
  pivot transitorio a "Santo Domingo de Guzmán" (B&N) del 2026-05-23
  quedó descartado; este doc ya está alineado a UTA (variables `--uta-*`).
- Cualquier desviación → ajustar este doc + commit
  `docs(infra): ajustar sprint1-preparacion según feedback`.
