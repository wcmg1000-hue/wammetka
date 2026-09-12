# Tareas atómicas — Código Germinación

> Backlog ejecutable tras **Plan**. Una sola `DOING`. Proyecto completo: T01–T07 = rebanada P0; luego módulos.  
> Orden canónico y puerta DONE: `docs/RECETA_MENOS_REWORK.md`.

**Proyecto:** Wammetka  
**Flujo crítico:** Cliente confirma pedido contraentrega; el comercio lo ve y puede aceptarlo  
**Dispositivo de prueba:** teléfono físico + APK arm64 (web Chrome = complemento)  
**Remoto CI:** GitHub Actions  
**Tarea actual:** T08  

> T08 **DOING** — despacho hasta `entregado` + evento. Converge P0 en curso (AC-09).  

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
| T01 | Scaffold | App Flutter corre; tema base; APK arm64 compilable | — | `flutter analyze` exit 0 + APK generado | DONE | APK +2 en Redmi 68486ddd; UI `Entrar a Wammetka` observada |
| T02 | CI | GitHub Actions: format + analyze + test (+ build arm64 en default) | T01 | Pipeline **PASS** | DONE | https://github.com/wcmg1000-hue/wammetka/actions/runs/34656548482 · verify + build_apk success · `46441d8` |
| T03 | Datos | Proyecto Supabase Wammetka + migraciones + RLS + seed | T01 | Seed listo; RLS +/− OK en local | TODO | Cloud schema+seed; tokens Auth `''`; GRANT helpers RLS. Docker local N/A. No DONE |
| T04 | Smoke | 1 escritura cloud desde el teléfono (pedido o perfil) | T03 | Visible en Table Editor | DONE | `Guardar perfil` → UI `Perfil guardado`; `profiles.telefono` del cliente seed = `3001234567` |
| T05 | Auth | Login por rol + **3 tests núcleo** | T03 | Entra/sale + tests auth / no-puede / validación | DONE | Tests núcleo + live. Teléfono: `Hola, Cliente Piloto` / `Rol: cliente` → `Cerrar sesión` → login |
| T06 | Rebanada | Catálogo + carrito + confirmar + bandeja comercio | T05 | AC-01…AC-10 con dueño; smoke teléfono | DONE | APK +3 Redmi; pedido `a6fb5a34-…360e` aceptado; CI https://github.com/wcmg1000-hue/wammetka/actions/runs/34659992798 |
| T07 | Auto-update | `app_config` + SHA-256 + diálogo | T06 | Update en teléfono | DONE | Redmi 4→5; hash `811d0e7d…1804` OK; CI https://github.com/wcmg1000-hue/wammetka/actions/runs/34662746664 |

_Una fila = una cosa comprobable. No “hacer el módulo X completo”._

## Módulos posteriores (no abrir hasta Converge de P0)

| ID | Módulo | Tarea (1 acción) | Depende | DoD verificable | Estado | Evidencia |
|---|---|---|---|---|---|---|
| T08 | Despacho | Aceptar → asignar repartidor → estados recogido/entregado | T06 | Pedido llega a `entregado` con evento | DOING | RPC `a6fb5a34-…360e` → `entregado` + eventos; smoke Redmi login `No hay red` (no DONE) |
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

- [x] Alcance en la **nav del rol** (no huérfano). Cliente: Inicio/Carrito/Pedidos/Cuenta. Comercio: Pedidos/Catálogo. Repartidor: Servicios (T08).
- [x] Cada G/W/T del módulo (incl. challenge) tiene `test` o `smoke` en expediente §12 — **sin huérfanos**. AC-09 ahora `test` (`canCancelCliente`).
- [x] Cero placeholders / `onPressed` vacío.
- [x] Analyze + **3 tests núcleo** + CI + dispositivo OK. REGISTRO T05/T06/T07.
- [x] Regresión corta (8–12) de `QA_MINIMO.md` §3 pasada.
- [x] `CHECKLIST` + `REGISTRO` + bitácora al día.
- [x] Error típico nuevo → ficha en `LECCIONES_APRENDIDAS.md`. Diálogo de update vs `go()` del splash (2.6).

**Módulo cerrado:** P0 Pedido contraentrega (T01–T07) · **Fecha:** 2026-09-11 · **Notas:** AC-09 cubierto con test; T08 Despacho abierto aparte.

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
