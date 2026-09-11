# Conectar la base de datos

Guía según el stack elegido. Tu profesor te ayuda la **primera vez** con login y `.env`.

El asistente completa la ruta D1–D4 antes de usar datos reales. Primero trabaja localmente; staging y producción son pasos separados.

**Al elegir D1 o D2:** abrir también [`CAMINO_POR_STACK.md`](CAMINO_POR_STACK.md) (camino recomendado Supabase vs Firebase) y aplicar solo las lecciones de ese stack.

---

## Antes de empezar

1. Copia `.env.example` → `.env` y rellena solo la sección de tu stack
2. Nunca pegues contraseñas en el chat; solo en `.env`
3. Usa modo **Agent** para que el asistente ejecute comandos CLI/MCP
4. Completa `docs/PROJECT_PROFILE.md` y no configures BD si elegiste D5
5. Usa datos sintéticos; nunca copies producción al entorno local sin anonimizar

## Orden obligatorio

1. Local/emulador o sandbox.
2. Migraciones desde cero y seed reproducible.
3. Lint y pruebas positivas/negativas de autorización.
4. Desarrollo/staging separado.
5. Producción solo con aprobación, backup/restauración y rollback.

---

## Firebase

### Requisitos
- Node.js y Firebase CLI: `npm install -g firebase-tools`
- Java y Firebase Emulator Suite para desarrollo/pruebas locales

### Desarrollo local primero

```bash
firebase init emulators
firebase emulators:start
```

Conectar la app a Auth/Firestore/Realtime/Storage/Functions emulados según aplique. Automatizar pruebas de Security Rules con accesos permitidos y denegados antes de desplegar.

### Login (método por defecto SIEMPRE)

```bash
firebase login          # abre el navegador: eliges tu cuenta Google y contraseña
# si ya había sesión y falla:
firebase login --reauth
```

Este es el método por defecto: el navegador se abre automáticamente, eliges tu cuenta y entras. Es el más rápido y sin errores. **No** se usan archivos de credenciales salvo que lo pidas.

`firebase login --reauth` **no funciona** en el shell no interactivo del agente: hazlo en una **terminal externa** (PowerShell/CMD propia). Si `login:list` parece OK pero `projects:list` falla con *credentials no longer valid*, reautentica ahí.

### Pre-flight Firebase (obligatorio, ~2 min) — “hay proyecto” ≠ “hay Firestore”

Antes de FlutterFire, seed o APK con nube, verificar en este orden. Saltar esto suele costar 15–20 min de improvisación + un segundo APK.

| # | Comprobación | Comando / acción | OK si… |
|---|---|---|---|
| 1 | CLI autenticado | `firebase projects:list` | lista proyectos sin error de credenciales |
| 2 | Proyecto activo | `firebase use <project-id>` | `(current)` correcto |
| 3 | Apps registradas | `firebase apps:list` | existe app Android y/o Web según plataforma |
| 4 | Firestore API + DB | consola o `firebase firestore:databases:list` | existe `(default)` en la región acordada |
| 5 | Rules | `firebase deploy --only firestore:rules` (cuando existan) | deploy OK |

Si el Project ID existe pero falla 3 o 4: habilitar API, crear la base, registrar apps — **no** asumir que “ya tengo la base” significa usable.

Si el requisito de entrega es “los datos están en la nube”:

- Preferir **Firestore-first** (o escritura cloud obligatoria).
- **Prohibido** `catch` vacío / silenciar fallos de sync.
- Smoke: una escritura desde el dispositivo visible en la consola Firebase antes de cerrar.

No uses `firebase open` genérico (puede abrir Realtime Database u otro producto). Usa comandos/consola del servicio concreto.

### Proyecto nuevo → base de datos nueva (automático)

Si dices que es un **proyecto nuevo**, el asistente crea también proyecto y base nuevos:

```bash
firebase projects:create mi-app-id-unico
firebase firestore:databases:create "(default)" --location=us-central1
firebase use mi-app-id-unico
firebase init      # Firestore, Authentication, Hosting si aplica
```

Si el CLI no puede crear el proyecto (permisos/facturación), el asistente te guía para crearlo en la [consola de Firebase](https://console.firebase.google.com) y luego continúa con `firebase use`.

### Conectar TODOS los servicios que use el proyecto

El asistente conecta cada servicio Firebase según lo que la app necesite (no solo la base):

| Necesita… | Servicio Firebase |
|-----------|-------------------|
| Login y roles | Authentication |
| Base de datos documentos | Cloud Firestore |
| Datos en tiempo real | Realtime Database |
| Fotos y archivos | Cloud Storage |
| Web / panel admin | Hosting |
| Notificaciones push | Cloud Messaging (FCM) |
| Lógica en servidor | Cloud Functions |
| Reporte de errores | Crashlytics |
| Config remota / versión de la app | Remote Config |

Todos los servicios necesarios quedan conectados y con sus reglas desplegadas.

### Qué hace el asistente
- Ejecuta `firebase init` con todos los módulos requeridos
- Crea/actualiza reglas de Firestore, Realtime y Storage según se usen
- Despliega reglas: `firebase deploy --only firestore:rules,firestore:indexes,storage`
- Documenta en `docs/database/STACK_DB.md` los servicios conectados

### Mensaje para el chat

```
Stack: Firebase. Inicia sesión con firebase login (navegador) si hace falta.
Como es proyecto nuevo, crea también proyecto y base Firestore nuevos.
Conecta TODOS los servicios que la app necesite (Auth, Firestore, Storage,
Realtime, Hosting, FCM, Functions, Remote Config según el proyecto),
crea colecciones y reglas según docs/specs/, despliega todo y actualiza STACK_DB.md.
```

---

## Supabase (CLI + MCP — recomendado)

### Requisitos
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- MCP supabase en `.cursor/mcp.json` (ver `mcp.json.example`)

### Pasos CLI

```bash
npx supabase init
npx supabase start
npx supabase migration new inicial
# El asistente escribe el SQL en supabase/migrations/
npx supabase db reset
npx supabase db lint
npx supabase test db
```

Solo después de pasar local: `supabase login`, `supabase link --project-ref ...` y `supabase db push` hacia staging. Producción se despliega en la Fase 6.

### Pasos MCP (en Cursor)
1. Copia `mcp.json.example` → `.cursor/mcp.json` (solo Supabase; no Stitch)
2. Settings → MCP → autentica **supabase** (OAuth en el navegador)
3. El asistente puede usar `execute_sql`, `get_advisors`, etc.

### Qué hace el asistente
- Crea tablas según `docs/specs/`
- Activa **RLS** y políticas por rol
- Genera migraciones versionadas
- Revisa seguridad con advisors

### Mensaje para el chat

```
Stack: Supabase. Conecta con CLI (supabase link) y/o MCP.
Crea tablas, RLS e índices según docs/specs/, aplica migraciones
y actualiza docs/database/STACK_DB.md. No expongas service_role en el cliente.
```

---

## MySQL

### Requisitos
- MySQL instalado o hosting con acceso remoto
- Cadena de conexión (la da tu profesor o el panel del hosting)

### Pasos

1. En `.env`:
   ```env
   DATABASE_URL=mysql://usuario:contraseña@host:3306/nombre_bd
   ```
2. Con **Prisma** (si el asistente lo elige):
   ```bash
   npx prisma init
   npx prisma migrate dev --name inicial
   ```
3. Con **Drizzle**:
   ```bash
   npx drizzle-kit push
   ```
4. Sin ORM — SQL directo:
   ```bash
   mysql -h HOST -u USER -p NOMBRE_BD < database/migrations/001_inicial.sql
   ```

### Qué hace el asistente
- Escribe migraciones en `database/migrations/`
- Ejecuta migrate/push o script mysql
- Documenta tablas en `STACK_DB.md`

### Mensaje para el chat

```
Stack: MySQL. DATABASE_URL está en .env.
Crea y aplica migraciones según docs/specs/ en database/migrations/
y actualiza STACK_DB.md.
```

---

## Verificar que funcionó

- [ ] `docs/database/STACK_DB.md` actualizado
- [ ] Tablas/colecciones creadas
- [ ] RLS o Security Rules activas (Supabase/Firebase)
- [ ] `docs/CHECKLIST.md` Fase 2D marcada

---

## Problemas frecuentes

| Problema | Qué hacer |
|----------|-----------|
| Error de login CLI | Repite `firebase login` o `supabase login` |
| MCP supabase no aparece | Revisa `.cursor/mcp.json` y reinicia Cursor |
| MySQL connection refused | Revisa host, puerto y firewall en `.env` |
| RLS bloquea todo | Pide al asistente revisar políticas por rol |

