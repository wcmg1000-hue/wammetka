enum AppRole { cliente, comercio, repartidor, operacion, finanzas, admin }

AppRole appRoleFromString(String raw) {
  return AppRole.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => AppRole.cliente,
  );
}

class AppProfile {
  const AppProfile({
    required this.id,
    required this.rol,
    required this.nombre,
    required this.activo,
    this.telefono,
    this.municipioId,
    this.comercioId,
  });

  final String id;
  final AppRole rol;
  final String nombre;
  final bool activo;
  final String? telefono;
  final String? municipioId;
  final String? comercioId;

  factory AppProfile.fromMap(Map<String, dynamic> map) {
    return AppProfile(
      id: map['id'] as String,
      rol: appRoleFromString(map['rol'] as String? ?? 'cliente'),
      nombre: map['nombre'] as String? ?? '',
      activo: map['activo'] as bool? ?? false,
      telefono: map['telefono'] as String?,
      municipioId: map['municipio_id'] as String?,
      comercioId: map['comercio_id'] as String?,
    );
  }
}

class AuthAppException implements Exception {
  const AuthAppException(this.message);

  final String message;

  @override
  String toString() => message;
}
