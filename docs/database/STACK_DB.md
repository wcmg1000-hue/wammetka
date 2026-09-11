# Stack de base de datos del proyecto

## Estado

Proyecto cloud **wammetka** creado 2026-09-11 (T03). Distincto de cualquier otro aplicativo de la org.

## Stack elegido

| Campo | Valor |
|-------|--------|
| **Base de datos** | Supabase (Postgres 17) |
| **ORM o herramienta** | `supabase_flutter` + SQL migraciones; sin Prisma |
| **Auth** | Supabase Auth (email/contraseña) |
| **Entorno** | cloud staging (local Docker no disponible en esta máquina) |

## Conexión

| Campo | Valor |
|-------|--------|
| **CLI usado** | `supabase` 2.117.0 |
| **MCP activo** | supabase: sí |
| **Proyecto / host** | `wwhyypadkjjbgkmlbpss` · `https://wwhyypadkjjbgkmlbpss.supabase.co` · región `sa-east-1` |
| **Migraciones en** | `supabase/migrations/` |
| **Fecha de conexión** | 2026-09-11 |

## Entornos separados

| Entorno | Proyecto/host | Datos | Credenciales | Estado |
|---|---|---|---|---|
| Local/emulador | localhost | sintéticos | locales | N/A — Docker no instalado |
| Desarrollo/staging | wwhyypadkjjbgkmlbpss | sintéticos | `.env` | schema + seed aplicados |
| Producción | distinto project-ref | reales | secret store | N/A hasta piloto |

## Reproducibilidad

- **Comando de inicio local:** `npx supabase start` (requiere Docker)
- **Comando reset + migraciones + seed:** `npx supabase db reset`
- **Comando lint:** advisors MCP `get_advisors` (security)
- **Comando pruebas RLS/rules:** `has_function_privilege` + políticas; pruebas JWT en T05
- **Backup y restauración:** Dashboard Supabase
- **Rollback de migraciones:** no editar migraciones aplicadas; nueva migración down

## Seguridad aplicada

- [x] RLS desplegada en tablas public del P0
- [x] `anon` no ejecuta `crear_pedido` ni `handle_new_user`
- [x] `authenticated` sí ejecuta `crear_pedido` (la función exige rol cliente)
- [ ] App Check/antiabuso evaluado cuando aplica
- [x] Índices en queries frecuentes
- [x] Secretos solo en `.env`

## Tablas / colecciones principales

| Nombre | Descripción |
|--------|-------------|
| `profiles` | Rol, municipio, `id` = `auth.uid()` |
| `municipios` | Seis municipios piloto |
| `zonas` | Tarifa domicilio Fonseca Centro $5.000 |
| `comercios` | Tienda Piloto Fonseca |
| `productos` | 3 SKUs seed |
| `pedidos` / `pedido_items` / `pedido_eventos` | Flujo crítico |
| `app_config` | Auto-update APK |

## Seed (staging)

Correos: `admin@wammetka.test`, `comercio@wammetka.test`, `cliente@wammetka.test`, `reparto@wammetka.test`.  
Contraseña: `SEED_PASSWORD` en `.env` local (no en git).

## Notas

No reutilizar `mqdxtjrivelsplzpsrsi`. Rol nunca en `user_metadata`.
