# Expediente técnico consolidado

Documento **único y obligatorio** en todo proyecto de Código Germinación (demo rápido **y** proyecto completo).  
Se genera al cerrar descubrimiento/arquitectura, se actualiza en cada fase y al cierre.

| Ritmo | Profundidad del expediente | Specs sueltos `docs/specs/` |
|---|---|---|
| **Demo rápido** | Secciones **1–8 obligatorias** (breves OK). **9–16:** `N/A` permitido **con una línea de motivo**. No exigir 1–16 llenas. Ver `docs/MODO_DEMO.md` | Opcional: el expediente (módulos + Given/When/Then) hace de backlog |
| **Proyecto completo** | Secciones 1–16 **completas** + anexos 17–20 | **Obligatorios** por módulo; el expediente los resume y enlaza |

**Proyecto:** Wammetka  
**Versión del expediente:** 1.0  
**Última actualización:** 2026-09-11  
**Ritmo:** proyecto completo (rebanada P0 = pedido contraentrega en zona piloto)  
**Plataforma(s):** Android APK directo + Web (Flutter)  
**Datos:** nube D1 Supabase  
**CI:** GitHub Actions — ver `docs/CI_CD.md`  
**Repo:** https://github.com/wcmg1000-hue/wammetka  

**Fuentes de negocio (PDF, no ejecutables):**

- Tomo I — Planeación estratégica  
- Tomo II — Modelo de negocio y financiero  
- Tomo III — Arquitectura funcional del ERP  
- Tomo IV — Arquitectura técnica  
- Tomo V — Desarrollo funcional  
- Tomo VI — Implementación y operación  

Esos tomos describen el **destino** (marketplace + ERP + liquidación). Este expediente traduce eso a lo que Código Germinación puede construir con puertas verificables. Lo que falta en los PDF está en §3 supuestos y en la tabla de huecos de `docs/BITACORA_DESARROLLO.md` (sesión 2026-09-11).

---

## 1. Resumen ejecutivo

- **Objetivo general:** Validar un marketplace local sostenible en municipios piloto de La Guajira, con operación trazable desde el catálogo hasta el cierre del pedido.
- **Problema que resuelve:** La compra de proximidad hoy exige llamadas, desplazamientos y coordinación manual; los comercios pierden pedidos por falta de vitrina, medios de cobro, datos y entrega confiable.
- **Tipo:** piloto / producción acotada (no demo de juguete; no ERP contable completo en P0).
- **Resultado de éxito medible:** Un cliente de zona piloto crea un pedido contraentrega en menos de 3 minutos y el comercio lo ve en su bandeja el mismo instante; el registro en nube incluye ítems, totales y estado.
- **Flujo crítico de valor:** Descubrir comercio abierto → armar carrito → confirmar pedido → comercio acepta.

## 2. Objetivos específicos

1. Cliente autenticado ve solo comercios **abiertos y de su municipio** y puede confirmar un pedido con total explicable.
2. Comercio autenticado ve **solo sus** pedidos y puede aceptar o rechazar con causal.
3. Cada pedido guarda historial de estados (quién, cuándo); no se borra al cancelar (anulación lógica).
4. Tres pruebas de núcleo (auth / no-puede / validación) verdes y pipeline GitHub Actions verde.
5. APK arm64 instalable en teléfono + auto-update en T07.
6. (P1) Pago con pasarela, evidencia de entrega y liquidación neta por corte — **no** en la primera rebanada.

## 3. Alcance

### Incluido (V1 / P0 — rebanada T01–T07 + módulos P0)

- Auth correo/contraseña y perfil con rol.
- Zonas piloto como catálogo de municipios (Albania, Hatonuevo, Barrancas, Fonseca, Distracción, San Juan del Cesar); seed en Fonseca.
- Alta/edición de catálogo del comercio (SKU, precio, stock, disponible sí/no).
- Pedido cliente: carrito de **un** comercio, contraentrega, totales (productos + domicilio hipotético fijo de zona).
- Bandeja comercio: aceptar / rechazar.
- Shells de repartidor y admin **navegables** con el mínimo del P0 (listar pedidos asignables / ver pedidos); asignación automática simple al aceptar.
- Auto-update APK.
- Integración Continua (CI) en GitHub Actions.

### Excluido (explícito)

- iOS App Store, crédito propio, wallet, BNPL.
- Categorías reguladas sin habilitación (p. ej. medicamentos controlados).
- Envíos intermunicipales y cadena de custodia.
- Publicidad pagada, ranking patrocinado, planes B2B de cobro.
- Contabilidad de doble entrada completa, facturación electrónica DIAN, nómina.
- Promesa de ETA en minutos; en P0 se muestra ventana textual (“30–50 min”, configurable).
- GPS en vivo del repartidor (P1).
- Pasarela de pagos (P1). El Tomo II la exige para el modelo económico; no bloquea el pedido contraentrega.

### Supuestos numerados

1. Si no se confirma iOS, piloto = Android APK + Web.
2. Si no hay pasarela, V1 = contraentrega.
3. Una app, cuatro roles.
4. Municipio seed = Fonseca.
5. CI = GitHub Actions.
6. Proyecto Supabase **nuevo** (no reutilizar otros de la org).
7. Comisión 12 % se **calcula y guarda** en el pedido; no se transfiere dinero en P0.
8. Cobertura V1 por municipio/zona, no por lat/lng.

### Riesgos principales

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Tomos piden ERP + pasarela + logística a la vez | Nunca se entrega un flujo real | Rebanada P0 = pedido contraentrega; el resto por módulo |
| Baja densidad en municipios piloto | Pedidos de prueba poco realistas | Seed sintético + cupos; no fingir cobertura nacional |
| Descuadre de pagos (Tomo II) | Confianza y caja | En P0 no hay split real; campos de split listos; motor de liquidación en P1 |
| Cliente confirma fuera de horario | Pedidos fantasma | Regla: comercio cerrado → no se puede confirmar (challenge R1) |
| Reutilizar BD de otro aplicativo | Fuga / mezcla de datos | Project-ref propio Wammetka |

## 4. Roles de usuario

| Rol | Qué puede hacer | Qué no puede | Cómo entra (login) |
|-----|-----------------|--------------|--------------------|
| `cliente` | Ver oferta de su zona, carrito, confirmar, seguir sus pedidos | Ver otros clientes, liquidaciones, panel comercio | Email/contraseña |
| `comercio` | Catálogo propio, aceptar/rechazar, marcar preparado | Ver otros comercios, tarifas globales, conciliación bancaria | Email/contraseña |
| `repartidor` | Ver ofertas de servicio de su zona, aceptar, marcar recogido/entregado | Ver comisión Wammetka, editar catálogo | Email/contraseña |
| `operacion` | Despacho, casos, reasignar | Cambiar tarifas retroactivas, pagarse a sí mismo | Email/contraseña |
| `finanzas` | Ver extractos y proponer liquidación (P1) | Editar evidencias de entrega | Email/contraseña |
| `admin` | Usuarios, zonas, tarifas futuras, seed | Autorizar sus propios ajustes de pago (segregación) | Email/contraseña |

**Matriz rol × recurso × acción** (C crear / R leer / U actualizar / D borrar / A aceptar):

| Recurso | Cliente | Comercio | Repartidor | Operación | Finanzas | Admin | Anónimo |
|---|---|---|---|---|---|---|---|
| Perfil propio | R/U | R/U | R/U | R | R | C/R/U | — |
| Comercios (oferta) | R zona | R/U propio | R zona | R | R | C/R/U/D | R zona |
| Catálogo | R si abierto | C/R/U propio | — | R | — | R/U | R si abierto |
| Pedido | C/R propio | R/A propio | R asignado | R/U estado | R | R | — |
| Pago/split | R propio (total) | R propio neto | R propio servicio | R | R/U P1 | R | — |
| `app_config` | R | R | R | R | R | U | — |

## 5. Módulos y menú funcional

| # | Módulo | Descripción | Pantallas / rutas | Criterio de hecho (1 línea) | Spec |
|---|--------|-------------|-------------------|-------------------------------|------|
| 1 | Auth | Login, sesión, rol, cáscara | `/login` `/register` | Entra y ve nav de su rol | `docs/specs/MODULO_AUTH.md` |
| 2 | Catálogo y comercios | Oferta por zona, SKU, horario | `/home` `/comercio/:id` `/comercio/catalogo` | Cliente ve SKUs de un comercio abierto | `docs/specs/MODULO_CATALOGO.md` |
| 3 | Pedido | Carrito → confirmar → bandeja | `/carrito` `/checkout` `/pedidos` `/comercio/pedidos` | Pedido en nube + comercio lo ve | `docs/specs/MODULO_PEDIDO.md` |
| 4 | Despacho | Asignar repartidor, estados logísticos | `/reparto` | Pedido aceptado puede asignarse | *este expediente* (P0 mínimo; spec amplia en P1) |
| 5 | Pagos y liquidación | Pasarela, split, corte | — | N/A en P0 (campos en pedido) | P1 |
| 6 | Auto-update APK | Detectar `versionCode` y actualizar | arranque | Detecta versión nueva y verifica SHA-256 | `docs/specs/MODULO_ACTUALIZACION.md` |

**Orden de construcción:** Auth → Catálogo → Pedido (primera rebanada) → Despacho → Auto-update → Pagos.

## 6. Reglas de negocio

1. **R1 Cobertura y horario.** Solo se confirma pedido si el municipio del cliente está habilitado **y** el comercio está `abierto` en ese instante.
2. **R2 Un comercio por carrito.** El carrito no mezcla SKUs de dos comercios.
3. **R3 Stock.** No se confirma si `cantidad > stock` del SKU (se muestra error; no se recorta en silencio).
4. **R4 Contraentrega P0.** Método `contraentrega`; el pedido nace `creado` → `pendiente_comercio` sin autorización de pasarela.
5. **R5 Comisión.** Se calcula 12 % sobre subtotal de productos (sin domicilio ni propina) y se guarda en el pedido; no se cobra al cliente como línea extra.
6. **R6 Aceptación.** El comercio acepta o rechaza; si no hay respuesta en SLA (P0: 10 minutos, configurable), operación puede cancelar o reasignar (en P0: el cliente ve “esperando al comercio”).
7. **R7 Segregación.** El comercio no lee pedidos de otro `comercio_id`. El cliente no lee pedidos ajenos.
8. **R8 Anulación lógica.** Cancelar pone `cancelado` + causal; no DELETE físico del pedido.
9. **R9 Tarifas.** Domicilio P0 = tarifa fija de zona (hipótesis Tomo II $5.000 en Fonseca); versionada con `vigente_desde`.
10. **R10 Financiador de descuento.** Si hay descuento (P1), cada línea declara financiador. En P0 no hay cupones.

### 6.1 Challenge de reglas (CG.challenge)

Plantilla: `docs/ANALISIS_REGLAS_NEGOCIO.md`. Demo: máx. ~6 reglas del flujo crítico.

#### Regla: “Solo se confirma si el comercio está abierto y la zona está habilitada” (R1)

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | Evitar pedidos que nadie puede preparar ni entregar |
| 2 | Preguntas / excepciones | ¿Pedido a las 21:59 si cierra a las 22:00? ¿Cliente con municipio mal cargado? ¿Comercio “abierto” pero sin repartidor? |
| 3 | Qué puede salir mal | Pedidos huérfanos; cliente cree que compró |
| 4 | Usuarios afectados | Cliente, comercio, operación |
| 5 | Abusos / evasiones | Comercio deja abierto 24/7 y no acepta |
| 6 | Alternativa propuesta | Validar al pulsar confirmar (no solo al entrar al catálogo). Si cierra entre carrito y confirmar → error claro. Sin repartidor **no** bloquea P0 (contraentrega puede ser recojo o asignación posterior) |
| 7 | Permisos / auditoría / estados | Evento `pedido.rechazado_cobertura`; admin habilita zonas |

**Decisión acordada:** **mantener** · validación en confirmar · **G/W/T:** AC-04, AC-05.

#### Regla: “El carrito es de un solo comercio” (R2)

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | Un despacho y una liquidación por pedido |
| 2 | Preguntas / excepciones | ¿El cliente quiere farmacia + restaurante? ¿Sustituir comercio? |
| 3 | Qué puede salir mal | Split logístico imposible en P0 |
| 4 | Usuarios afectados | Cliente |
| 5 | Abusos / evasiones | Dos sesiones / dos cuentas |
| 6 | Alternativa propuesta | Al agregar SKU de otro comercio: diálogo “Vaciar carrito y empezar este comercio” |
| 7 | Permisos / auditoría / estados | Carrito local + validación servidor al confirmar |

**Decisión acordada:** **mantener** · diálogo de reemplazo · **G/W/T:** AC-06.

#### Regla: “No confirmar si cantidad > stock” (R3)

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | Sobreventa |
| 2 | Preguntas / excepciones | ¿Dos clientes confirman el último SKU a la vez? ¿Stock desactualizado? |
| 3 | Qué puede salir mal | Promesa incumplida |
| 4 | Usuarios afectados | Cliente, comercio |
| 5 | Abusos / evasiones | Comercio infla stock |
| 6 | Alternativa propuesta | Reserva atómica en transacción (UPDATE stock WHERE stock >= qty). El segundo recibe error. Sustitución = P1 |
| 7 | Permisos / auditoría / estados | `pedido_items` + decremento; evento `stock.insuficiente` |

**Decisión acordada:** **mantener** con transacción · **G/W/T:** AC-07.

#### Regla: “Contraentrega en P0; sin pasarela no hay pedido pagado” (R4)

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | No bloquear el piloto por contrato de pasarela |
| 2 | Preguntas / excepciones | ¿Cliente no paga al recibir? ¿Comercio exige prepago? |
| 3 | Qué puede salir mal | Pedidos de broma; pérdida de producto |
| 4 | Usuarios afectados | Comercio, finanzas |
| 5 | Abusos / evasiones | Pedidos masivos contraentrega |
| 6 | Alternativa propuesta | Tope P0: 3 pedidos `pendiente_*` por cliente; comercio puede exigir prepago más adelante (flag) |
| 7 | Permisos / auditoría / estados | Campo `metodo_pago`; rate limit de creación |

**Decisión acordada:** **mantener** + tope 3 pendientes · **G/W/T:** AC-08.

#### Regla: “El comercio solo ve sus pedidos” (R7)

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | Fuga de demanda y datos personales |
| 2 | Preguntas / excepciones | ¿Operación necesita ver todos? ¿Comercio con dos sucursales? |
| 3 | Qué puede salir mal | Un comercio copia precios/pedidos del vecino |
| 4 | Usuarios afectados | Comercio, cliente (PII) |
| 5 | Abusos / evasiones | Cambiar `comercio_id` en el cliente |
| 6 | Alternativa propuesta | RLS por `comercio_id` del perfil; sucursales = P2 (mismo comercio_id o tabla sucursal) |
| 7 | Permisos / auditoría / estados | Policy SELECT/UPDATE; test no-puede |

**Decisión acordada:** **mantener** · **G/W/T:** AC-02.

#### Regla: “SLA 10 min o el pedido se queda esperando” (R6)

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | Cliente no espera indefinidamente |
| 2 | Preguntas / excepciones | ¿Hora pico? ¿Comercio con un solo empleado? |
| 3 | Qué puede salir mal | Cancelaciones automáticas agresivas matan al comercio |
| 4 | Usuarios afectados | Cliente, comercio |
| 5 | Abusos / evasiones | Comercio ignora y el cliente paga el costo de atención |
| 6 | Alternativa propuesta | **Suavizar:** P0 no auto-cancela; muestra temporizador y botón “Cancelar” al cliente tras 10 min. Auto-cancel = P1 con job |
| 7 | Permisos / auditoría / estados | `aceptar_antes`; cliente puede cancelar `pendiente_comercio` |

**Decisión acordada:** **suavizar** (sin auto-cancel en P0) · **G/W/T:** AC-09.

| Regla | Decisión (mantener/suavizar/reemplazar) | Excepción acordada | G/W/T / auditoría |
|---|---|---|---|
| R1 zona+horario | mantener | Validar al confirmar | AC-04 AC-05 |
| R2 un comercio | mantener | Diálogo vaciar carrito | AC-06 |
| R3 stock atómico | mantener | Segundo cliente pierde | AC-07 |
| R4 contraentrega | mantener | Máx. 3 pedidos pendientes | AC-08 |
| R7 RLS comercio | mantener | Operación sí ve todos | AC-02 |
| R6 SLA 10 min | suavizar | Cliente cancela; no job auto | AC-09 |

**Challenge cerrado:** sí · **Fecha:** 2026-09-11

## 7. Modelo de datos

### 7.1 Entidades

| Tabla / colección | Campos clave | Tipos / notas | Relaciones | Índices |
|---|---|---|---|---|
| `profiles` | `id` (auth.uid), `rol`, `nombre`, `telefono`, `municipio_id`, `activo` | rol enum | `auth.users` | `rol`, `municipio_id` |
| `municipios` | `id`, `nombre`, `habilitado` | text, bool | — | unique nombre |
| `zonas` | `id`, `municipio_id`, `nombre`, `tarifa_domicilio_centavos`, `vigente_desde` | int dinero en centavos COP | municipio | municipio |
| `comercios` | `id`, `owner_id`, `nombre`, `municipio_id`, `zona_id`, `abierto`, `hora_apertura`, `hora_cierre`, `estado_aprobacion` | enum pendiente/activo/suspendido | owner → profiles | municipio, owner |
| `productos` | `id`, `comercio_id`, `nombre`, `sku`, `precio_centavos`, `stock`, `disponible`, `impuesto_bps` | bps = basis points | comercio | comercio, disponible |
| `pedidos` | `id`, `cliente_id`, `comercio_id`, `repartidor_id`, `zona_id`, `estado`, `metodo_pago`, `subtotal_centavos`, `domicilio_centavos`, `propina_centavos`, `comision_centavos`, `total_centavos`, `direccion_texto`, `notas`, `aceptar_antes` | estado ver §7.2 | cliente, comercio | cliente, comercio, estado |
| `pedido_items` | `id`, `pedido_id`, `producto_id`, `nombre_snapshot`, `precio_centavos`, `cantidad`, `subtotal_centavos` | snapshot de precio | pedido, producto | pedido |
| `pedido_eventos` | `id`, `pedido_id`, `de_estado`, `a_estado`, `actor_id`, `nota`, `created_at` | append-only | pedido | pedido |
| `app_config` | `id=1`, `latest_version`, `version_code`, `apk_url`, `sha256`, `force_update`, `changelog` | auto-update | — | — |

Dinero siempre en **centavos COP** (entero) para no usar flotantes.

### 7.2 Ciclo de vida del dato

Estados de pedido (Tomo III + P0):

`creado` → `pendiente_comercio` → `aceptado` → `preparado` → `asignado` → `recogido` → `entregado` → `cerrado`

Excepciones: `cancelado`, `rechazado_comercio`.

- Quién crea: cliente. Edita ítems: nadie tras `pendiente_comercio` (cancelar y repetir).
- Soft delete: sí (`estado` + `deleted_at` en productos/comercios). Pedidos no se borran.
- Offline: no. Conflicto de stock: gana la transacción que decrementa primero.

### 7.3 Seed (día 1)

Usuarios de prueba (contraseñas solo en `.env` local / documentación interna, **nunca** en este expediente ni en git):

- `admin@wammetka.local` — admin  
- `comercio@wammetka.local` — comercio “Tienda Piloto Fonseca”  
- `cliente@wammetka.local` — cliente Fonseca  
- `reparto@wammetka.local` — repartidor  

Datos: municipio Fonseca habilitado; 3 productos (arroz, pan, gaseosa); tarifa domicilio 500000 centavos ($5.000).

### 7.4 Migraciones / rules

- Rutas: `supabase/migrations/`
- Stack: `docs/database/STACK_DB.md` + `CAMINO_POR_STACK.md` § D1
- RLS en todas las tablas `public`. Roles en `profiles.rol` (no en `user_metadata`).

## 8. Arquitectura

| Capa | Elección | Notas |
|---|---|---|
| Cliente | Flutter 3.x (Android + Web) | Cáscaras por rol |
| Estado / DI | Riverpod | Providers por feature |
| Navegación | go_router | Redirect por sesión/rol |
| Backend / BaaS | Supabase | Postgres + Auth + Storage + Realtime (bandeja) |
| Auth | Supabase Auth email | |
| Storage archivos | bucket `apk` (T07); `evidencias` P1 | |
| Notificaciones | N/A P0 (poll/Realtime en bandeja) | Push en P1 |
| Tareas en 2º plano | Descarga APK (T07) | Regla `05` |
| Auto-update | `app_config` + SHA-256 | Regla `12` |
| CI | **GitHub Actions** | Siempre |

```text
[UI Flutter] → [Auth] → [Repos Riverpod] → [Supabase] → [RLS]
         ↑
   [CI: format · analyze · test · build arm64 en main]
```

Estructura de carpetas:

```text
lib/
  app.dart
  theme/
  core/           # config, router, supabase
  features/
    auth/
    catalogo/
    pedido/
    reparto/
    admin/
    update/
  shared/         # widgets (tarjeta acento), formatters
test/
supabase/migrations/
entregas/apk/
```

---

## 9. Seguridad y privacidad

- Clasificación: `docs/SEGURIDAD.md`. Pedidos = personales + financieros. Ubicación precisa = P1.
- Auth: email/contraseña; recuperación Supabase; sesión en cliente oficial.
- Autorización: RLS por `profiles.rol` + `comercio_id` / `cliente_id`. Pruebas + y − en T03/T05.
- Secretos: `.env` local; **GitHub Secrets** en pipeline; anon key en `--dart-define`; nunca `service_role` en APK.
- Rate limiting: tope 3 pedidos pendientes por cliente (R4); Auth rate limit del proyecto.
- Backup / retención: backups de Supabase en staging; pedidos se conservan para conciliación; PII cliente minimizada (nombre, teléfono, dirección de entrega).
- Cumplimiento: Ley 1581/2012 (datos personales Colombia) — aviso de privacidad P1; menores no son público objetivo.
- MFA administrativo: evaluar en piloto (Tomo IV); no bloquea P0.

## 10. Navegación y pantallas

| Pantalla | Ruta | Rol | Entrada visible (tab/menú) | Acciones principales |
|---|---|---|---|---|
| Splash | `/` | todos | arranque | check sesión + auto-update |
| Login | `/login` | anónimo | — | Entrar, crear cuenta |
| Registro | `/register` | anónimo | desde login | Crear cliente |
| Descubrir | `/home` | cliente | tab Inicio | Ver comercios, entrar |
| Catálogo comercio | `/comercio/:id` | cliente | desde tarjeta | Agregar al carrito |
| Carrito | `/carrito` | cliente | tab Carrito | Cambiar qty, confirmar |
| Checkout | `/checkout` | cliente | desde carrito | Confirmar pedido |
| Mis pedidos | `/pedidos` | cliente | tab Pedidos | Ver estado |
| Detalle pedido | `/pedidos/:id` | cliente | lista | Cancelar si pendiente |
| Catálogo propio | `/comercio/catalogo` | comercio | tab Catálogo | Alta/editar SKU |
| Bandeja comercio | `/comercio/pedidos` | comercio | tab Pedidos | Aceptar/rechazar |
| Ofertas reparto | `/reparto` | repartidor | tab Servicios | Aceptar servicio |
| Pedidos operación | `/admin/pedidos` | operación/admin | menú | Ver todos |
| Config | `/admin/config` | admin | menú | Zonas (P1) |

Mapa: login → shell por rol → módulos.  
Auditoría: `docs/manual/AUDITORIA_NAVEGACION.md` (cuando haya UI).

## 11. Diseño visual

| Ítem | Valor |
|---|---|
| Ruta UI | V1 Stitch MD |
| Fuente de verdad UI | `docs/stitch/PANTALLAS_PARA_STITCH.md` |
| HTML Stitch | Solo al final del visual, a mano |
| Tokens | Primario `#0F6B5C`, acento `#E87B3A`, fondo `#F7F4EF`, texto `#1A1F1C`, error `#B42318`, radio 16, espacio 8 |
| Tema base en código | `lib/theme/wammetka_theme.dart` (T01) |
| Auditoría | `docs/AUDITORIA_VISUAL.md` |

## 12. Criterios de aceptación

| ID | Módulo | Given | When | Then | Prueba (`test` / `smoke`) | Evidencia |
|---|---|---|---|---|---|---|
| AC-01 | Auth | Usuario seed cliente | Entra con email/clave correctos | Ve shell cliente (tab Inicio) | `test` | T05 |
| AC-02 | Auth | Usuario seed cliente | Intenta leer pedidos de otro comercio (API) | 0 filas / error permiso | `test` | T05 no-puede + `AuthPolicy.canReadForeignPedidos` |
| AC-03 | Pedido | Carrito con SKU y dirección | Confirma con cantidad válida | Pedido en nube `pendiente_comercio` y total = ítems + domicilio | `test` + `smoke` | `pedido_nucleo_test` + Redmi pedido `a6fb5a34-…360e` total 950000 |
| AC-04 | Pedido | Comercio cerrado | Cliente pulsa confirmar | Error en español; no hay fila pedido | `test` | `OrderRules.canConfirm` cerrado |
| AC-05 | Pedido | Municipio no habilitado | Confirma | Error cobertura; no hay pedido | `test` | `OrderRules.canConfirm` municipio |
| AC-06 | Pedido | Carrito de comercio A | Agrega SKU de comercio B | Diálogo vaciar o rechazo; no mezcla | `test` | `CartController.tryAdd` mix + `replaceWith` |
| AC-07 | Pedido | Stock = 1 | Confirma cantidad 2 | Error stock; stock intacto | `test` | `cantidadVsStock` + tryAdd noStock |
| AC-08 | Pedido | Cliente con 3 pedidos pendientes | Intenta un 4.º | Error tope; no crea | `test` | `OrderRules.canConfirm` tope 3 |
| AC-09 | Pedido | Pedido `pendiente_comercio` > 10 min | Cliente cancela | Estado `cancelado`; stock revertido | `smoke` | T06 UI Cancelar pedido (RPC lista; no ejercido en smoke +3) |
| AC-10 | Pedido | Comercio dueño | Abre bandeja | Ve el pedido nuevo y puede aceptar | `smoke` | Redmi bandeja `Cliente Piloto` → `Aceptado` |
| AC-11 | Update | `version_code` remoto > local | Arranca app | Ofrece/descarga update; si sha256 no coincide no instala | `smoke` | T07 |

Casos: éxito · error · vacío · **sin permiso** · excepción `CG.challenge` · sin red (mensaje, no éxito falso).  
Plantilla y 3 tests mínimos: `docs/QA_MINIMO.md`. Sin fila `test` o `smoke` → no Converge.

## 13. Pruebas y verificación

- Calidad Asegurada (Quality Assurance, QA) mínimo: `docs/QA_MINIMO.md`.
- Comandos: `docs/VERIFICACION.md` (los mismos que GitHub Actions).
- Evidencias: `docs/evidencias/REGISTRO.md` (incluir URL de pipeline).
- **CI:** `.github/workflows/ci.yml` desde T02.
- Entorno de prueba: APK arm64 en teléfono + auto-update.
- Plugin GitHub en Cursor para pipelines y solicitudes de extracción (Pull Request, PR).

## 14. Despliegue y operación

| Entorno | ID / URL | Datos | Quién despliega |
|---|---|---|---|
| Dispositivo / local | APK + `flutter run -d chrome` solo complemento | sintéticos | dev |
| Staging | Supabase Wammetka (T03) | sintéticos | tras CI verde |
| Producción | N/A hasta puerta Tomo VI “antes de piloto” | reales | aprobación |

- Publicación APK / auto-update: `docs/PUBLISH_APK.md` + `entregas/apk/`.
- **CD (opcional):** job manual; no sustituye CI ni prueba en teléfono.
- Runbook: `docs/RUNBOOK.md` (ampliar en cierre).
- Rollback: APK anterior en Storage / revertir migración.

## 15. Decisiones técnicas (ADR resumidos)

| Fecha | Decisión | Alternativas | Por qué |
|---|---|---|---|
| 2026-09-11 | Supabase D1 | Firebase, ERP monolítico propio | Pedido + split + RLS relacional; tomos piden integridad y liquidación |
| 2026-09-11 | Flutter Android+Web | Nativo dual, solo web | Un código, APK directo, auto-update del molde |
| 2026-09-11 | GitHub Actions | GitLab CI | Conector GitLab no autenticado; YAML GitHub ya en el kit |
| 2026-09-11 | Contraentrega P0 | Bloquear por pasarela | Tomo II exige pasarela para economía; P0 debe ser demostrable |
| 2026-09-11 | Una app / cuatro roles | Cuatro APKs | Menos rework; RLS separa datos |

Detalle: `docs/decisions/ADR-001-supabase-flutter.md`.

## 16. Entregables y cierre

- [ ] Expediente alineado con la app real  
- [x] Pipeline verde en rama principal de GitHub (run 34656548482, 2026-09-11)  
- [ ] APK / artefacto nombrado  
- [ ] Auto-update (Android APK directo)  
- [ ] Manual por rol (obligatorio al cierre del piloto)  
- [ ] Bitácora con horas (`BITACORA_DESARROLLO.md`)  
- [ ] Lecciones generalizadas  
- [ ] Deuda técnica con dueño y fecha  

---

## 17. Contratos e integraciones

| Sistema | Uso | Auth | Entornos | Errores esperados | Dueño |
|---|---|---|---|---|---|
| Supabase Auth/DB/Storage | Fuente de verdad | anon + RLS; service_role solo server | local + staging + prod | 401, RLS 0 rows, timeout | Tecnología |
| Pasarela (P1) | Prepago / split | Adaptador + webhook idempotente | sandbox → prod | firma inválida, reintento | Finanzas + Prod |
| Mapas (P1) | ETA / ruta | clave servidor o SDK | cuota | degradar a dirección texto | Operaciones |
| Mensajería (P1) | Push / WhatsApp soporte | cola | no duplicar alertas | Producto |

P0 no llama pasarela ni mapas. Payloads: webhook P1 se documentará en spec Pagos.

## 18. Requisitos no funcionales

| Tema | Objetivo | Cómo se verifica |
|---|---|---|
| Tiempo de arranque / flujo crítico | Splash < 3 s en teléfono medio; confirmar pedido < 3 min seed | smoke T06 |
| Offline / red lenta | Error accionable; no éxito falso | cortar datos en T06 |
| Volumen (usuarios, filas) | Piloto: decenas de comercios, cientos de pedidos/semana | índices §7.1; no optimizar prematuro (Tomo IV) |
| Accesibilidad | Contraste tokens, áreas táctiles 48, textos en español | auditoría visual |
| Idiomas / locales | Español Colombia, COP | `intl` + centavos |
| Dispositivos objetivo | Android 8+ arm64; Chrome desktop para admin | APK + web |

## 19. Operación y soporte

- Alertas / Crash reporting / logs: Crashlytics o equivalente en P1; P0 = logs Flutter + tabla `pedido_eventos`.
- Responsable de incidente: Operaciones (Tomo VI) — nombre concreto pendiente de asignación humana.
- Backup y restore: plan Supabase al crear proyecto (T03).
- Procedimiento de hotfix: APK anterior + auto-update; migración down documentada.
- Cambio de tarifa: vigencia futura, nunca retroactiva (Tomo VI).

## 20. Trazabilidad

| Módulo | Spec | Pipeline job | Release / tag | Manual |
|---|---|---|---|---|
| Auth | `MODULO_AUTH.md` | verify (test) | _(T05)_ | cliente / comercio |
| Catálogo | `MODULO_CATALOGO.md` | verify | _(T06)_ | comercio |
| Pedido | `MODULO_PEDIDO.md` | verify + smoke | _(T06)_ | cliente / comercio |
| Auto-update | `MODULO_ACTUALIZACION.md` | build_apk | _(T07)_ | todos |
| CI | `CI_CD.md` | format/analyze/test/build | T02 | — |

---

_Si el expediente y el código divergen, el expediente está mal: actualizarlo en el mismo turno que el cambio._
