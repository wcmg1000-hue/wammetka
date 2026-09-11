/// Reglas de pedido en cliente. El total definitivo lo recalcula la RPC.
abstract final class OrderRules {
  static const int maxPendientes = 3;
  static const int direccionMin = 10;
  static const int direccionMax = 180;
  static const int nombreProductoMin = 3;

  static int totalCliente({
    required int subtotalCentavos,
    required int domicilioCentavos,
  }) {
    return subtotalCentavos + domicilioCentavos;
  }

  static String? direccion(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < direccionMin) {
      return 'Escribe una dirección de al menos 10 caracteres';
    }
    if (text.length > direccionMax) {
      return 'La dirección no puede pasar de 180 caracteres';
    }
    return null;
  }

  static String? cantidadVsStock(int cantidad, int stock) {
    if (cantidad < 1) {
      return 'Cantidad inválida';
    }
    if (cantidad > stock) {
      return 'No hay stock suficiente';
    }
    return null;
  }

  static bool sameComercio(String? currentId, String nextId) {
    return currentId == null || currentId == nextId;
  }

  static String? productoNombre(String? value) {
    if ((value ?? '').trim().length < nombreProductoMin) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? precioPesos(String? value) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    final pesos = int.tryParse(cleaned);
    if (pesos == null || pesos <= 0) {
      return 'El precio debe ser mayor que 0';
    }
    return null;
  }

  static int? pesosToCentavos(String? value) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    final pesos = int.tryParse(cleaned);
    if (pesos == null || pesos <= 0) {
      return null;
    }
    return pesos * 100;
  }

  static String? stock(String? value) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null || n < 0) {
      return 'El stock no puede ser negativo';
    }
    return null;
  }

  static String? canConfirm({
    required bool comercioAbierto,
    required bool municipioHabilitado,
    required int pedidosEnCurso,
    required int cantidad,
    required int stock,
  }) {
    if (!municipioHabilitado) {
      return 'Tu municipio no está habilitado';
    }
    if (!comercioAbierto) {
      return 'Este comercio no recibe pedidos ahora';
    }
    if (pedidosEnCurso >= maxPendientes) {
      return 'Tienes 3 pedidos en curso. Espera o cancela uno';
    }
    return cantidadVsStock(cantidad, stock);
  }
}

String pedidoEstadoLabel(String estado) {
  switch (estado) {
    case 'pendiente_comercio':
    case 'creado':
      return 'Esperando al comercio';
    case 'aceptado':
      return 'Aceptado';
    case 'preparado':
      return 'En preparación';
    case 'asignado':
    case 'recogido':
      return 'En camino';
    case 'entregado':
      return 'Entregado';
    case 'cerrado':
    case 'cancelado':
      return 'Cancelado';
    case 'rechazado_comercio':
      return 'Rechazado';
    default:
      return estado;
  }
}

bool pedidoEsActivo(String estado) {
  return estado == 'pendiente_comercio' ||
      estado == 'creado' ||
      estado == 'aceptado' ||
      estado == 'preparado' ||
      estado == 'asignado' ||
      estado == 'recogido';
}

bool pedidoEsNuevo(String estado) =>
    estado == 'pendiente_comercio' || estado == 'creado';

bool pedidoEnCursoComercio(String estado) =>
    estado == 'aceptado' || estado == 'preparado' || estado == 'asignado';
