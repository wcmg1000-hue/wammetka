String formatCopFromCentavos(int centavos) {
  final pesos = (centavos / 100).round();
  final raw = pesos.abs().toString();
  final buf = StringBuffer();
  if (pesos < 0) {
    buf.write('-');
  }
  for (var i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) {
      buf.write('.');
    }
    buf.write(raw[i]);
  }
  return '\$$buf COP';
}

String shortPedidoId(String id) {
  final compact = id.replaceAll('-', '');
  if (compact.length <= 8) {
    return compact.toUpperCase();
  }
  return compact.substring(0, 8).toUpperCase();
}
