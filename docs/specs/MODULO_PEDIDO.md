# Módulo: Pedido

## 1. Objetivo del módulo

Flujo crítico: el cliente confirma un pedido contraentrega de un solo comercio; el comercio lo ve y acepta o rechaza.

## 2. Usuarios autorizados

| Rol | Qué puede hacer en este módulo |
|-----|--------------------------------|
| cliente | Crear, listar y cancelar los suyos si `pendiente_comercio` |
| comercio | Ver/aceptar/rechazar los de su `comercio_id` |
| repartidor | Ver si `asignado` a él (P0 mínimo) |
| operacion / admin | Ver todos |

## 3. Pantallas y rutas

| Pantalla | Ruta | Rol | Fuente UI |
|----------|------|-----|-----------|
| Carrito | `/carrito` | cliente | MD |
| Confirmar pedido | `/checkout` | cliente | MD |
| Pedido creado | `/pedidos/:id/ok` | cliente | MD |
| Mis pedidos | `/pedidos` | cliente | MD |
| Detalle cliente | `/pedidos/:id` | cliente | MD |
| Bandeja comercio | `/comercio/pedidos` | comercio | MD |
| Detalle comercio | `/comercio/pedidos/:id` | comercio | MD |

## 4. Flujo de navegación acordado

Catálogo → carrito → checkout → pedido creado → mis pedidos. Comercio: tab Pedidos → detalle → Aceptar/Rechazar. Sin red en confirmar → Error de red (no éxito). Sesión expirada → login.

## 5. Inventario visual por pantalla (1:1 con el MD)

Cubrir todos los bloques `#### Pantalla:` de carrito, confirmar, pedido creado, mis pedidos, detalle cliente, shell comercio, detalle comercio y error de red en `PANTALLAS_PARA_STITCH.md`. Botones con el texto exacto del MD. Cero `onPressed` vacíos.

## 6. Datos de entrada y salida

| Dato | Tipo | Origen/Destino | Validación |
|------|------|----------------|------------|
| items[] | producto_id, cantidad | carrito → RPC | cantidad ≥ 1; un comercio |
| direccion_texto | string | pedidos | 10–180 chars |
| metodo_pago | enum | pedidos | `contraentrega` en P0 |
| total_centavos | int | servidor | recalculado; no confiar en el cliente |

## 7. Tablas o colecciones

| Nombre | Campos clave | Relaciones |
|--------|--------------|------------|
| pedidos | cliente_id, comercio_id, estado, totales | profiles, comercios |
| pedido_items | snapshot precio/nombre | pedidos, productos |
| pedido_eventos | de_estado, a_estado, actor_id | pedidos |

## 8. Reglas de negocio

Ver expediente §6 y challenge §6.1 (R1–R8). Totales **solo** en servidor (RPC `crear_pedido`). Comisión 12 % sobre subtotal productos. Domicilio = tarifa de zona. Tope 3 pedidos no terminales por cliente.

## 9. Validaciones

Dirección obligatoria; stock atómico; comercio abierto; municipio habilitado; no mezclar comercios.

## 10. APIs necesarias

- RPC `crear_pedido(items, direccion, zona_id)` security definer en schema privado, grant authenticated
- `pedidos` select/update según RLS
- Realtime opcional en bandeja comercio

## 11. Tareas en segundo plano

No bloquear UI al confirmar: overlay de carga; timeout 20 s → error de red.

## 12. Casos límite

AC-04…AC-09 (cerrado, cobertura, mix, stock, tope, cancelar). Dos clientes el último SKU.

## 13. Criterios de aceptación

- [x] AC-03 guarda total correcto
- [x] AC-04 a AC-10 (AC-09 RPC lista; smoke cancelar no corrido en +3)

## 14. Pruebas mínimas

- [x] Test núcleo 3: validación que guarda (AC-03)
- [x] Tests R1/R3/R7 (cerrado/stock/no-mezclar + política RLS)

## 15. Seguridad y privacidad

| Dato/acción sensible | Amenaza | Control | Prueba/evidencia |
|---|---|---|---|
| Pedido ajeno | fuga PII | RLS | AC-02 |
| Total manipulado | fraude | RPC recalcula | AC-03 |
| Pedidos masivos | abuso | tope 3 | AC-08 |

## 16. Observabilidad y operación

Cada cambio de estado → `pedido_eventos`. Cancelar revierte stock.

## 17. Comandos de verificación

| Control | Comando | Resultado esperado |
|---|---|---|
| Tests | `flutter test` | AC-03, AC-07, AC-02 |
| Smoke teléfono | confirmar seed | fila en Table Editor + bandeja |
