class PedidoItem {
  const PedidoItem({
    required this.nombre,
    required this.precioCentavos,
    required this.cantidad,
    required this.subtotalCentavos,
  });

  final String nombre;
  final int precioCentavos;
  final int cantidad;
  final int subtotalCentavos;

  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    return PedidoItem(
      nombre: map['nombre_snapshot'] as String? ?? '',
      precioCentavos: map['precio_centavos'] as int? ?? 0,
      cantidad: map['cantidad'] as int? ?? 0,
      subtotalCentavos: map['subtotal_centavos'] as int? ?? 0,
    );
  }
}

class Pedido {
  const Pedido({
    required this.id,
    required this.clienteId,
    required this.comercioId,
    required this.zonaId,
    required this.estado,
    required this.metodoPago,
    required this.subtotalCentavos,
    required this.domicilioCentavos,
    required this.totalCentavos,
    required this.direccionTexto,
    required this.createdAt,
    this.comercioNombre,
    this.comercioTelefono,
    this.clienteNombre,
    this.clienteTelefono,
    this.items = const <PedidoItem>[],
  });

  final String id;
  final String clienteId;
  final String comercioId;
  final String zonaId;
  final String estado;
  final String metodoPago;
  final int subtotalCentavos;
  final int domicilioCentavos;
  final int totalCentavos;
  final String direccionTexto;
  final DateTime createdAt;
  final String? comercioNombre;
  final String? comercioTelefono;
  final String? clienteNombre;
  final String? clienteTelefono;
  final List<PedidoItem> items;

  Pedido copyWith({
    String? estado,
    String? comercioNombre,
    String? comercioTelefono,
    String? clienteNombre,
    String? clienteTelefono,
    List<PedidoItem>? items,
  }) {
    return Pedido(
      id: id,
      clienteId: clienteId,
      comercioId: comercioId,
      zonaId: zonaId,
      estado: estado ?? this.estado,
      metodoPago: metodoPago,
      subtotalCentavos: subtotalCentavos,
      domicilioCentavos: domicilioCentavos,
      totalCentavos: totalCentavos,
      direccionTexto: direccionTexto,
      createdAt: createdAt,
      comercioNombre: comercioNombre ?? this.comercioNombre,
      comercioTelefono: comercioTelefono ?? this.comercioTelefono,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteTelefono: clienteTelefono ?? this.clienteTelefono,
      items: items ?? this.items,
    );
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    final rawItems = map['pedido_items'];
    final items = <PedidoItem>[];
    if (rawItems is List<dynamic>) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(PedidoItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }
    return Pedido(
      id: map['id'] as String,
      clienteId: map['cliente_id'] as String,
      comercioId: map['comercio_id'] as String,
      zonaId: map['zona_id'] as String,
      estado: map['estado'] as String? ?? 'pendiente_comercio',
      metodoPago: map['metodo_pago'] as String? ?? 'contraentrega',
      subtotalCentavos: map['subtotal_centavos'] as int? ?? 0,
      domicilioCentavos: map['domicilio_centavos'] as int? ?? 0,
      totalCentavos: map['total_centavos'] as int? ?? 0,
      direccionTexto: map['direccion_texto'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      items: items,
    );
  }
}

Map<String, dynamic> asPedidoMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is List && raw.isNotEmpty && raw.first is Map) {
    return Map<String, dynamic>.from(raw.first as Map);
  }
  throw const OrderShapeException();
}

class OrderShapeException implements Exception {
  const OrderShapeException();
}
