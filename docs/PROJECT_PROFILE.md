# Perfil y ruta del proyecto

Se completa al finalizar el descubrimiento para evitar imponer herramientas innecesarias.

## Identidad

| Campo | Valor |
|---|---|
| Proyecto | Wammetka |
| Objetivo | Marketplace local multivendedor con pedido, entrega y liquidación trazable en el piloto de La Guajira |
| Tipo | **producción / piloto** (proyecto completo; primera entrega = rebanada P0) |
| Plataformas | **Android APK** (canal directo + auto-update) y **Web** (mismo código Flutter). iOS fuera del piloto |
| Flujo crítico | Cliente en zona piloto arma carrito en un comercio abierto, confirma pedido contraentrega y el pedido queda en la nube; el comercio lo ve y puede aceptarlo |
| Brief / expediente | `docs/EXPEDIENTE_TECNICO.md` (**siempre** obligatorio) |
| Remoto Git | **GitHub** |
| Repo (URL) | https://github.com/wcmg1000-hue/wammetka (público) |
| Tareas | `docs/TASKS.md` |
| Menos rework | `docs/RECETA_MENOS_REWORK.md` (puerta DONE) |
| QA mínimo | `docs/QA_MINIMO.md` (3 tests + trazabilidad + regresión) |

Fuentes de negocio (no sustituyen este perfil): tomos I–VI en la raíz del repo (`Wammetka_Expediente_Tecnico_Maestro_*.pdf`).

## Constitution del proyecto (máx. ~8 líneas)

Principios que el Agent **no debe olvidar** en este repo:

1. Datos: **nube = fuente de verdad** (Supabase / Postgres). Local = schema, migraciones y políticas de seguridad a nivel de fila (Row Level Security, RLS).
2. Prueba de producto = **teléfono físico + paquete de Android (Android Package, APK)**; web se verifica en navegador además, no en lugar del APK. Auto-update obligatorio.
3. Pantalla terminada = datos reales + acciones reales + **entrada en nav del rol** (cero placeholders).
4. Secrets solo en `.env` / variables CI; nunca en chat ni APK. Rol y permisos **no** viven en `user_metadata`.
5. No avanzar con analyze/CI en rojo (salvo excepción documentada).
6. Una tarea atómica a la vez (`TASKS.md`); al cerrar módulo → **Converge**.
7. Cada peso del pedido es trazable (producto, domicilio, propina, comisión, descuento con financiador). No liquidar sin pedido y estado final.
8. Una sola app Flutter con **cáscaras por rol** (cliente, comercio, repartidor, administración). No cuatro repositorios en el piloto.

## Clarify (cerrar antes de Specify profundo)

Respuestas cortas. Si falta dato → supuesto numerado.

| # | Pregunta | Respuesta |
|---|---|---|
| C1 | Flujo crítico en 1 frase (quién hace qué y qué queda guardado) | Un **cliente** en municipio piloto elige un comercio abierto, arma carrito con SKUs disponibles, confirma **contraentrega** y se guarda un `pedido` + `pedido_items` en la nube; el **comercio** lo ve en su bandeja. |
| C2 | Roles y qué **no** pueden hacer | **Cliente:** comprar y seguir su pedido; no ve liquidación ni datos de otros clientes. **Comercio:** catálogo y pedidos propios; no ve otros comercios. **Repartidor:** servicios asignados; no ve montos de comisión ni catálogo ajeno. **Admin/operación:** configurar y soportar; no auto-aprobar sus propios ajustes de pago. **Finanzas:** conciliar; no editar evidencias operativas. Anónimo: solo ver oferta pública de zona, no crear pedido. |
| C3 | Offline / pagos / archivos — sí o no | **Pagos:** sí (V1 contraentrega; pasarela en módulo posterior). **Archivos:** sí (evidencia de entrega, más adelante). **Offline completo:** no; si cae la red al confirmar, se muestra error accionable (no se finge éxito). |
| C4 | Ritmo: demo rápido o proyecto completo | **Proyecto completo** (expediente 1–20 + specs P0). La rebanada vertical sigue T01–T07; el resto de tomos se construye por módulos. |
| C5 | Hecho del día 1 (seed + 1 acción en dispositivo) | Seed: 1 admin, 1 comercio, 1 cliente, 1 repartidor, 1 catálogo mínimo, 1 zona. Acción: el cliente confirma un pedido y aparece en Supabase y en la bandeja del comercio. |
| C6 | Fuera de alcance explícito (3 ítems máx.) | (1) Cobertura nacional e iOS App Store. (2) Crédito propio / wallet / categorías reguladas sin habilitación. (3) Envíos intermunicipales, publicidad pagada y planes B2B de pago (P1/P2). |

**Clarify cerrado:** sí · **Fecha:** 2026-09-11

## Specify vs Plan (orden)

1. **Specify** — negocio, roles, alcance, expediente, MD pantallas. *Sin* bloquear por CLI/cloud.  
2. **Challenge** (`CG.challenge`) — cuestionar reglas del flujo crítico → expediente §6.1 (`ANALISIS_REGLAS_NEGOCIO.md`).  
3. **Plan** — stack D1, pre-flight, estructura, **TASKS T01…**, primera rebanada.  
4. **Implement** — solo siguiente `TODO` en `TASKS.md`.

## Decisiones cerradas (antes de codear)

| Decisión | Valor |
|---|---|
| Plataforma(s) objetivo | Android APK directo + Web (Flutter). iOS N/A en piloto |
| Entorno de prueba | Teléfono físico + APK; web en navegador como complemento |
| Datos | **Nube** |
| Cloud fuente de verdad | sí |
| Stack datos | **Supabase (D1)** — Postgres + Auth + Storage + RLS |
| Project ID / project-ref | `wwhyypadkjjbgkmlbpss` (proyecto **wammetka**, sa-east-1) |
| Cuenta CLI autenticada | MCP Supabase autenticado; CLI local pendiente en T03 |
| Estado / DI | **Riverpod** + `go_router` |
| Ruta entrega APK | `entregas/apk/` · nombre `wammetka-v{version}+{versionCode}-arm64.apk` |
| Auto-update APK | **Obligatorio** — `app_config` + Storage bucket `apk` + SHA-256 |
| CI | **GitHub Actions** (`docs/CI_CD.md`) |
| CD | job manual opcional (`scripts/upload_apk.ps1` + `docs/PUBLISH_APK.md`); no en el YAML base |
| Fuera de alcance | iOS store, crédito propio, intermunicipal, pauta, planes B2B de pago, ERP contable completo (asientos) en P0 |

## Ritmo de entrega (profundidad de docs, no de CI)

La CI del remoto elegido es **igual** en ambos ritmos. Cambia la profundidad del expediente/specs/manual. Demo: `docs/MODO_DEMO.md`.

- [ ] **Demo rápido:** Clarify C1–C6; expediente **1–8** (9–16 = N/A + motivo); specs sueltos opcionales; manual N/A si se acuerda; **solo T01–T07** en `TASKS.md`; bitácora. No exigir 1–16 llenas.
- [x] **Proyecto completo:** expediente 1–20 + specs por módulo + manual + runbook; tareas por módulo.

## Ruta de interfaz

- [x] **V1 — Stitch (MD-first):** `PANTALLAS_PARA_STITCH.md`. HTML manual solo al final. Sin MCP/ID Stitch.
- [ ] **V2 — Diseño externo:** Figma/HTML/capturas en `docs/design/`.
- [ ] **V3 — UI estándar:** tokens/componentes mínimos.
- [ ] **V4 — Sin UI.**

**Fuente visual:** MD (`docs/stitch/PANTALLAS_PARA_STITCH.md`)

## Ruta de datos

- [x] **D1 — Supabase (nube)** → `CAMINO_POR_STACK.md` § D1
- [ ] **D2 — Firebase (nube)** → `CAMINO_POR_STACK.md` § D2
- [ ] **D3 — SQL propio**
- [ ] **D4 — API existente**
- [ ] **D5 — Sin persistencia / solo local**

## Entornos

| Entorno | Identificador | Datos | Despliegue |
|---|---|---|---|
| Prueba | Teléfono + APK; web local | sintéticos | `flutter build apk --release --target-platform android-arm64` |
| Staging cloud | proyecto Supabase Wammetka (T03) | sintéticos | tras CI verde |
| Producción | N/A hasta piloto controlado (Tomo VI) | reales | aprobación explícita |

## Puertas aplicables

- [x] Clarify cerrado (tabla arriba).
- [x] Constitution rellenada.
- [x] Plataforma(s) + nube/local + ritmo cerrados.
- [x] `EXPEDIENTE_TECNICO.md` generado según ritmo (demo 1–8 / completo 1–20).
- [x] `TASKS.md` con T01… y rebanada identificada (fase Plan).
- [x] D1/D2: pre-flight del stack (si nube). Project-ref `wwhyypadkjjbgkmlbpss`.
- [x] V1: MD generado (HTML no es puerta).
- [x] `BITACORA_DESARROLLO.md` lista.
- [x] Auto-update APK si hay Android APK directo. (Spec existente; implementación T07.)
- [x] Remoto GitHub **o** GitLab: repo + YAML CI en 1ª rebanada (T02). https://github.com/wcmg1000-hue/wammetka/actions/runs/34656548482 PASS
- [ ] Seed día 1 si es demostrable. (T03 cloud + T05 login seed; falta acción en teléfono.)

## Supuestos numerados (reversibles)

1. **S1.** Si no se confirma iOS, el piloto es Android APK + Web.
2. **S2.** Si no hay pasarela contratada, V1 cobra **contraentrega**; la pasarela entra en módulo Pagos (P1).
3. **S3.** Una sola app Flutter con login por rol; no cuatro APKs.
4. **S4.** Municipio piloto inicial de seed: **Fonseca** (uno de los seis del Tomo I); los otros se habilitan por configuración, no por código.
5. **S5.** Integración Continua (CI) en **GitHub Actions** (el conector de GitLab no está autenticado en este entorno).
6. **S6.** No se reutiliza el proyecto Supabase de otro aplicativo de la organización; Wammetka tendrá project-ref propio.
7. **S7.** Comisión de referencia 12 % sobre subtotal de productos (Tomo II, hipótesis); no se liquida dinero real en P0.
8. **S8.** Mapa/GPS se aplaza: la cobertura V1 es **municipio + barrio/zona** elegidos en el perfil, no geocerca por latitud.
