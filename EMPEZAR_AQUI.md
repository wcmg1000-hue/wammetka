# Empezar aquí

## 1. Abre el proyecto en Cursor

Copia el contenido de **Código Germinación** dentro de la carpeta de tu app y ábrela en Cursor.

## 2. Nuevo chat

El asistente preguntará: **¿Sobre qué aplicativo vamos a trabajar hoy?**

## 3. Elegir la ruta (Clarify)

Tras nombrar la app, cierra **Clarify** en `PROJECT_PROFILE.md` (o escribe `CG.clarify`):

1. **Plataforma(s):** Android / iOS / Web / Windows / macOS / Linux…
2. **Datos:** nube (casi siempre) o solo local
3. **Ritmo:** demo rápido o proyecto completo — CI **siempre** en el remoto del perfil (**GitHub Actions o GitLab CI**, marcar uno) — `docs/CI_CD.md`. Demo: `docs/MODO_DEMO.md`.
4. Flujo crítico, roles, hecho del día 1, fuera de alcance

Luego: `CG.specify` (expediente/MD) → `CG.challenge` (reglas) → `CG.plan` (`TASKS.md`) → `CG.implement` → `CG.converge`.

**Visual**

- **V1 Stitch (MD-first):** `PANTALLAS_PARA_STITCH.md` → implementar desde el MD. HTML a mano solo al final. **Sin MCP ni ID.**
- V2 diseño externo · V3 UI estándar · V4 sin UI.

**Datos nube:** `CAMINO_POR_STACK.md` (Firebase o Supabase). **Solo local:** no forzar cloud.

**Android APK directo:** auto-update **obligatorio**; prueba en teléfono. No Chrome/AVD como estándar.

## 4. Orden operativo

```text
idea → CG.clarify → CG.specify (G/W/T) → CG.challenge (reglas §6)
→ CG.plan (TASKS 5–12)
→ T01 scaffold → T02 CI → T03/T04 seed+smoke
→ T05 auth+tests núcleo → T06 flujo en dispositivo del perfil
→ T07 auto-update si APK → CG.converge → staging/prod
```

Detalle: `docs/RECETA_MENOS_REWORK.md` · challenge: `docs/ANALISIS_REGLAS_NEGOCIO.md`.  
Local = schema/rules; producto = teléfono/navegador/desktop según perfil.

## 5. Evidencia

- `VERIFICACION.md`, `evidencias/REGISTRO.md`, `CHECKLIST.md`, `TASKS.md`
- Bitácora única: `docs/BITACORA_DESARROLLO.md` (tiempos para cobro + retrospectiva)
- **Sin fila PASS en REGISTRO no hay DONE.**

## 6. Si eliges Stitch (V1)

1. Generar `PANTALLAS_PARA_STITCH.md`.
2. Implementar desde el MD; probar con APK en el teléfono.
3. Pegar el MD en Stitch cuando quieras (paralelo).
4. Al terminar el visual: si prefieres Stitch, pasa el HTML a mano.

## 7. Datos

Abrir `CAMINO_POR_STACK.md` según Firebase o Supabase. Pre-flight antes de features.

## 8. Archivos clave

| Archivo | Uso |
|---------|-----|
| `docs/CHECKLIST.md` | fases y puertas |
| `docs/PROJECT_PROFILE.md` | Clarify, constitution, rutas |
| `docs/TASKS.md` | backlog atómico + Converge |
| `docs/RECETA_MENOS_REWORK.md` | puerta DONE / menos rework |
| `docs/QA_MINIMO.md` | 3 tests + G/W/T→prueba + regresión Converge |
| `docs/MODO_DEMO.md` | ritmo demo: Clarify + expediente 1–8 + T01–T07 |
| `docs/ANALISIS_REGLAS_NEGOCIO.md` | CG.challenge — excepciones de reglas |
| `docs/BITACORA_DESARROLLO.md` | tiempos y cobro |
| `docs/stitch/PANTALLAS_PARA_STITCH.md` | MD pegable + fuente UI |
| `docs/database/CAMINO_POR_STACK.md` | camino Firebase/Supabase |

