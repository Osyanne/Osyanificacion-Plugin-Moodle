# Mockups Sprint 1 — Paleta UTA (azul #233A83)

> Mockups visuales **HTML+CSS standalone** y **templates Mustache
> propuestos** para Sprint 1 (réplica visual). Cero dependencias
> externas — abrir cualquier `.html` directo en el navegador.

## 📂 Contenido

### Mockups HTML (vista previa visual)

| Archivo | Qué muestra |
|---|---|
| `dashboard-mockup.html` | Página principal del curso ALG-DEMO con header, formato Tiles, bloque XP en sidebar |
| `leaderboard-mockup.html` | Vista expandida del leaderboard ±5 con highlight "TÚ" en dorado |

### Cómo abrir los mockups

3 métodos. Elegí el que prefieras.

#### Método 1 — `make mockups` (más cómodo, requiere Docker corriendo)

```bash
make up         # si el stack no está corriendo
make mockups    # publica los .html en el Apache del container Moodle
```

Te devuelve las URLs:

- http://localhost:8080/mockups/dashboard-mockup.html
- http://localhost:8080/mockups/leaderboard-mockup.html

Refrescá el navegador. Los mockups se sirven igual que cualquier otra
URL del Moodle local. **No requiere Python ni servidores extras**.

Para limpiar después: `make mockups-clean`.

#### Método 2 — Doble-click en el explorer

Abrí `presentation/mockups/dashboard-mockup.html` en tu carpeta local.
La URL será `file:///...` en lugar de `localhost`, pero los mockups se
ven idénticos. Es el método más simple y siempre funciona.

#### Método 3 — Servidor Python (sin Docker)

Si no querés depender del container Moodle:

```bash
cd presentation/mockups
python -m http.server 5500
```

Después abrí http://localhost:5500/dashboard-mockup.html. Para parar:
`Ctrl+C`.

### Templates Mustache propuestos (Sprint 2+)

| Archivo | Para qué | Override de |
|---|---|---|
| `templates/xp-widget-osyanificacion.mustache` | Override del bloque XP con look UTA y highlight "TÚ" | `blocks/xp/templates/xp-widget.mustache` |

## 🎯 Cómo usar estos mockups

### Para Edison (Sprint 1)

1. **Abrí los `.html` en tu navegador** — son standalone, no requieren
   Moodle corriendo
2. **Comparalos con los screenshots reales** del Moodle de referencia
   que capturás siguiendo `docs/sprint1-preparacion.md` sección 9
3. **Ajustá lo que no te convenza** — son propuestas de Álvaro, vos
   decidís el look final
4. **Aplicá la paleta CSS** al theme Boost-custom siguiendo
   `docs/sprint1-preparacion.md` sección 4
5. **Hacé tus propios mockups originales** si querés algo distinto

### Para Imanol (Sprint 2 cuando arranque el plugin)

1. Crear plugin propio: `code/local/osyanificacion/`
2. **Copiar templates de esta carpeta** a `templates/block_xp/` del
   plugin propio
3. Moodle los priorizará sobre los originales de `blocks/xp/templates/`
   automáticamente (sin tocar core)
4. Verificar visualmente que el look matchea con los mockups HTML

## 🎨 Filosofía visual

- **Paleta**: azul institucional UTA (`#233A83`) sobre fondo claro,
  acento dorado solo para casos críticos ("TÚ", CTAs primarios)
- **Sombras**: suaves, hairline borders + drop shadows discretas
- **Border-radius**: 8px (sobrio institucional, alineado al theme real)
- **Tipografía**: system stack sin Google Fonts (offline-first,
  privacidad)
- **Saturación**: baja, dominada por el azul UTA + acento dorado puntual

Detalle completo en
[`../../docs/sprint1-preparacion.md`](../../docs/sprint1-preparacion.md).

## ⚠️ Estos mockups NO son finales

Son **propuestas de Álvaro** (rol Infra/QA) cubriendo el rol de Edison
ausente. **Edison puede:**

- Aprobarlos tal cual
- Modificarlos
- Descartarlos y hacer los suyos
- Pedirle cambios a Álvaro

La **paleta UTA azul (`#233A83`)** es la decisión final confirmada por
Imanol el 2026-05-29.
