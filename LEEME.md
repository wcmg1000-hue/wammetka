# Código Germinación — Instrucciones para alumnos

## Qué es esto

Un paquete de archivos que configura Cursor para ayudarte a crear tu aplicación paso a paso: desde la idea hasta el código, con documentación, pruebas y seguridad.

---

## Instalación (solo copiar y pegar)

### 1. Crea la carpeta de tu proyecto

Por ejemplo: `C:\MisProyectos\mi-app-dental`

### 2. Copia TODO el contenido de esta carpeta

Copia **todos** los archivos y carpetas que recibiste del profesor:

- La carpeta `.cursor` (¡no la olvides! A veces está oculta en Windows)
- La carpeta `docs` (incluye `docs/stitch/` para diseño en Stitch)
- La carpeta `.github` (workflow de ejemplo si eliges GitHub)
- Los archivos `AGENTS.md`, `EMPEZAR_AQUI.md`, `LEEME.md` y `.env.example`

Pégalos **dentro** de la carpeta de tu proyecto.

> **Windows:** si no ves la carpeta `.cursor`, ve a **Ver → Elementos ocultos** en el Explorador de archivos y vuelve a copiar.

Tu proyecto debe verse así:

```
mi-app-dental/
├── .cursor/
│   ├── rules/              ← reglas automáticas de Código Germinación
│   └── mcp.json.example    ← opcional: MCP Supabase (copiar a mcp.json)
├── .github/
│   └── workflows/ci.yml    ← CI GitHub (T02 si el remoto es GitHub)
├── docs/
│   ├── specs/              ← specs por módulo (o expediente en demo)
│   ├── stitch/             ← MD pegable Stitch; HTML solo a mano al final
│   │   └── export/         ← HTML/PNG si el usuario los aporta
│   ├── database/           ← stack y conexión BD (nube o local)
│   ├── decisions/          ← decisiones técnicas
│   ├── manual/             ← manuales por rol (al final)
│   ├── PROJECT_PROFILE.md  ← Clarify, constitution, rutas, GitHub o GitLab
│   ├── TASKS.md            ← backlog atómico + Converge (CG.*)
│   ├── RECETA_MENOS_REWORK.md ← puerta DONE / menos correcciones
│   ├── QA_MINIMO.md        ← 3 tests + trazabilidad G/W/T + regresión
│   ├── ANALISIS_REGLAS_NEGOCIO.md ← CG.challenge (excepciones de reglas)
│   ├── CI_CD.md            ← CI en GitHub Actions o GitLab CI; CD opcional
│   ├── EXPEDIENTE_TECNICO.md ← obligatorio (demo o completo)
│   ├── MODO_DEMO.md        ← ritmo demo (1–8 + T01–T07)
│   ├── DEUDA_CODIGO_GERMINACION.md ← roces/ajustes finos del molde
│   ├── SEGURIDAD.md
│   ├── VERIFICACION.md     ← comandos = jobs del remoto elegido
│   ├── evidencias/
│   ├── CHECKLIST.md
│   ├── WORKFLOW.md
│   ├── BITACORA_DESARROLLO.md
│   ├── AUDITORIA_VISUAL.md
│   └── LECCIONES_APRENDIDAS.md
├── database/migrations/
├── supabase/migrations/
├── .gitlab-ci.yml.example  ← copiar a .gitlab-ci.yml si el remoto es GitLab
├── .env.example
├── .gitignore
├── AGENTS.md
├── EMPEZAR_AQUI.md
├── KIT_VERSION.md
└── LEEME.md
```

### 3. Abre tu proyecto en Cursor

1. Abre **Cursor**
2. Menú **Archivo → Abrir carpeta**
3. Selecciona la carpeta de tu proyecto (`mi-app-dental`)

### 4. Abre el archivo inicial

1. En el explorador de archivos de Cursor, abre **`EMPEZAR_AQUI.md`**
2. Sigue los pasos que indica ese archivo

---

## Eso es todo (casi)

Cursor leerá automáticamente `.cursor/rules/` y `AGENTS.md` al abrir tu proyecto.

**Una sola vez** tu profesor te ayudará a conectar la **base de datos** (Firebase/Supabase — `docs/database/CONECTAR_BD.md` y `CAMINO_POR_STACK.md`). Stitch **no** usa MCP: solo el MD pegable y, al final, HTML a mano si quieres.

---

## Resumen rápido

1. Copiar archivos de Código Germinación → tu carpeta de proyecto
2. Abrir la carpeta en Cursor
3. Abrir `EMPEZAR_AQUI.md`
4. Abrir chat (Ctrl + L)
5. Responder: *¿Sobre qué aplicativo vamos a trabajar hoy?*
6. `CG.clarify` → `CG.specify` → `CG.challenge` → `CG.plan` → `CG.implement` → `CG.converge` (`RECETA_MENOS_REWORK.md`)

---

## Para el profesor

Código Germinación se puede distribuir como carpeta comprimida (ZIP). Los alumnos descomprimen y copian el contenido a su proyecto.

