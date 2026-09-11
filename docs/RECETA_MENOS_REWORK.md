# Receta — menos rework (Código Germinación)

Objetivo: atrapar errores baratos temprano. Orden canónico del kit.

## Orden canónico

```text
0  Git / secretos
1  Clarify + plataforma + nube/local
2  Specify: G/W/T flujo crítico (+ MD pantallas si V1)
3  Challenge: reglas del flujo crítico (`ANALISIS_REGLAS_NEGOCIO.md` → expediente §6.1)
4  Plan: perfil + TASKS 5–12 + VERIFICACION
5  T01 scaffold → T02 CI (format + analyze + test; build arm64 solo en default)
6  T03/T04 seed + smoke (local = rules/schema; producto = dispositivo del perfil)
7  T05 auth (+ tests del núcleo auth)
8  T06 flujo crítico en dispositivo (rebanada vertical real)
9  T07 auto-update solo si Android APK directo
10 Módulos: una TODO + DONE + Converge
11 Staging → producción
```

## Local vs prueba de producto

| Qué | Dónde | Para qué |
|---|---|---|
| Schema, migraciones, RLS/rules +/− | Emulador / Supabase local / SQL local | Datos seguros sin prod |
| Smoke del flujo / DoD de una tarea | **Dispositivo del perfil** | Probar el producto |

- Android APK directo → teléfono físico (+ auto-update). No Chrome/AVD como estándar.
- E2E/Patrol **no** es puerta DONE. Si se pide: solo proyecto **QA** + respaldo verificado; jamás contra prod (`LECCIONES` **3.29**, **4.22–4.25**).
- Web → navegador del perfil. Desktop → build nativo. V4/API → contrato/smoke documentado.
- Con nube: tras rules locales OK → **1 escritura visible** desde el dispositivo del perfil (staging/dev, no prod).

## Puerta DONE (cada tarea crítica) — fail closed

No marcar `DONE` / PASS si falta alguno. **Sin fila PASS en REGISTRO.md no hay DONE.**

| # | Control | Evidencia |
|---|---|---|
| 1 | Analyze del stack (`flutter analyze` u equivalente) exit 0 | local y/o job del remoto (GitHub o GitLab) |
| 2 | Tests del **núcleo** del flujo tocado (obligatorios desde la rebanada; crearlos en T05/T06, no “si ya existen”) | `flutter test` / job `test` |
| 3 | Artefacto + smoke del DoD en el **dispositivo del perfil** | REGISTRO |
| 4 | Fila PASS en `docs/evidencias/REGISTRO.md` (**obligatoria**) | observada |

`CG.implement` no cierra la tarea si falta el REGISTRO.

## Tests del núcleo (crear en T05/T06)

Obligatorios **tres** (`docs/QA_MINIMO.md`): auth OK/fallido · rol que **no puede** · validación que guarda.  
Ampliar solo si un bug se repite (p. ej. `versionCode` / hash de auto-update). No un test por widget.

Cada G/W/T del flujo crítico → `test` o `smoke` (expediente §12). Sin dueño → no Converge.

## Rebanada vertical

UI → auth → autorización → dato → visible en el dispositivo del perfil.  
**Una pantalla a la vez** = una pantalla del flujo crítico **completa** (dato real + acciones), no UI con mocks permanentes.

