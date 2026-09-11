import '../features/auth/auth_models.dart';

String homePathFor(AppRole? role) {
  switch (role) {
    case AppRole.comercio:
      return '/comercio/pedidos';
    case AppRole.repartidor:
      return '/reparto/servicios';
    case AppRole.operacion:
    case AppRole.finanzas:
    case AppRole.admin:
      return '/admin/pedidos';
    case AppRole.cliente:
    case null:
      return '/home';
  }
}
