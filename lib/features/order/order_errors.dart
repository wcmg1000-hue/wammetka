const kOrderOfflineMessage =
    'Sin conexión. Revisa tus datos e inténtalo de nuevo. Tu pedido no se envió.';

class OrderAppException implements Exception {
  const OrderAppException(this.message);

  final String message;

  @override
  String toString() => message;
}

String mapOrderFailure(Object error) {
  if (error is OrderAppException) {
    return error.message;
  }
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('socket') ||
      lower.contains('failed host') ||
      lower.contains('clientexception') ||
      lower.contains('timeout') ||
      lower.contains('network')) {
    return kOrderOfflineMessage;
  }
  if (raw.contains('comercio no recibe')) {
    return 'Este comercio no recibe pedidos ahora';
  }
  if (raw.contains('stock')) {
    return 'No hay stock suficiente';
  }
  if (raw.contains('3 pedidos')) {
    return 'Tienes 3 pedidos en curso. Espera o cancela uno';
  }
  if (raw.contains('municipio no está habilitado')) {
    return 'Tu municipio no está habilitado';
  }
  if (raw.contains('un solo comercio')) {
    return 'El carrito es de un solo comercio';
  }
  if (raw.contains('dirección')) {
    return 'Escribe una dirección de al menos 10 caracteres';
  }
  final match = RegExp(r'ERROR:\s*(.+)').firstMatch(raw);
  if (match != null) {
    return match.group(1)!.split('\n').first.trim();
  }
  if (raw.contains('PostgrestException')) {
    final msg = RegExp(r'message:\s*(.+)').firstMatch(raw);
    if (msg != null) {
      return msg.group(1)!.split(',').first.trim();
    }
  }
  return raw.length > 160 ? kOrderOfflineMessage : raw;
}
