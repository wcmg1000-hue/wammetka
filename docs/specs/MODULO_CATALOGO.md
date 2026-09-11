# Módulo: Catálogo y comercios

## 1. Objetivo del módulo

Mostrar oferta real por municipio y permitir al comercio mantener SKUs (precio, stock, disponibilidad).

## 2. Usuarios autorizados

| Rol | Qué puede hacer en este módulo |
|-----|--------------------------------|
| cliente / anónimo | Ver comercios y productos de zona habilitada |
| comercio | CRUD lógico de sus productos; interruptor abierto |
| admin | Aprobar comercio (`estado_aprobacion`) |

## 3. Pantallas y rutas

| Pantalla | Ruta | Rol | Fuente UI |
|----------|------|-----|-----------|
| Inicio cliente | `/home` | cliente | MD |
| Catálogo comercio | `/comercio/:id` | cliente | MD |
| Catálogo propio | `/comercio/catalogo` | comercio | MD |

## 4. Flujo de navegación acordado

Inicio → tarjeta comercio → catálogo. Comercio cerrado: se puede **ver** el catálogo pero no agregar. Comercio: tab Catálogo → alta/editar. Sin permiso → 0 filas.

## 5. Inventario visual por pantalla (1:1 con el MD)

### Pantalla: Inicio cliente (fuente: MD)

Elementos: saludo, chip municipio, buscador, chips Abiertos/Todas, tarjetas con badge y domicilio, nav inferior, vacío.

Acciones: abrir comercio; cambiar municipio (solo habilitados).

### Pantalla: Catálogo del comercio (fuente: MD)

Elementos: encabezado, banner cerrado, lista SKU, stepper, barra Ver carrito.

Acciones: agregar si abierto y stock > 0; ver carrito.

### Pantalla: Catálogo propio (fuente: MD)

Elementos: lista, switch Disponible, formulario nombre/precio/stock.

Acciones: Nuevo, Guardar, Ocultar.

## 6. Datos de entrada y salida

| Dato | Tipo | Origen/Destino | Validación |
|------|------|----------------|------------|
| nombre producto | string | productos | ≥ 3 |
| precio_centavos | int | productos | > 0 |
| stock | int | productos | ≥ 0 |
| abierto | bool | comercios | owner only |

## 7. Tablas o colecciones

| Nombre | Campos clave | Relaciones |
|--------|--------------|------------|
| comercios | owner_id, municipio_id, abierto, horario | profiles, municipios |
| productos | comercio_id, precio_centavos, stock, disponible | comercios |

## 8. Reglas de negocio

1. Cliente solo lista `estado_aprobacion=activo` y municipio propio (o el seleccionado si admin lo permite).
2. Agregar al carrito exige `abierto` y `disponible` y `stock>0`.
3. Ocultar producto = `disponible=false`, no DELETE si hubo `pedido_items`.

## 9. Validaciones

Precio > 0; nombre ≥ 3; stock entero.

## 10. APIs necesarias

PostgREST `comercios`, `productos` con RLS. Listados con `.range()`.

## 11. Tareas en segundo plano

No aplica (listados síncronos con loading).

## 12. Casos límite

Vacío de zona; comercio cierra mientras estás en el catálogo (se valida otra vez al confirmar, AC-04).

## 13. Criterios de aceptación

- [ ] Cliente ve SKUs del seed
- [ ] Comercio no ve catálogo ajeno
- [ ] Cerrado → no agrega

## 14. Pruebas mínimas

- [ ] Validación precio/stock al guardar (apoya test núcleo 3 junto con pedido)

## 15. Seguridad y privacidad

| Dato/acción sensible | Amenaza | Control | Prueba/evidencia |
|---|---|---|---|
| Catálogo ajeno | copiar demanda | RLS comercio_id | test |

## 16. Observabilidad y operación

Listados paginados (máx. 50). Error de red → banner Reintentar.

## 17. Comandos de verificación

| Control | Comando | Resultado esperado |
|---|---|---|
| Analyze | `flutter analyze` | exit 0 |
| Smoke | APK: ver 3 SKUs seed | visible |
