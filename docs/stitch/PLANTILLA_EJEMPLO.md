# Plantilla de referencia — Formato visual para Stitch

El asistente debe seguir **este formato exacto** al generar `PANTALLAS_PARA_STITCH.md`. Estos ejemplos son la referencia de estructura, tono y nivel de detalle.

---

## Ejemplo 1 — CotizaPro

#### Contexto Global de la Interfaz
* **Plataforma destino:** Aplicación Móvil y Web App.
* **Idioma principal:** Español.
* **Nombre del Proyecto:** CotizaPro.

#### Pantalla: Splash Screen (Carga Inicial)
* **Objetivo/Funcionalidad:** Pantalla de bienvenida al abrir la app para establecer la marca y el idioma.
* **Elementos de interfaz:**
* Logotipo principal de "CotizaPro".
* Texto descriptivo: "Proformas profesionales en segundos".
* Animación o barra de carga (Loading spinner).
* **Botones/Acciones principales:**
* Redirección automática al Login o Menú Principal.

#### Pantalla: Menú de Navegación Principal
* **Objetivo/Funcionalidad:** Mostrar al usuario todas las áreas del sistema para que pueda navegar fluidamente entre los módulos.
* **Elementos de interfaz:**
* Logotipo superior de CotizaPro.
* Acordeón desplegable para "Cotizaciones" (Nueva Cotización, Historial de Enviadas).
* Acordeón desplegable para "Catálogo" (Productos, Servicios, Impuestos).
* Acordeón desplegable para "Directorio" (Cartera de Clientes).
* Acordeón desplegable para "Configuración" (Perfil de Empresa, Estilos y Colores).
* **Botones/Acciones principales:**
* Expandir/Contraer menú lateral
* Cerrar Sesión

#### Pantalla: Creador de Cotizaciones (Nueva Proforma)
* **Objetivo/Funcionalidad:** Es el motor de la app. Permite armar la cotización seleccionando a quién va dirigida, agregando los items y calculando totales automáticamente.
* **Elementos de interfaz:**
* Buscador autocompletable para "Seleccionar Cliente" (o botón para añadir uno rápido).
* Barra de búsqueda rápida para agregar productos/servicios al listado.
* Tabla de items dinámicos (columnas de Descripción, Cantidad, Precio Unitario, Impuesto, y Subtotal).
* Tarjeta de resumen financiero (Subtotal, Total Impuestos, Total Final a Pagar).
* **Botones/Acciones principales:**
* + Agregar Item Manualmente
* Ir a Vista Previa (Siguiente)
* Guardar Borrador
* Cancelar

#### Pantalla: Vista Previa, Estilos y Envío
* **Objetivo/Funcionalidad:** Permite al usuario visualizar exactamente cómo quedará el documento, personalizar su diseño y enviarlo al cliente.
* **Elementos de interfaz:**
* Visor de PDF en tiempo real (Mockup del documento final).
* Carrusel inferior o panel lateral de "Plantillas/Estilos" (Ej: Minimalista, Corporativo, Moderno).
* Paleta de selección rápida para "Colores del Negocio" (Color primario y secundario).
* **Botones/Acciones principales:**
* Generar / Descargar PDF
* Enviar por WhatsApp
* Compartir Enlace
* Volver a Editar

#### Pantalla: Gestión de Productos e Impuestos
* **Objetivo/Funcionalidad:** Permite administrar el catálogo de lo que se vende, configurando sus costos y la carga impositiva correspondiente.
* **Elementos de interfaz:**
* Formulario de creación (Nombre, Descripción corta, SKU/Código).
* Campo de Precio Base (antes de impuestos).
* Checkboxes o selectores múltiples para "Impuestos Aplicables" (Ej: IVA 12%, IVA 15%, Exento).
* Lista/Tabla inferior con el catálogo completo guardado.
* **Botones/Acciones principales:**
* + Nuevo Producto
* Guardar Configuración
* Editar Producto
* Eliminar / Ocultar

#### Pantalla: Configuración del Negocio (Mi Empresa)
* **Objetivo/Funcionalidad:** Recopilar los datos legales y de contacto del usuario para que se impriman automáticamente en el encabezado o pie de todas las cotizaciones.
* **Elementos de interfaz:**
* Zona de carga (Drag & Drop) para el "Logotipo de la Empresa".
* Campos de texto obligatorios (Nombre Legal/Comercial, Identidad Fiscal/RUT/RUC, Dirección, Teléfono, Correo).
* Área de texto amplio para "Términos y Condiciones por defecto" o "Notas bancarias".
* **Botones/Acciones principales:**
* Subir Logotipo
* Guardar Cambios
* Restaurar Valores por Defecto

---

## Ejemplo 2 — TiendaPOS

#### Contexto Global de la Interfaz
* **Plataforma destino:** Aplicación Móvil (Mobile App).
* **Idioma principal:** Español.
* **Nombre del Proyecto:** TiendaPOS.

#### Pantalla: Splash Screen (Carga Inicial)
* **Objetivo/Funcionalidad:** Pantalla de bienvenida al abrir la app móvil para establecer la marca y el idioma.
* **Elementos de interfaz:**
* Logotipo principal de "TiendaPOS".
* Texto descriptivo en español: "Tu Punto de Venta Inteligente".
* Animación o barra de carga (Loading spinner).
* **Botones/Acciones principales:**
* Redirección automática al Menú Principal.

#### Pantalla: Menú Lateral de Navegación Principal
* **Objetivo/Funcionalidad:** Mostrar al usuario todas las áreas del sistema para que pueda navegar fluidamente entre los módulos.
* **Elementos de interfaz:**
* Logotipo superior de TiendaPOS.
* Acordeón desplegable para "Punto de Venta" (Terminal, Historial).
* Acordeón desplegable para "Inventario" (Catálogo, Alertas, Ingresos).
* Acordeón desplegable para "Clientes" (Directorio, Cuentas por cobrar).
* Acordeón desplegable para "Finanzas" (Arqueo, Ingresos/Retiros).
* **Botones/Acciones principales:**
* Expandir/Contraer menú lateral
* Cerrar Sesión

#### Pantalla: Terminal de Punto de Venta (Caja)
* **Objetivo/Funcionalidad:** Permite al cajero escanear, buscar y registrar los productos rápidamente para cobrarle al cliente sin demoras.
* **Elementos de interfaz:**
* Barra superior de búsqueda rápida y escáner de código de barras.
* Cuadrícula de botones grandes con "Productos Frecuentes" o "Categorías".
* Lista de compras en el lado derecho (carrito) mostrando subtotal, impuestos y Total a pagar.
* Teclado numérico en pantalla para ingreso rápido de cantidades.
* **Botones/Acciones principales:**
* Cobrar (Efectivo / Tarjeta)
* Vender a Crédito (Fiar)
* Eliminar Producto
* Cancelar Venta / Limpiar Caja

#### Pantalla: Gestión de Créditos (Fiados)
* **Objetivo/Funcionalidad:** Permite llevar un control estricto del dinero que deben los clientes, reemplazando el cuaderno de deudas.
* **Elementos de interfaz:**
* Tarjeta de resumen global con el saldo total por cobrar.
* Lista de clientes con deuda, ordenada por monto o fecha de atraso.
* Historial detallado por cliente de los productos retirados a crédito y fechas.
* **Botones/Acciones principales:**
* + Nuevo Cliente a Crédito
* Registrar Abono / Pago Total
* Enviar Recordatorio (WhatsApp/SMS)
* Imprimir Estado de Cuenta

#### Pantalla: Cierre de Caja (Arqueo Diario)
* **Objetivo/Funcionalidad:** Ayuda al encargado a cuadrar el dinero en efectivo al final del turno, detectando faltantes o sobrantes.
* **Elementos de interfaz:**
* Resumen de movimientos (Efectivo Inicial, Ventas, Tarjeta, Retiros).
* Calculadora de denominaciones (formulario para contar monedas y billetes).
* Indicador de descuadre (Diferencia de caja).
* **Botones/Acciones principales:**
* Registrar Retiro de Efectivo
* Calcular Total
* Cerrar Turno / Caja
* Imprimir Ticket de Cierre

#### Pantalla: Control de Inventario y Alertas
* **Objetivo/Funcionalidad:** Administra los productos de la tienda y avisa automáticamente cuáles están por agotarse.
* **Elementos de interfaz:**
* Filtros rápidos: Todos, Stock Bajo, Agotados.
* Tabla de productos con foto, nombre, código, precio costo/venta y cantidad.
* Indicadores visuales de colores para el nivel de stock (Verde, Amarillo, Rojo).
* **Botones/Acciones principales:**
* + Nuevo Producto
* Ajuste de Inventario Rápido (+ / -)
* Imprimir Lista de Faltantes
* Escanear para Editar

---

## Checklist de calidad para el asistente

Antes de dar por listo `PANTALLAS_PARA_STITCH.md`, verificar:

- [ ] Contexto global al inicio
- [ ] Todas las pantallas del alcance incluidas
- [ ] Menú de navegación si la app lo requiere
- [ ] Login/Splash si están en alcance
- [ ] Cada pantalla tiene objetivo, elementos y botones
- [ ] Formato idéntico a estos ejemplos
- [ ] Solo Markdown, sin HTML ni JSON
- [ ] Alineado con mapa de navegación y specs
