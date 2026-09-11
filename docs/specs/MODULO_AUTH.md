# Módulo: Auth

## 1. Objetivo del módulo

Identificar al usuario, cargar su rol desde `profiles` y mostrar la cáscara (shell) correcta. Sin sesión no hay pedido.

## 2. Usuarios autorizados

| Rol | Qué puede hacer en este módulo |
|-----|--------------------------------|
| Anónimo | Login; registro solo como `cliente` |
| cliente, comercio, repartidor, operacion, finanzas, admin | Entrar, ver su perfil, cerrar sesión |
| admin | Alta de comercios/repartidores (P0: seed; UI de alta en P1) |

## 3. Pantallas y rutas

| Pantalla | Ruta | Rol | Fuente UI |
|----------|------|-----|-----------|
| Splash | `/` | todos | `docs/stitch/PANTALLAS_PARA_STITCH.md` |
| Login | `/login` | anónimo | MD |
| Registro cliente | `/register` | anónimo | MD |
| Cuenta | `/cuenta` | autenticado | MD |

## 4. Flujo de navegación acordado

Splash → sesión válida → shell del rol; si no → Login. Login OK → shell. Registro → Login o shell cliente. 401/sesión expirada → Login con mensaje. Rol desconocido o `activo=false` → pantalla de error “Cuenta no habilitada” + cerrar sesión.

## 5. Inventario visual por pantalla (1:1 con el MD)

### Pantalla: Login  (fuente: MD)

Elementos:
- [ ] Logotipo pequeño
- [ ] Título "Entrar a Wammetka"
- [ ] Campo Correo electrónico
- [ ] Campo Contraseña (mostrar/ocultar)
- [ ] Texto de error en rojo
- [ ] Enlace "Crear cuenta de cliente"
- [ ] Texto comercio/repartidor

Acciones:
- [ ] Entrar → shell del rol
- [ ] Crear cuenta de cliente → `/register`
- [ ] Reintentar si error de red

### Pantalla: Registro de cliente  (fuente: MD)

Elementos:
- [ ] Campos Nombre, Teléfono, Correo, Contraseña, Confirmar
- [ ] Selector Municipio
- [ ] Checkbox aviso de datos

Acciones:
- [ ] Crear cuenta
- [ ] Volver a Entrar

## 6. Datos de entrada y salida

| Dato | Tipo | Origen/Destino | Validación |
|------|------|----------------|------------|
| email | string | Auth | formato email |
| password | string | Auth | mín. 8 |
| nombre | string | profiles | 2–80 |
| telefono | string | profiles | 7–15 dígitos |
| municipio_id | uuid | profiles | debe existir y habilitado |
| rol | enum | profiles | solo `cliente` en self-register |

## 7. Tablas o colecciones

| Nombre | Campos clave | Relaciones |
|--------|--------------|------------|
| `profiles` | id, rol, nombre, telefono, municipio_id, activo | auth.users |

## 8. Reglas de negocio

1. El registro público solo crea `rol=cliente`.
2. Comercio/repartidor/admin salen de seed o de un admin.
3. Trigger: el usuario no puede UPDATE su `rol` ni `activo`.
4. Login fallido no revela si el email existe (“Correo o contraseña incorrectos”).

## 9. Validaciones

- Campos requeridos en registro.
- Municipio habilitado.
- Checkbox de datos obligatorio.

## 10. APIs necesarias

- `auth.signInWithPassword` / `signUp` / `signOut`
- `from('profiles').select()` del uid

## 11. Tareas en segundo plano

- Restaurar sesión en splash (no bloquear UI más de 3 s; timeout → login)

## 12. Casos límite

- Sin red; clave mala; cuenta inactiva; perfil huérfano (auth sin profile) → crear profile cliente o error admin.

## 13. Criterios de aceptación

- [ ] AC-01 login seed cliente
- [ ] AC-02 cliente no lee pedidos ajenos (permiso)

## 14. Pruebas mínimas

- [ ] Auth OK / auth fallido (test núcleo 1)
- [ ] Rol que no puede (test núcleo 2)

## 15. Seguridad y privacidad

| Dato/acción sensible | Amenaza | Control | Prueba/evidencia |
|---|---|---|---|
| Contraseña | fuerza bruta | rate limit Auth + mensaje genérico | test fallido |
| Rol | auto-admin | trigger + RLS | test no-puede |

- Autorización del lado servidor/BD: RLS + trigger rol
- Datos personales y retención: nombre/teléfono mientras la cuenta exista
- Rate limit/antiabuso: Auth de Supabase
- Logs y auditoría: sin contraseñas

## 16. Observabilidad y operación

- Métricas/logs/crashes: fallos de login agregados, no el email en claro en crashlytics P1
- Degradado: timeout splash → login
- Rollback: desactivar usuario `activo=false`

## 17. Comandos de verificación

| Control | Comando | Resultado esperado |
|---|---|---|
| Analyze | `flutter analyze` | exit 0 |
| Tests | `flutter test` | AC-01 AC-02 |
