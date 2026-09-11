class Municipio {
  const Municipio({
    required this.id,
    required this.nombre,
    required this.habilitado,
  });

  final String id;
  final String nombre;
  final bool habilitado;

  factory Municipio.fromMap(Map<String, dynamic> map) {
    return Municipio(
      id: map['id'] as String,
      nombre: map['nombre'] as String? ?? '',
      habilitado: map['habilitado'] as bool? ?? false,
    );
  }
}

class Comercio {
  const Comercio({
    required this.id,
    required this.nombre,
    required this.abierto,
    required this.municipioId,
    required this.zonaId,
    required this.domicilioCentavos,
    required this.municipioNombre,
    required this.zonaNombre,
    this.horaApertura,
    this.horaCierre,
    this.telefono,
    this.estadoAprobacion = 'activo',
  });

  final String id;
  final String nombre;
  final bool abierto;
  final String municipioId;
  final String zonaId;
  final int domicilioCentavos;
  final String municipioNombre;
  final String zonaNombre;
  final String? horaApertura;
  final String? horaCierre;
  final String? telefono;
  final String estadoAprobacion;

  String get horarioTexto {
    final a = _hhmm(horaApertura);
    final c = _hhmm(horaCierre);
    if (a.isEmpty && c.isEmpty) {
      return zonaNombre;
    }
    return '$a–$c · $zonaNombre';
  }

  static String _hhmm(String? raw) {
    if (raw == null || raw.isEmpty) {
      return '';
    }
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  factory Comercio.fromMaps({
    required Map<String, dynamic> comercio,
    required Map<String, dynamic>? zona,
    required Map<String, dynamic>? municipio,
  }) {
    return Comercio(
      id: comercio['id'] as String,
      nombre: comercio['nombre'] as String? ?? '',
      abierto: comercio['abierto'] as bool? ?? false,
      municipioId: comercio['municipio_id'] as String,
      zonaId: comercio['zona_id'] as String,
      domicilioCentavos: zona?['tarifa_domicilio_centavos'] as int? ?? 0,
      municipioNombre: municipio?['nombre'] as String? ?? '',
      zonaNombre: zona?['nombre'] as String? ?? '',
      horaApertura: comercio['hora_apertura'] as String?,
      horaCierre: comercio['hora_cierre'] as String?,
      telefono: comercio['telefono'] as String?,
      estadoAprobacion: comercio['estado_aprobacion'] as String? ?? 'activo',
    );
  }
}

class Producto {
  const Producto({
    required this.id,
    required this.comercioId,
    required this.nombre,
    required this.precioCentavos,
    required this.stock,
    required this.disponible,
    this.sku,
  });

  final String id;
  final String comercioId;
  final String nombre;
  final int precioCentavos;
  final int stock;
  final bool disponible;
  final String? sku;

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as String,
      comercioId: map['comercio_id'] as String,
      nombre: map['nombre'] as String? ?? '',
      precioCentavos: map['precio_centavos'] as int? ?? 0,
      stock: map['stock'] as int? ?? 0,
      disponible: map['disponible'] as bool? ?? false,
      sku: map['sku'] as String?,
    );
  }
}
