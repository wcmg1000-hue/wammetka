# Agente del proyecto — Código Germinación

Este proyecto usa **Código Germinación** para desarrollar aplicaciones de forma ordenada.

## Antes de trabajar

1. Lee `docs/CHECKLIST.md` para saber en qué fase estamos.
2. Lee `docs/WORKFLOW.md` para el proceso completo.
3. Lee `docs/TASKS.md` + `docs/RECETA_MENOS_REWORK.md` + `docs/QA_MINIMO.md` (puerta DONE + Converge).
4. Lee `docs/PROJECT_PROFILE.md` (Clarify + constitution); V1 → `PANTALLAS_PARA_STITCH.md`; D1/D2 → `CAMINO_POR_STACK.md` + `STACK_DB.md`.
5. Lee `docs/specs/` / expediente (Given/When/Then) antes de implementar.
6. Lee `docs/LECCIONES_APRENDIDAS.md` antes de programar (reglas `13`/`14`).

## Al iniciar un chat nuevo

Pregunta **solo** esto primero:

> **¿Sobre qué aplicativo vamos a trabajar hoy?**

## Máquina Clarify → Converge

| Frase | Paso |
|-------|------|
| `CG.clarify` | Cerrar tabla Clarify del perfil |
| `CG.specify` | Negocio + expediente + MD (sin bloquear por CLI) |
| `CG.challenge` | Cuestionar reglas de negocio → expediente §6.1 |
| `CG.plan` | Stack + `TASKS.md` T01… |
| `CG.tasks` | Solo ajustar backlog |
| `CG.implement` | Solo la siguiente `TODO` |
| `CG.converge` | Cerrar módulo/rebanada (checklist en `TASKS.md`) |

Regla: `.cursor/rules/17-cg-clarify-tasks-converge.mdc`.

## Fases del trabajo

| Fase | Qué hacer | Modo sugerido |
|------|-----------|---------------|
| Descubrimiento | Clarify + Specify (plataforma, nube/local, alcance) | Ask |
| Perfil y arquitectura | Plan: ruta, stack, **TASKS**, expediente | Ask o Agent (docs) |
| Diseño (condicional) | MD Stitch / Figma / UI estándar | Manual/Agent |
| Datos | Pre-flight stack, migraciones, seed, rules/RLS | Agent + CLI/MCP |
| Rebanada vertical | Tareas T01–T0n + **APK en teléfono** | Agent |
| Implementación | Una `TODO` + Converge por módulo | Agent |
| Staging/producción | Desplegar, smoke, rollback | Agent + aprobación |

## Reglas clave

- Responde en español. No inventes secretos. Siglas: primero el significado (regla `18-lenguaje-claro-siglas`).
- Orden canónico y **DONE** en `RECETA_MENOS_REWORK.md` (dispositivo del perfil, no APK si no es Android). **Sin fila PASS en `docs/evidencias/REGISTRO.md` no hay DONE** (fail closed).
- **V1 Stitch:** MD-first; regla `07-stitch-md-implementacion`. Sin MCP/ID. HTML manual solo al final del visual.
- Al descubrir: **plataforma(s)** y **nube vs solo local** antes de stack detallado.
- **Android APK directo → auto-update obligatorio** (regla `12`) en cada proyecto con ese canal. Prueba en teléfono físico (no Chrome/AVD como estándar).
- Si D1/D2 (nube): `CAMINO_POR_STACK.md`. Si solo local: no forzar cloud.
- Tema base antes de pantallas (desde MD/tokens).
- Una pantalla a la vez: implementar → auditar en dispositivo → siguiente.
- Bitácora: `docs/BITACORA_DESARROLLO.md` cada sesión.
- Evidencia en `REGISTRO.md`; sync `CHECKLIST.md`.
- **Expediente técnico siempre** (demo §§1–8, 9–16 N/A con motivo — `docs/MODO_DEMO.md`; completo §§1–20). Specs sueltos obligatorios solo en proyecto completo.
- **CI obligatoria en el remoto del perfil: GitHub Actions o GitLab CI** (marcar uno). Plugin GitHub y/o GitLab según elección. CD opcional (`docs/CI_CD.md`).
- Lecciones según plataforma; actualizar al cierre (`13`).

## Stitch (solo MD + HTML manual)

1. Generar `docs/stitch/PANTALLAS_PARA_STITCH.md` (plantilla `PLANTILLA_EJEMPLO.md`).
2. Implementar UI desde ese MD.
3. Usuario puede pegar el MD en Stitch en paralelo.
4. Al terminar el visual: si prefiere Stitch, pasa **HTML a mano** → adaptar.
5. **No** pedir ID ni usar MCP Stitch. Ver `COMO_USAR_EN_STITCH.md` y regla `07-stitch-md-implementacion`.

## Base de datos

`STACK_DB.md` + `CONECTAR_BD.md` + `CAMINO_POR_STACK.md` (D1/D2).  
CLI Firebase / Supabase MCP+CLI / MySQL. Secretos solo en `.env`.

## Auto-actualización de APK (obligatoria si hay APK directo)

Si el proyecto incluye **Android con distribución por APK** (fuera de Play): el módulo auto-update es **obligatorio** (regla `12`) — Firebase Remote Config + Storage **o** Supabase `app_config` + Storage. **Fuente de verdad:** `versionCode` / `PackageInfo.buildNumber` vs `version_code` remoto; semver `latest_version` solo si `version_code` es null. Tras descargar, SHA-256 hex minúsculas: si el `sha256` remoto no está vacío y no coincide, borrar y no instalar. El teléfono es el entorno de prueba continuo. **No** Google Play; no-op en iOS. Si no hay canal APK: `N/A` en checklist.

## Cierre

- `EXPEDIENTE_TECNICO.md`, manual por rol, lecciones, **bitácora con totales de horas**.

## Archivos importantes

- `EMPEZAR_AQUI.md`, `docs/WORKFLOW.md`, `docs/CHECKLIST.md`
- `docs/PROJECT_PROFILE.md`, `docs/TASKS.md`, `docs/RECETA_MENOS_REWORK.md`, `docs/QA_MINIMO.md`, `docs/ANALISIS_REGLAS_NEGOCIO.md`, `docs/BITACORA_DESARROLLO.md`
- `docs/MODO_DEMO.md`, `docs/PILOTO_UN_DIA.md`, `docs/PUBLISH_APK.md`
- `docs/database/CAMINO_POR_STACK.md`, `CONECTAR_BD.md`, `STACK_DB.md`
- `docs/stitch/PANTALLAS_PARA_STITCH.md`, `COMO_USAR_EN_STITCH.md`
- `docs/EXPEDIENTE_TECNICO.md`, `docs/CI_CD.md`, `.gitlab-ci.yml.example`, `.github/workflows/ci.yml`
- `docs/DEUDA_CODIGO_GERMINACION.md` — roces del molde (no se actualiza solo; distinto de lecciones)
- `docs/LECCIONES_APRENDIDAS.md`, `docs/VERIFICACION.md`, `docs/SEGURIDAD.md`
- `.cursor/mcp.json.example` — MCP **Supabase** (sin Stitch)
- Plugin **GitHub y/o GitLab** en Cursor según el remoto del perfil
- `.cursor/rules/`

