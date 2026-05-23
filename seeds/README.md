# Seeds — Datos de prueba

> Datos ficticios para inicializar el Moodle local. No representan
> personas reales ni instituciones específicas. Cada integrante del
> equipo crea estos seeds en su propio entorno local antes de empezar
> a trabajar.

## 📁 Archivos

- **`users.json`** — admin + 5 cuentas estudiante de prueba
- **`courses.json`** — 1 curso genérico de prueba (`PROG1-DEMO`) con formato Tiles y 5 actividades

## 🛠️ Cómo crear los seeds en tu Moodle local

### Pre-requisito

Tu Moodle local debe estar corriendo:
```bash
docker compose ps
# Esperás ver: moodle (Up), mariadb (Up healthy), mailhog (Up)
```

Y debés estar logueado en http://localhost:8080 con tu usuario admin
(definido en `.env`).

### Paso 1 — Crear las 5 cuentas estudiante

Para cada entrada del array `students` en `users.json`:

1. Site administration → **Users** → **Accounts** → **Add a new user**
2. Llenar:
   - **Username**: `estudianteXX` (sin mayúsculas, sin espacios)
   - **New password**: usar el del JSON
   - **First name**: del JSON
   - **Surname**: del JSON
   - **Email address**: del JSON
   - **City/town**: Ambato
   - **Country**: Ecuador
3. Dejar el resto por defecto
4. **Create user**
5. Repetir para los 5 estudiantes

> ⏱️ **Tiempo estimado**: ~5 min total

### Paso 2 — Crear la categoría de curso

1. Site administration → **Courses** → **Manage courses and categories**
2. **Create new category**:
   - **Category name**: `Carrera de Prueba - DEMO`
   - **Category ID number**: `DEMO-CAT`
3. **Create category**

### Paso 3 — Crear el curso

1. Site administration → **Courses** → **Add a new course**
2. Llenar:
   - **Course full name**: `Programación 1 - DEMO`
   - **Course short name**: `PROG1-DEMO`
   - **Course category**: `Carrera de Prueba - DEMO`
   - **Course start date**: 1 abr 2026
   - **Course end date**: 31 jul 2026
   - **Course format** → **Format**: **Tiles** (si no aparece la opción, instalar primero el plugin `format_tiles` desde Site administration → Plugins → Install plugins)
   - **Course summary**: copiar del JSON
3. **Save and display**

### Paso 4 — Inscribir a los 5 estudiantes en el curso

1. Dentro del curso → **Participants** (en el menú izquierdo)
2. **Enrol users**
3. Buscar `estudiante01`, marcar, asignar **Role: Student**
4. Repetir para los 5
5. **Enrol users** (botón abajo)

### Paso 5 — Crear las 5 actividades

Activar **Edit mode** (toggle arriba a la derecha).

Para cada actividad del array `activities` en `courses.json`:

1. En la primera "tile" del curso → **Add an activity or resource**
2. Elegir el tipo correspondiente:
   - **Assignment** para tipo `assign`
   - **Quiz** para tipo `quiz`
   - **File** para tipo `resource`
   - **URL** para tipo `url`
   - **Forum** para tipo `forum`
3. Llenar nombre + descripción según el JSON
4. **Save and return to course**
5. Repetir las 5

> ⏱️ **Tiempo estimado**: ~15 min total

### Paso 6 — Verificar

Cerrar sesión y entrar como `estudiante01` (password `Estudiante01.demo`):
- ¿Ve el curso `PROG1-DEMO` en Mi dashboard?
- ¿Puede entrar al curso y ver las 5 actividades?

Si SÍ → seeds listos. Si NO → debug (probable que no se inscribió bien).

## 🚀 Automatización futura

En **Sprint 3** vamos a automatizar la creación de seeds vía script CLI:

```bash
# Ejemplo de cómo será (pseudocódigo, no implementado todavía)
docker compose exec moodle php admin/cli/install_seed.php \
  --users seeds/users.json \
  --courses seeds/courses.json
```

Por ahora el flujo manual está bien — solo 6 cuentas + 5 actividades,
~25 min de setup por persona del equipo.

## 🏛️ Adaptación a otras instituciones

Estos seeds son **genéricos** intencionalmente. Cuando el plugin se
despliegue en una institución externa (Fase 2) o en UTA (Fase 3), los
JSON se ajustan a su contexto:

- **Categoría**: la real de la institución (ej. "Ingeniería de Software")
- **Curso de prueba**: una materia que esa institución use (ej. "Algoritmos y Lógica")
- **Estudiantes**: cuentas reales con consentimiento informado (Fase 2) o
  proceso institucional (Fase 3)

El plugin mismo no asume nada de la institución — funciona con cualquier
Moodle 4.x.

## ⚠️ Importante

- ✅ **NO commitear** datos reales (nombres/emails de personas reales)
- ✅ Los passwords del JSON son de **prueba** — usar solo en Moodle local
- ✅ Los emails `@osyanificacion.local` son ficticios — Mailhog los captura sin SMTP real
