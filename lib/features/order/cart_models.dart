import 'order_rules.dart';

class CartLine {
  const CartLine({
    required this.productoId,
    required this.comercioId,
    required this.comercioNombre,
    required this.nombre,
    required this.precioCentavos,
    required this.cantidad,
    required this.stock,
    required this.zonaId,
    required this.domicilioCentavos,
    required this.comercioAbierto,
    required this.municipioHabilitado,
  });

  final String productoId;
  final String comercioId;
  final String comercioNombre;
  final String nombre;
  final int precioCentavos;
  final int cantidad;
  final int stock;
  final String zonaId;
  final int domicilioCentavos;
  final bool comercioAbierto;
  final bool municipioHabilitado;

  int get subtotalCentavos => precioCentavos * cantidad;

  CartLine copyWith({int? cantidad, int? stock, bool? comercioAbierto}) {
    return CartLine(
      productoId: productoId,
      comercioId: comercioId,
      comercioNombre: comercioNombre,
      nombre: nombre,
      precioCentavos: precioCentavos,
      cantidad: cantidad ?? this.cantidad,
      stock: stock ?? this.stock,
      zonaId: zonaId,
      domicilioCentavos: domicilioCentavos,
      comercioAbierto: comercioAbierto ?? this.comercioAbierto,
      municipioHabilitado: municipioHabilitado,
    );
  }
}

class CartState {
  const CartState({this.lines = const <CartLine>[]});

  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  String? get comercioId => lines.isEmpty ? null : lines.first.comercioId;

  String? get comercioNombre =>
      lines.isEmpty ? null : lines.first.comercioNombre;

  String? get zonaId => lines.isEmpty ? null : lines.first.zonaId;

  int get unidades => lines.fold<int>(0, (sum, line) => sum + line.cantidad);

  int get subtotalCentavos =>
      lines.fold<int>(0, (sum, line) => sum + line.subtotalCentavos);

  int get domicilioCentavos =>
      lines.isEmpty ? 0 : lines.first.domicilioCentavos;

  int get totalCentavos => OrderRules.totalCliente(
    subtotalCentavos: subtotalCentavos,
    domicilioCentavos: domicilioCentavos,
  );

  List<Map<String, dynamic>> toRpcItems() {
    return lines
        .map(
          (line) => <String, dynamic>{
            'producto_id': line.productoId,
            'cantidad': line.cantidad,
          },
        )
        .toList();
  }
}

enum CartAddResult { added, mix, closed, noStock }
