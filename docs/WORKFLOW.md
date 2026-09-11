# Flujo de trabajo — Código Germinación

Guía para convertir una idea en un aplicativo funcionando con el mínimo trabajo desperdiciado y con evidencia reproducible.

## Principios

1. Seguridad y protección de datos antes que velocidad aparente.
2. Elegir herramientas según el proyecto; Stitch, Flutter y una BD no son universales.
3. Local primero; staging antes de producción.
4. Probar temprano una rebanada vertical completa.
5. **CI obligatoria en el remoto del perfil (GitHub Actions o GitLab CI)** desde la 1ª rebanada. Marcar uno. Plugin Cursor según elección. CD opcional (`docs/CI_CD.md`).
6. Un módulo a la vez; no avanzar con build, pruebas o pipeline en rojo.
7. Un checkbox sin evidencia no prueba nada. **Sin fila PASS en REGISTRO no hay DONE.**
8. Documentar decisiones costosas, no producir documentación especulativa.
9. **Velocidad real = menos rework:** decisiones cerradas, run verde temprano, pre-flight cloud, sync visible, seed día 1.
10. **V1 Stitch = MD-first:** implementar desde `PANTALLAS_PARA_STITCH.md`; HTML **manual** solo al finalizar el visual. Sin MCP ni ID Stitch.
11. **Stack guiado:** D1 Supabase / D2 Firebase (`CAMINO_POR_STACK.md`).
12. **Preguntar plataforma** (web/Android/iOS/desktop…) y **nube vs solo local** al inicio del descubrimiento.
13. **Android APK directo → auto-update obligatorio** (regla `12`). Prueba en teléfono (no Chrome/AVD como estándar).
14. **Bitácora única:** `BITACORA_DESARROLLO.md` (tiempos + retrospectiva) cada sesión.
15. **Expediente técnico siempre** (`EXPEDIENTE_TECNICO.md`): demo = §§1–8 (9–16 N/A con motivo, `docs/MODO_DEMO.md`); proyecto completo = §§1–20 + specs por módulo.
16. **Clarify → Specify → Challenge → Plan → Tasks → Implement → Converge** (`PROJECT_PROFILE`, `TASKS.md`, regla `17`). Una tarea atómica a la vez.
17. **Menos rework:** orden canónico en `docs/RECETA_MENOS_REWORK.md`.
18. **Local ≠ producto:** local = schema/RLS/rules; prueba de producto = **dispositivo del perfil**.
19. **CG.challenge:** cuestionar reglas de negocio del flujo crítico antes de Plan (`ANALISIS_REGLAS_NEGOCIO.md`).

## Aceleradores (orden canónico)

Antes: Clarify · Specify (G/W/T) · **Challenge** (reglas §6) · Plan (TASKS 5–12 + VERIFICACION).

Durante:

1. T01 scaffold → T02 **CI** (format + analyze + test; build arm64 en default).
2. T03 seed/rules locales → T04 smoke cloud desde dispositivo del perfil (si nube).
3. T05 auth + **tests del núcleo** → T06 flujo crítico en dispositivo.
4. T07 auto-update solo si Android APK directo.
5. Cada `DONE`: analyze · tests núcleo · smoke en dispositivo del perfil · **REGISTRO** (fail closed).

Al cerrar módulo: Converge · bitácora · lección si patrón nuevo.

## Máquina de estados

| Etapa | Resultado | Puerta de salida |
|---|---|---|
| 0 Preparación | Git, entorno y secretos controlados | repo recuperable y escaneo limpio |
| 1 Descubrimiento | Clarify + Specify + **Challenge** (reglas flujo crítico) | Clarify + G/W/T + §6.1 OK |
| 2 Perfil/arquitectura | Plan: perfil, expediente, **TASKS.md**, VERIFICACION | T01… definidas |
| 2V Diseño condicional | MD Stitch / externo / tokens / N/A | fuente visual OK (sin exigir APK) |
| 2D Datos | local = schema/rules; luego smoke en dispositivo si nube | local + smoke producto OK |
| 3 Rebanada | T01→T07: scaffold, CI, seed, auth, flujo, auto-update si APK | dispositivo del perfil + CI verde |
| 4 Módulos | tareas atómicas + Converge por módulo | DoD + Converge OK |
| 5 Staging | aceptación, seguridad y observabilidad | sin críticos abiertos |
| 6 Producción | release operativo y recuperable | smoke test verde |
| 7 Cierre | expediente, manual y operación | entrega trazable |

No saltar una puerta aplicable. Lo no aplicable se marca `N/A` con motivo en `CHECKLIST.md`.

## Etapa 0 — Preparación

1. Inicializar Git inmediatamente, antes de generar código.
2. Revisar `.gitignore`, copiar `.env.example` solo si hace falta y no pegar secretos en el chat.
3. Registrar versiones de SDK/runtime.
4. Crear primer commit de la plantilla.
5. Preparar `docs/evidencias/REGISTRO.md`.

## Etapa 1 — Descubrimiento breve

Preguntar por bloques, máximo 8–12 preguntas por mensaje:

- Contexto: greenfield/existente, MVP/producción, plazo y presupuesto.
- Negocio: problema, usuario, resultado y flujo principal de valor.
- Roles: quién puede ver/hacer qué; administración y soporte.
- Plataforma: web/móvil/API/desktop, offline, idiomas y accesibilidad.
- Datos: personales/sensibles, volumen, residencia, retención y eliminación.
- Integraciones: pagos, mensajes, archivos, hardware, servicios externos.
- Operación: distribución, responsable, soporte, monitoreo y recuperación.
- Alcance: incluido, excluido, supuestos y criterio de éxito.

Si falta información no crítica, usar supuestos numerados y reversibles. No inventar datos sensibles.

## Etapa 2 — Perfil y arquitectura mínima

Completar `PROJECT_PROFILE.md` y elegir una ruta visual:

- V1 Stitch (MD-first): `PANTALLAS_PARA_STITCH.md` pegable; implementar desde MD; HTML manual al final del visual. Sin MCP/ID.
- V2 Diseño externo: Figma, HTML, capturas o sistema existente.
- V3 UI estándar: tokens/componentes mínimos definidos en el proyecto.
- V4 Sin UI: omitir diseño y auditoría visual.

Elegir una ruta de datos y abrir `docs/database/CAMINO_POR_STACK.md` si D1/D2:

- D1 Supabase/Postgres (camino Supabase).
- D2 Firebase (camino Firebase + pre-flight).
- D3 SQL propio local/contenedor.
- D4 API existente con contrato/mock/sandbox.
- D5 sin persistencia.

Entregables mínimos:

1. Alcance, roles, flujo crítico y G/W/T (expediente).
2. Criterios verificables: en **demo** viven en el expediente; **specs sueltos** solo en proyecto completo.
3. Navegación o contratos API.
4. Modelo de datos preliminar.
5. Matriz rol × acción.
6. Arquitectura y carpetas del stack real.
7. `SEGURIDAD.md` y riesgos aceptados.
8. `VERIFICACION.md` + `TASKS.md`.
9. ADR solo para decisiones difíciles de revertir.
10. Primera rebanada = primeras filas de `TASKS.md`.

## Etapa 2V — Diseño condicional

### V1 Stitch (MD-first)

1. Generar `PANTALLAS_PARA_STITCH.md` (texto **idéntico** al pegable en Stitch).
2. Implementar desde el MD; probar en el **dispositivo del perfil** (Android → APK en el teléfono).
3. Usuario puede pegar el MD en Stitch en paralelo.
4. Al **finalizar todo el visual**: si prefiere Stitch, entrega HTML a mano → adaptar.
5. **Sin** MCP ni ID de proyecto Stitch.

### V2 Diseño externo

Guardar enlaces/exportaciones y registrar versión, permisos de uso, tokens, fuentes, componentes, iconos y breakpoints. No exigir Stitch.

### V3 UI estándar

Definir un sistema mínimo antes de pantallas: colores, tipografía, espaciado, radios, inputs, botones, tarjetas, iconos, estados y accesibilidad. Priorizar componentes nativos y consistencia.

### V4 Sin UI

Marcar diseño, tema y auditoría visual como `N/A — sin interfaz`.

En V1–V3 diseñar también loading, vacío, error, sin permiso, offline y éxito cuando apliquen.

## Etapa 2D — Datos (local primero para schema; producto en dispositivo)

**No** usar producción. Dos capas:

1. **Local (datos):** emulador / Supabase local / SQL — migraciones, seed, RLS/rules +/−.  
2. **Producto:** smoke del DoD en el **dispositivo del perfil** (Android → teléfono; web → navegador). Si hay nube: 1 escritura visible en staging/dev tras local OK.

- Supabase: `supabase start` → migraciones → seed → `db reset` / lint / test db.
- Firebase: Emulator Suite → rules +/− → luego smoke desde dispositivo a proyecto de desarrollo.
- SQL propio / API: local o sandbox; luego smoke en el cliente del perfil.

Staging separado. Producción = Etapa 6.

## Etapa 3 — Primera rebanada vertical

Antes de construir todos los módulos, implementar el flujo más pequeño que atraviese las capas reales aplicables:

```text
entrada UI/API → validación → autenticación → autorización → dato/servicio → respuesta → prueba → build
```

Esta etapa debe detectar temprano problemas de toolchain, navegación, SDK, permisos, migraciones y despliegue.

**CI (siempre, desde T02 tras scaffold):** YAML del remoto elegido = comandos de `VERIFICACION.md`. Plugin GitHub y/o GitLab según `PROJECT_PROFILE`. Detalle: `docs/CI_CD.md`.

CI mínima (ver `CI_CD.md`):

1. **Format** + **analyze** + **test** del núcleo — en PR/MR y rama default.
2. **Build** del artefacto **arm64** — solo en rama default (no en cada PR/MR).
3. Tests del núcleo: **3 mínimos** en T05/T06 (`QA_MINIMO.md`); no cerrar rebanada con suite vacía. Cada G/W/T → test o smoke.

Rules/RLS: Fase 2D local; job CI opcional por stack, no en el YAML base.

**CD:** opcional, con aprobación (`docs/PUBLISH_APK.md`); no sustituye CI ni smoke en dispositivo.

## Etapa 4 — Implementación incremental

Por cada módulo:

1. Leer spec, fuente visual y modelo de datos.
2. Implementar un incremento pequeño.
3. Probar éxito, error, vacío y permisos aplicables.
4. Ejecutar comandos de verificación.
5. Auditar la pantalla si existe UI.
6. Registrar evidencia y commit de checkpoint.
7. Continuar solo con CI verde + verificación en dispositivo.

Definition of Done:

- Criterios de aceptación cubiertos.
- Autorización probada en backend/BD, no solo UI.
- Validaciones y errores controlados.
- Tareas pesadas no bloquean la interfaz.
- Pruebas y build pasan en plataforma objetivo.
- Fila PASS en `REGISTRO.md` (sin ella no hay DONE).
- No hay vulnerabilidades críticas/altas sin decisión registrada.
- Documentación y evidencias actualizadas.

## Etapa 5 — Staging y aceptación

1. Desplegar reproduciblemente a staging.
2. Aplicar migraciones y comprobar compatibilidad.
3. Ejecutar smoke test del flujo crítico.
4. Probar roles, reglas/RLS, abuso y endpoints públicos.
5. Verificar secret scanning, dependencias y SAST aplicable.
6. Activar App Check/antiabuso cuando corresponda.
7. Verificar crash reporting/logs, métricas y alertas.
8. Probar dispositivos, navegadores y conectividad objetivo.
9. Obtener aceptación funcional.

## Etapa 6 — Producción

Producción es una mutación externa y requiere aprobación explícita.

Antes:

- Backup y restauración probada si hay datos.
- Rollback de aplicación y migración.
- Variables, dominios y permisos de mínimo privilegio.
- Artefacto firmado/versionado y canal de distribución correcto.

Después:

- Smoke test inmediato.
- Revisión de errores, latencia y alertas.
- Registrar versión, commit, migraciones, responsable y evidencia.

## Etapa 7 — Cierre y operación

- Consolidar `EXPEDIENTE_TECNICO.md` con lo real.
- Manual por rol con capturas reales.
- Runbook: despliegue, rollback, backup, restauración, monitoreo e incidentes.
- Actualizar `LECCIONES_APRENDIDAS.md` en forma generalizada.
- Completar `docs/BITACORA_DESARROLLO.md` (ejecuciones + totales de horas para **cobro** + retrospectiva).
- Registrar deuda y riesgos con responsable y fecha.
- Crear release/tag final.

## Seguridad por riesgo

Usar `SEGURIDAD.md` como base y ampliar con OWASP ASVS cuando el aplicativo maneje información sensible, dinero, salud, menores, administración privilegiada o exposición pública importante.

Reglas permanentes:

- Autorización en servidor/BD.
- Configuración pública no equivale a secreto; secretos del servidor nunca viajan al cliente.
- Logs no contienen tokens, contraseñas ni datos sensibles.
- Rate limit y antiabuso en superficies públicas.
- Backups sin restauración probada no cuentan como recuperación.
- “Compila” no significa “seguro” ni “listo para producción”.

## Herramientas recomendadas por contexto

| Necesidad | Preferencia | Alternativas |
|---|---|---|
| Móvil multiplataforma | Flutter | nativo, React Native |
| Web/admin | framework web del equipo | Flutter web si se justifica |
| Relacional/RLS | Supabase/Postgres local-first | SQL gestionado |
| Offline/tiempo real móvil | Firebase + emuladores | Supabase Realtime |
| Diseño de alta fidelidad | Stitch o Figma | diseño existente |
| CRUD simple/prototipo | generación asistida o low-code evaluado | FlutterFlow |
| CI/CD | **GitHub Actions o GitLab CI** (marcar uno) + plugin Cursor | CD opcional con aprobación; Codemagic solo si se acuerda |
| Observabilidad | Crashlytics o Sentry | proveedor existente |

No cambiar herramientas por moda: documentar costo, lock-in, experiencia del equipo, seguridad, operación y salida.

