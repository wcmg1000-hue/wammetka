# Camino por stack de datos

> Primero, en descubrimiento: **¿datos en la nube o solo local?**  
> - **Nube (~99 %):** elegir D1 (Supabase) o D2 (Firebase) y seguir la sección.  
> - **Solo local:** D3/D5 o SQLite en dispositivo; **no** forzar proyecto cloud ni Remote Config de producción.  
> El asistente **debe** leer este archivo cuando el perfil marque **D1** o **D2**.

Marcar en el perfil **exactamente una** ruta D1–D5. Luego seguir solo la sección correspondiente.

---

## D2 — Firebase (camino recomendado)

### Pre-flight (antes de código de producto)

1. `firebase login` en **terminal externa** (no en el shell del agente). Verificar `firebase projects:list`.
2. Si usas `gcloud`: `gcloud auth login` + `gcloud auth application-default login` (sesiones distintas a Firebase CLI).
3. Project ID acordado + `firebase use <id>`.
4. Checklist usable (ver `CONECTAR_BD.md`):
   - [ ] APIs habilitadas (Firestore, Identity Toolkit, Storage si aplica)
   - [ ] Base `(default)` creada
   - [ ] Apps Android/Web registradas
   - [ ] Auth Email/Password activado si el login lo usa
   - [ ] Plan: **Blaze** si hay Storage/Functions/APK; Spark solo sin archivos
5. Emuladores locales cuando se pueda (`firebase emulators:start`) antes de staging.

### Orden de trabajo (rápido y seguro)

1. Scaffold app → run verde.
2. Conectar Firebase (`flutterfire configure` / options por flavor).
3. Rules + indexes → `firebase deploy --only firestore:rules,firestore:indexes`.
4. Seed staging (nunca asumir “hay proyecto” = hay datos). Firestore **no tiene tablas**: las colecciones aparecen al escribir.
5. Si la nube es requisito: **Firestore-first** o sync **visible** (nunca `catch` vacío).
6. Storage solo si hay archivos; activar en consola + Blaze.
7. Smoke: una escritura vista en consola desde el dispositivo.

### Anti-patrones Firebase

- Mezclar dos CLIs con credenciales distintas sin pre-flight.
- `firebase open` genérico (usar producto concreto).
- Seed PowerShell que hace `Write-Output` del UID (corrompe IDs).
- Espejo local→nube silencioso.
- Relajar rules para “que compile el flujo”.

### Lecciones clave

`LECCIONES_APRENDIDAS.md` fichas **3.1–3.11**, **3.23–3.25** (Firebase) y checklist Firebase.

---

## D1 — Supabase (camino recomendado)

### Pre-flight

1. Proyecto creado; `project-ref` en `STACK_DB.md`.
2. MCP Supabase autenticado **o** CLI con `SUPABASE_ACCESS_TOKEN` de la **org dueña**.
3. Local: `npx supabase start` → migraciones → seed → pruebas RLS.
4. Anon/publishable key en cliente; **nunca** `service_role` en app.

### Elegir canal (no improvisar)

| Necesitas… | Canal |
|---|---|
| Tablas, RLS, RPC, migraciones DDL | MCP `apply_migration` / `execute_sql` + archivos en `supabase/migrations/` |
| Deploy Edge Functions (código) | MCP `deploy_edge_function` o CLI |
| Secrets de Edge (`STRIPE_*`, etc.) | CLI `secrets set` con token de la org correcta (**MCP no setea secrets**) |
| Auth Dashboard (MFA, min password, rate limits, HIBP) | Management API `PATCH …/config/auth` |
| SQL de prueba para el alumno | Sentencia **completa** `UPDATE`/`SELECT` |

### Orden de trabajo

1. Migraciones + RLS local; pruebas positivas/negativas.
2. Seed reproducible.
3. Cliente tipado; listados grandes con **paginación** (PostgREST corta en **1000** filas).
4. Si offline-first: Drift/SQLite + outbox; UI lee local; `kickSync` await en línea; badge pendientes **solo offline**.
5. Perfiles: trigger que impida auto-cambiar `rol`/`activo`.
6. Edge + secrets solo en servidor; advisors de seguridad al cerrar.
7. Auto-update APK (si aplica): `app_config` + Storage bucket `apk` (no Remote Config). Ver ficha **2.6**.

### Anti-patrones Supabase

- Asumir que MCP hace Auth config o secrets.
- Token de otra org → 403.
- Pegar `sbp_…` / `sk_…` en el chat sin revocar después.
- `.select()` sin `.range()` en tablas grandes.
- Dejar “hazlo en el Dashboard” sin intentar Management API.

### Lecciones clave

Fichas **2.6**, **3.12–3.22**, **4.19–4.20** y checklist Supabase.

---

## D3 — SQL propio / D4 — API / D5 — Sin BD

Ver `CONECTAR_BD.md` y `STACK_DB.md`. No aplicar checklists Firebase/Supabase.

---

## Mensaje al elegir stack (asistente)

Cuando el alumno diga “usaremos Firebase” o “usaremos Supabase”:

1. Marcar D2 o D1 en `PROJECT_PROFILE.md`.
2. Abrir **esta guía** + `CONECTAR_BD.md`.
3. Ejecutar pre-flight de ese stack **antes** de features de datos.
4. Aplicar solo las lecciones etiquetadas `[Firebase]` o `[Supabase]` (+ `[General]` / `[Flutter]`).
