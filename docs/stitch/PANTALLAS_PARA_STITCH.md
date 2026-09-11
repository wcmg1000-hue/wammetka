# Pantallas para Stitch

Texto pegable en Stitch. Fuente de verdad UI de Wammetka (V1 MD-first). Implementar desde este archivo. Sin MCP ni ID de Stitch.

#### Contexto Global de la Interfaz
* **Plataforma destino:** Aplicación Móvil Android y Web App (mismo diseño; móvil primero).
* **Idioma principal:** Español (Colombia).
* **Nombre del Proyecto:** Wammetka.
* **Tono visual:** Cercanía territorial, confianza y utilidad. Superficies claras, poco ruido, precios y estados siempre visibles.
* **Color primario:** #0F6B5C (verde profundo).
* **Color de acento:** #E87B3A (naranja cálido, acciones principales).
* **Fondo:** #F7F4EF (arena clara).
* **Superficie:** #FFFFFF.
* **Texto:** #1A1F1C.
* **Error:** #B42318.
* **Éxito:** #1F7A4D.
* **Tipografía:** Plus Jakarta Sans o equivalente geométrica sans-serif; títulos semibold, cuerpo regular.
* **Radios:** 16 px en tarjetas, 24 px en botones píldora.
* **Espaciado base:** 8 px.
* **Iconografía:** Material Symbols Outlined.
* **Estados obligatorios en pantallas de lista:** carga (skeleton), vacío, error con reintentar, sin permiso.

#### Pantalla: Splash (Carga inicial)
* **Objetivo/Funcionalidad:** Mostrar marca mientras se restaura sesión y se consulta si hay actualización del paquete de Android (Android Package, APK).
* **Elementos de interfaz:**
* Logotipo wordmark "Wammetka" centrado sobre fondo arena.
* Frase: "Compra local, llega de verdad".
* Indicador de carga circular color primario.
* Versión pequeña al pie (ej. "v0.1.0").
* **Botones/Acciones principales:**
* Redirección automática a Login o al inicio del rol.

#### Pantalla: Login
* **Objetivo/Funcionalidad:** Entrar con correo y contraseña. El rol sale del perfil en nube, no de un selector en esta pantalla.
* **Elementos de interfaz:**
* Logotipo pequeño arriba.
* Título: "Entrar a Wammetka".
* Campo Correo electrónico.
* Campo Contraseña (mostrar/ocultar).
* Texto de error en rojo bajo el formulario (credenciales, red).
* Enlace "Crear cuenta de cliente".
* Texto discreto: "¿Eres comercio o repartidor? Te activa un administrador".
* **Botones/Acciones principales:**
* Entrar (acento, ancho completo)
* Crear cuenta de cliente
* Reintentar si hay error de red

#### Pantalla: Registro de cliente
* **Objetivo/Funcionalidad:** Alta de cliente en municipio piloto.
* **Elementos de interfaz:**
* Título: "Crear cuenta".
* Campos: Nombre, Teléfono, Correo, Contraseña, Confirmar contraseña.
* Selector Municipio (lista de los seis piloto; Fonseca preseleccionado en seed).
* Checkbox: "Acepto el aviso de tratamiento de datos".
* Errores de validación por campo.
* **Botones/Acciones principales:**
* Crear cuenta
* Volver a Entrar

#### Pantalla: Inicio cliente (Descubrir)
* **Objetivo/Funcionalidad:** Ver comercios abiertos del municipio del cliente.
* **Elementos de interfaz:**
* Barra superior: saludo "Hola, {nombre}" y chip de municipio.
* Buscador: "Buscar tienda o producto".
* Filtros chip: Abiertos ahora, Todas.
* Lista de tarjetas de comercio: foto/placeholder, nombre, categoría corta, estado Abierto/Cerrado (badge), tiempo estimado "30–50 min", tarifa de domicilio en COP.
* Franja de acento 8 px a la izquierda de cada tarjeta (primario si abierto, gris si cerrado) — borde de tarjeta uniforme.
* Estado vacío: "Aún no hay comercios en tu zona".
* Navegación inferior: Inicio, Carrito, Pedidos, Cuenta.
* **Botones/Acciones principales:**
* Tocar tarjeta → Catálogo del comercio
* Cambiar municipio (hoja inferior; solo municipios habilitados)

#### Pantalla: Catálogo del comercio
* **Objetivo/Funcionalidad:** Ver SKUs disponibles y agregarlos al carrito de un solo comercio.
* **Elementos de interfaz:**
* Encabezado con nombre del comercio, horario, badge Abierto/Cerrado.
* Banner si está cerrado: "Este comercio no recibe pedidos ahora".
* Lista de productos: nombre, precio COP, stock bajo ("Últimas {n} und.") si stock ≤ 3, stepper cantidad.
* Botón circular + por producto (deshabilitado si cerrado o stock 0).
* Barra inferior persistente: "Ver carrito · {n} productos · {total} COP" (oculta si carrito vacío).
* **Botones/Acciones principales:**
* Agregar / sumar / restar
* Ver carrito
* Atrás

#### Pantalla: Carrito
* **Objetivo/Funcionalidad:** Revisar ítems, cantidades y el total antes de pagar. Un solo comercio.
* **Elementos de interfaz:**
* Título: "Tu pedido · {nombre comercio}".
* Líneas: nombre, precio unitario, stepper, subtotal.
* Resumen: Subtotal productos, Domicilio, Total a pagar (contraentrega).
* Nota: "Pagas en efectivo al recibir. No incluye propina en esta versión."
* Estado vacío: "Tu carrito está vacío" + botón Ir a inicio.
* Diálogo si se intenta mezclar comercios: "Tu carrito tiene productos de {A}. ¿Vaciar y agregar de {B}?"
* **Botones/Acciones principales:**
* Continuar a confirmar
* Vaciar carrito
* En diálogo: Vaciar y continuar / Cancelar

#### Pantalla: Confirmar pedido
* **Objetivo/Funcionalidad:** Capturar dirección de entrega y crear el pedido en la nube.
* **Elementos de interfaz:**
* Bloque Dirección (texto obligatorio, 10–180 caracteres) y referencias (opcional).
* Método de pago fijo: "Contraentrega" (no editable en P0).
* Desglose idéntico al carrito (productos + domicilio = total).
* Texto legal corto: "Al confirmar, el comercio debe aceptar tu pedido."
* Error a pantalla completa o banner: cobertura, comercio cerrado, stock, tope de 3 pedidos pendientes, sin red.
* **Botones/Acciones principales:**
* Confirmar pedido (acento)
* Volver al carrito

#### Pantalla: Pedido creado
* **Objetivo/Funcionalidad:** Confirmar que el pedido quedó guardado y mostrar el estado.
* **Elementos de interfaz:**
* Ícono de éxito.
* Título: "Pedido enviado al comercio".
* Número corto de pedido (8 caracteres).
* Estado actual: "Esperando al comercio".
* Temporizador informativo: "Suelen responder en 10 minutos".
* Total y método Contraentrega.
* **Botones/Acciones principales:**
* Ver mis pedidos
* Ir a inicio

#### Pantalla: Mis pedidos (cliente)
* **Objetivo/Funcionalidad:** Listar pedidos propios con estado consistente en todos los canales.
* **Elementos de interfaz:**
* Pestañas: Activos / Anteriores.
* Tarjeta: comercio, total, estado en lenguaje humano (Esperando al comercio, Aceptado, En preparación, En camino, Entregado, Cancelado).
* Vacío: "Todavía no has pedido".
* **Botones/Acciones principales:**
* Abrir detalle
* Repetir pedido (P1: ocultar si no está listo; en P0 no mostrar el botón)

#### Pantalla: Detalle de pedido (cliente)
* **Objetivo/Funcionalidad:** Ver ítems, total y cancelar si aún espera al comercio.
* **Elementos de interfaz:**
* Línea de tiempo simple (puntos): Enviado → Aceptado → Preparado → En camino → Entregado.
* Lista de ítems snapshot.
* Dirección.
* Banner de error de red si falla la carga.
* **Botones/Acciones principales:**
* Cancelar pedido (solo estado Esperando al comercio; pide confirmación)
* Llamar al comercio (teléfono, P0)

#### Pantalla: Cuenta (cliente)
* **Objetivo/Funcionalidad:** Ver perfil y salir.
* **Elementos de interfaz:**
* Nombre, correo, municipio.
* Versión de la app.
* **Botones/Acciones principales:**
* Cerrar sesión (confirmación)
* (Sin placeholders de "próximamente")

#### Pantalla: Shell comercio — Pedidos
* **Objetivo/Funcionalidad:** Bandeja de pedidos del comercio dueño.
* **Elementos de interfaz:**
* Tabs: Nuevos / En curso / Cerrados.
* Tarjeta: hora, cliente (nombre), total, ítems resumidos ("3 productos").
* Badge "Nuevo" con acento.
* Navegación inferior comercio: Pedidos, Catálogo, Cuenta.
* Vacío Nuevos: "No hay pedidos nuevos".
* **Botones/Acciones principales:**
* Abrir detalle para aceptar o rechazar
* Interruptor "Comercio abierto" en app bar (cambia `abierto`)

#### Pantalla: Detalle pedido comercio
* **Objetivo/Funcionalidad:** Aceptar o rechazar con causal.
* **Elementos de interfaz:**
* Ítems con cantidades.
* Dirección de entrega (texto).
* Teléfono cliente.
* Total (el comercio ve subtotal productos; no ve la comisión como línea al cliente).
* Selector de causal si rechaza: Sin stock, Fuera de horario, Otro.
* **Botones/Acciones principales:**
* Aceptar pedido (primario)
* Rechazar (texto, abre causal)
* Marcar preparado (si ya aceptado)

#### Pantalla: Catálogo propio (comercio)
* **Objetivo/Funcionalidad:** Alta y edición de SKUs reales.
* **Elementos de interfaz:**
* Lista de productos con switch Disponible y stock.
* Formulario (hoja o pantalla): Nombre, Precio COP, Stock, SKU opcional.
* Validación: nombre ≥ 3, precio > 0, stock ≥ 0.
* **Botones/Acciones principales:**
* Nuevo producto
* Guardar
* Ocultar producto (disponible = false; no borrar si tuvo ventas)

#### Pantalla: Shell repartidor — Servicios
* **Objetivo/Funcionalidad:** Ver servicios de su zona cuando un pedido está aceptado/preparado.
* **Elementos de interfaz:**
* Lista: comercio origen, zona destino, pago estimado del servicio, distancia textual ("misma zona").
* Estado vacío: "No hay servicios disponibles".
* Nav: Servicios, En curso, Cuenta.
* **Botones/Acciones principales:**
* Ver detalle / Aceptar servicio (P0: si no hay oferta, la lista vacía es válida; no botón muerto)

#### Pantalla: Shell administración — Pedidos
* **Objetivo/Funcionalidad:** Operación ve todos los pedidos del piloto (soporte).
* **Elementos de interfaz:**
* Filtro por estado y municipio.
* Tabla/lista: id corto, comercio, estado, total.
* **Botones/Acciones principales:**
* Abrir detalle (solo lectura en P0)
* Cerrar sesión

#### Pantalla: Error de red
* **Objetivo/Funcionalidad:** No fingir éxito cuando no hay conexión.
* **Elementos de interfaz:**
* Ilustración simple / ícono nube tachada.
* Título: "Sin conexión".
* Texto: "Revisa tus datos e inténtalo de nuevo. Tu pedido no se envió."
* **Botones/Acciones principales:**
* Reintentar
* Volver
