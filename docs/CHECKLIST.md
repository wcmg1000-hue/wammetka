# Checklist del proyecto

Marca `[x]` solo con evidencia observada en `docs/evidencias/REGISTRO.md`. Usa `N/A — motivo` cuando una ruta no aplique.

**Proyecto:** Wammetka  
**Fase actual:** 4 — Converge P0 OK. T08 Despacho DOING. T03 local Docker N/A.

## Fase 0 — Preparación reproducible

- [x] Código Germinación copiado y proyecto abierto.
- [x] Git inicializado (`main`). Primer commit en este turno (T02/T03).
- [x] `.gitignore` revisado antes del primer commit.
- [x] `.env` creado solo si hace falta; secretos fuera del repo y del chat. (plantilla `.env.example`; `.env` en T03)
- [x] Versiones de SDK/runtime registradas. Flutter 3.47.2 · Dart 3.13.2 · 2026-09-11
- [x] `docs/evidencias/REGISTRO.md` disponible.

**Puerta:** repositorio recuperable y sin secretos detectados.

## Fase 1 — Descubrimiento (Clarify + Specify)

- [x] **Clarify** cerrado en `PROJECT_PROFILE.md` (flujo crítico, roles, offline/pagos, ritmo, hecho día 1, fuera de alcance).
- [x] Problema, usuario y resultado de negocio definidos.
- [x] Flujo crítico de valor definido.
- [x] Roles y matriz preliminar de permisos.
- [x] Alcance incluido, excluido y criterio de éxito.
- [x] **Plataforma(s)** definidas (Android APK + Web).
- [x] **Datos: nube vs solo local** (nube → D1 Supabase).
- [x] Ritmo: proyecto completo (CI = GitHub Actions).
- [x] Conectividad, accesibilidad e integraciones.
- [x] Datos personales/sensibles identificados.
- [x] Supuestos numerados, reversibles y riesgos principales.
- [x] **Specify:** Given/When/Then del flujo crítico (3–8) en expediente, con al menos un caso “no puede”.
- [x] **CG.challenge:** reglas del flujo crítico cuestionadas → expediente §6.1. Ver `ANALISIS_REGLAS_NEGOCIO.md`.

**Puerta:** Clarify OK + G/W/T + challenge (o N/A); listo para Plan.

## Fase 2 — Plan (perfil, expediente, TASKS)

- [x] `docs/PROJECT_PROFILE.md`: constitution + decisiones + rutas V1–V4 / D1–D5.
- [x] **Decisiones cerradas** + ritmo; D1: leído `CAMINO_POR_STACK.md`.
- [x] `docs/TASKS.md` con T01…T07 (P0) + T08–T10 posteriores.
- [x] `BITACORA_DESARROLLO.md` lista (tiempos por sesión para cobro).
- [x] Stack elegido por necesidad, costo, experiencia y operación.
- [x] `docs/EXPEDIENTE_TECNICO.md` **siempre**: completo §§1–20 + specs P0.
- [x] Specs `docs/specs/` AUTH, CATALOGO, PEDIDO, ACTUALIZACION.
- [x] Navegación/contratos y estructura de carpetas documentados.
- [x] Primera rebanada vertical = tareas concretas en `TASKS.md`.
- [x] Repo **GitHub o GitLab** identificado (URL y elección en perfil/expediente). https://github.com/wcmg1000-hue/wammetka
- [x] `docs/SEGURIDAD.md` revisado y riesgos registrados.
- [x] `docs/VERIFICACION.md` con comandos exactos (= jobs del remoto).
- [x] ADR para decisiones costosas o difíciles de revertir.

**Puerta:** Plan listo; siguiente acción = `CG.implement` sobre la primera `TODO`.

## Fase 2V — Diseño visual (condicional)

- [x] V1: `PANTALLAS_PARA_STITCH.md` generado (texto pegable); implementar desde el MD; o
- [ ] V1 (solo al **final** del visual): HTML manual en `export/screens/` si se adopta diseño Stitch; o
- [ ] V2 externo / V3 tokens / V4 N/A.
- [x] Fuente visual: MD
- [x] Dispositivo de prueba anotado en perfil/TASKS (APK+teléfono).

**Puerta:** en V1 la fuente es el MD. Sin MCP/ID Stitch. HTML no bloquea el inicio. (APK/auto-update = Fase 3 si aplica.)

## Fase 2D — Datos (local = schema/rules; producto = dispositivo)

- [x] `docs/database/STACK_DB.md` completo con entornos y servicios necesarios.
- [ ] **Local (datos):** N/A — Docker no instalado. Schema aplicado en staging cloud.
- [ ] Si Firebase cloud: N/A — stack D1.
- [x] Migraciones versionadas y reversibilidad evaluada.
- [x] Seed sintético reproducible (**día 1**): usuarios/roles de prueba listos.
- [x] RLS/Security Rules/autorización implementadas.
- [ ] Pruebas positivas y negativas de permisos pasan **en local**. _(N/A Docker; staging: login seed + no-puede autoascenso PASS en test live)_
- [x] Si nube: tras local OK → **1 smoke cloud** desde el **dispositivo del perfil** (staging/dev; sin `catch` vacío). `Guardar perfil` → `telefono=3001234567`
- [ ] Lint/pruebas de BD pasan. _(advisors: `crear_pedido` definer a authenticated es intencional; HIBP Auth WARN)_
- [ ] Staging separado de producción preparado (o N/A solo local).
- [x] Credenciales privilegiadas ausentes del cliente.

**Puerta:** schema/permisos OK en local; smoke de producto en dispositivo del perfil cuando hay nube.

## Fase 3 — Primera rebanada vertical

Orden: T01 scaffold → T02 CI → T03/T04 seed+smoke → T05 auth+tests → T06 flujo → T07 auto-update si APK.

- [x] Scaffold y estructura real del stack. (`flutter analyze` + APK arm64 + smoke Redmi 68486ddd)
- [x] Tema/componentes base cuando existe UI. (`lib/theme/`)
- [x] **CI del remoto** (T02): format + analyze + test verdes (PR/MR y default); build **arm64** verde en default — ver `CI_CD.md`. Run https://github.com/wcmg1000-hue/wammetka/actions/runs/34656548482
- [x] Flujo crítico UI/API → auth → autorización → dato (**sin mocks permanentes**). Pedido seed en nube + bandeja comercio aceptó (T06).
- [x] Given/When/Then con dueño (`test` o `smoke` en §12); **3 tests núcleo** (auth / no-puede / validación) — `QA_MINIMO.md`. Pedido: AC-03/07/04/06 en test; AC-03/10 smoke.
- [x] Smoke en **dispositivo del perfil** (Android → APK + teléfono; web → navegador; etc.). Auth + pedido contraentrega + aceptar en Redmi 68486ddd.
- [x] **Auto-update** si Android APK directo; si no, N/A — motivo. Redmi 68486ddd `versionCode` 4 → 5; SHA-256 verificado.
- [x] URL pipeline + PASS en `REGISTRO.md`.

**Puerta:** flujo real en dispositivo del perfil + analyze/test/build verdes + REGISTRO.

## Fase 4 — Implementación por módulo (Tasks → Implement → Converge)

### Módulo: P0 Pedido contraentrega (T01–T07)

- [x] Spec / criterio de la tarea `TASKS.md` leídos.
- [x] Criterios de aceptación y matriz rol × acción cubiertos. AC-01…AC-11 con dueño.
- [x] **Una sola** tarea atómica `TODO` a la vez (`CG.implement`). T08 es la DOING.
- [x] Validación, errores, loading, vacío, offline y concurrencia tratados según aplique.
- [x] Tareas pesadas no bloquean la UI.
- [x] Tests del núcleo: los 3 mínimos existen; ampliar si la tarea tocó dominio.
- [x] Puerta DONE: format/analyze + tests núcleo + smoke en dispositivo del perfil + **REGISTRO**.
- [x] Build verde y pipeline del remoto verde.
- [x] **Converge** OK: G/W/T sin huérfanos + regresión corta (`QA_MINIMO.md`). 2026-09-11.
- [x] Documentación y evidencia actualizadas.

### Pantalla: __________ (si aplica)

- [ ] Inventario funcional y visual 1:1 contra la fuente elegida (MD por defecto).
- [ ] Navegación, estados, permisos y acciones depurados.
- [ ] Captura comparada y diferencias corregidas, o auditoría estándar V3.
- [ ] Accesibilidad básica: contraste, tamaño, foco/teclado y lectores según plataforma.
- [ ] Registrada en `docs/AUDITORIA_VISUAL.md` y checkpoint Git.

**Puerta:** no avanzar si fallan build, criterios o CI del remoto.

## Fase 5 — Staging y aceptación

- [ ] Despliegue automático o reproducible a staging.
- [ ] Migraciones aplicadas en staging y verificadas.
- [ ] Smoke test del flujo crítico pasa.
- [ ] Pruebas de roles, abuso, reglas/RLS y endpoints públicos pasan.
- [ ] Dependencias, secretos y análisis estático revisados.
- [ ] App Check/antiabuso activado cuando aplica.
- [ ] Crash reporting, logs, métricas y alertas funcionan.
- [ ] Pruebas en dispositivos/navegadores objetivo.
- [ ] Usuario responsable acepta criterios funcionales.

**Puerta:** staging representa producción y no tiene defectos críticos abiertos.

## Fase 6 — Producción

- [ ] Aprobación explícita de despliegue.
- [ ] Backup previo y restauración probada cuando aplica.
- [ ] Plan de rollback de app y migración.
- [ ] Variables y permisos de producción revisados por mínimo privilegio.
- [ ] Artefacto firmado/versionado; publicación por canal correcto.
- [ ] Migraciones y despliegue ejecutados de forma reproducible.
- [ ] Smoke test post-despliegue pasa.
- [ ] Monitoreo revisado y responsable informado.

**Puerta:** el servicio está operativo, observable y recuperable.

## Fase 7 — Cierre

- [ ] `EXPEDIENTE_TECNICO.md` refleja lo construido.
- [ ] Manual por rol con capturas reales (N/A si demo rápido sin deliverable de manual).
- [ ] Runbook de operación, backup, rollback e incidentes (N/A si solo demo local).
- [ ] `LECCIONES_APRENDIDAS.md` actualizado de forma generalizada.
- [ ] `docs/BITACORA_DESARROLLO.md` con **todas** las ejecuciones (inicio/fin/minutos) y total para cobro.
- [ ] Resumen cualitativo (1 error / 1 acierto) al cerrar.
- [ ] Si hubo APK: artefacto **nombrado** en carpeta de entrega del cliente.
- [ ] Riesgos aceptados y deuda técnica con responsable/fecha.
- [ ] Etiqueta/release final y artefactos identificados.

## Módulo obligatorio — Auto-update APK (si hay Android APK directo)

> Si el proyecto **no** distribuye APK fuera de tienda: marcar todo `N/A — sin APK directo`.

- [x] Decisión: APK directo (auto-update ON) / Play o sin Android (`N/A`).
- [x] Spec `MODULO_ACTUALIZACION.md` seguida.
- [x] Fuente de verdad: **`versionCode` / `buildNumber`** vs `app_config.version_code` o Remote Config `version_code` (semver `latest_version` solo si `version_code` es null).
- [x] APK firmado, **misma keystore**; publicación de `version_code` + `sha256` + `apk_url` (build: `--target-platform android-arm64` o split-per-abi arm64).
- [x] Tras descargar: SHA-256 hex minúsculas; si el remoto no está vacío y no coincide → borrar, no instalar, error en español.
- [x] Descarga no bloqueante, permisos, prueba en teléfono sin romper la app si falla red.
- [x] No-op en iOS; no usar si el canal es Google Play.

## Notas

- 2026-09-11: Tomos PDF I–VI mapeados al molde. Huecos de los PDF (plataforma, cloud, G/W/T, CI, modelo de tablas) cerrados con supuestos S1–S8 en el perfil.
- 2026-09-11: T02 DONE — repo público + Actions PASS (verify + build_apk). T05 sigue DOING (falta teléfono). T01 sin smoke.
- 2026-09-11: APK `wammetka-v0.1.0+2-arm64.apk` (dart-define cliente). adb `68486ddd` Redmi 23129RA5FL. Install `USER_RESTRICTED` (Xiaomi: Instalar vía USB / aceptar diálogo). T01/T04/T05 no DONE.
- 2026-09-11: Reintento install SUCCESS. T01/T04/T05 DONE en Redmi. Siguiente T06.
- T03 no debe usar el project-ref de otro aplicativo de la org.
- 2026-09-11: T07 DONE. Instalado 4 vs remoto 5; diálogo + hash OK; `dumpsys versionCode=5`. URL pública Storage `apk/releases/wammetka-v0.1.0+5-arm64.apk`. CI https://github.com/wcmg1000-hue/wammetka/actions/runs/34662746664

