# Tareas atómicas — Código Germinación

> Backlog ejecutable tras **Plan**. Una sola `DOING`. Proyecto completo: T01–T07 = rebanada P0; luego módulos.  
> Orden canónico y puerta DONE: `docs/RECETA_MENOS_REWORK.md`.

**Proyecto:** Wammetka  
**Flujo crítico:** Cliente confirma pedido contraentrega; el comercio lo ve y puede aceptarlo  
**Dispositivo de prueba:** teléfono físico + APK arm64 (web Chrome = complemento)  
**Remoto CI:** GitHub Actions  
**Tarea actual:** T05  

## Estados

| Estado | Significado |
|---|---|
| `TODO` | Pendiente |
| `DOING` | En curso (solo una) |
| `DONE` | Puerta DONE + **fila PASS en REGISTRO** (sin REGISTRO no hay DONE) |
| `N/A` | No aplica (motivo) |

## Backlog (orden fijo de rebanada)

| ID | Módulo | Tarea (1 acción) | Depende | DoD verificable | Estado | Evidencia |
|---|---|---|---|---|---|---|
| T01 | Scaffold | App Flutter corre; tema base; APK arm64 compilable | — | `flutter analyze` exit 0 + APK generado | TODO | Analyze/test/build PASS; **smoke teléfono FAIL** (`adb` vacío). No DONE |
| T02 | CI | GitHub Actions: format + analyze + test (+ build arm64 en default) | T01 | Pipeline **PASS** | DONE | https://github.com/wcmg1000-hue/wammetka/actions/runs/34656548482 · verify + build_apk success · `46441d8` |
| T03 | Datos | Proyecto Supabase Wammetka + migraciones + RLS + seed | T01 | Seed listo; RLS +/− OK en local | TODO | Cloud schema+seed; tokens Auth `''`; GRANT helpers RLS. Docker local N/A. No DONE |
| T04 | Smoke | 1 escritura cloud desde el teléfono (pedido o perfil) | T03 | Visible en Table Editor | TODO | Bloqueado: sin teléfono |
| T05 | Auth | Login por rol + **3 tests núcleo** | T03 | Entra/sale + tests auth / no-puede / validación | DOING | Cliente `supabase_flutter` + tests núcleo PASS; login seed PASS (local dart-define). Falta smoke APK+teléfono |
| T06 | Rebanada | Catálogo + carrito + confirmar + bandeja comercio | T05 | AC-01…AC-10 con dueño; smoke teléfono | TODO | |
| T07 | Auto-update | `app_config` + SHA-256 + diálogo | T06 | Update en teléfono | TODO | |

_Una fila = una cosa comprobable. No “hacer el módulo X completo”._

## Módulos posteriores (no abrir hasta Converge de P0)

| ID | Módulo | Tarea (1 acción) | Depende | DoD verificable | Estado | Evidencia |
|---|---|---|---|---|---|---|
| T08 | Despacho | Aceptar → asignar repartidor → estados recogido/entregado | T06 | Pedido llega a `entregado` con evento | TODO | |
| T09 | Pagos | Adaptador pasarela sandbox + webhook idempotente | T08 | Pedido prepago autorizado | TODO | |
| T10 | Liquidación | Corte comercio/repartidor con extracto | T09 | Neto explicable por pedido | TODO | |

## Orden canónico

```text
T01 scaffold → T02 CI (format+analyze+test; build arm64 en default) → T03 seed/rules → T04 smoke cloud (si nube)
→ T05 auth + tests núcleo → T06 flujo crítico → T07 auto-update (si APK)
→ módulos siguientes → Converge
```

## Puerta DONE (fail closed)

- [ ] Analyze exit 0 (stack del perfil).
- [ ] Tests del núcleo: los **3 mínimos** desde T05/T06 (`QA_MINIMO.md`: auth, no-puede, validación).
- [ ] Smoke del DoD en el **dispositivo del perfil** (no exigir APK si no es Android).
- [ ] **Fila PASS en `docs/evidencias/REGISTRO.md` — obligatoria. Sin esa fila no marcar `DONE`.**

## Converge (cerrar módulo / rebanada)

Máx. ~10 minutos (incluye regresión corta). Detalle: `docs/QA_MINIMO.md`.

- [ ] Alcance en la **nav del rol** (no huérfano).
- [ ] Cada G/W/T del módulo (incl. challenge) tiene `test` o `smoke` en expediente §12 — **sin huérfanos**.
- [ ] Cero placeholders / `onPressed` vacío.
- [ ] Analyze + **3 tests núcleo** + CI + dispositivo OK.
- [ ] Regresión corta (8–12) de `QA_MINIMO.md` §3 pasada.
- [ ] `CHECKLIST` + `REGISTRO` + bitácora al día.
- [ ] Error típico nuevo → ficha en `LECCIONES_APRENDIDAS.md`.

**Módulo cerrado:** _(nombre)_ · **Fecha:** _(_)_ · **Notas:** _(_)_

## Frases `CG.*`

| Frase | Acción |
|-------|--------|
| `CG.clarify` | Tabla Clarify del perfil |
| `CG.specify` | Negocio + G/W/T + MD (**sin** pelear CLI) |
| `CG.challenge` | Cuestionar reglas (§6 / `ANALISIS_REGLAS_NEGOCIO.md`) antes de Plan |
| `CG.plan` | Perfil + stack + esta tabla |
| `CG.tasks` | Solo ajustar backlog |
| `CG.implement` | Siguiente `TODO` + puerta DONE (fail closed sin REGISTRO) |
| `CG.converge` | Checklist Converge |
