import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_models.dart';

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  CartAddResult tryAdd(CartLine draft) {
    if (!draft.comercioAbierto) {
      return CartAddResult.closed;
    }
    if (draft.stock < 1) {
      return CartAddResult.noStock;
    }
    final current = state.comercioId;
    if (current != null && current != draft.comercioId) {
      return CartAddResult.mix;
    }
    final idx = state.lines.indexWhere(
      (line) => line.productoId == draft.productoId,
    );
    if (idx < 0) {
      state = CartState(
        lines: <CartLine>[...state.lines, draft.copyWith(cantidad: 1)],
      );
      return CartAddResult.added;
    }
    final line = state.lines[idx];
    if (line.cantidad >= line.stock) {
      return CartAddResult.noStock;
    }
    final next = List<CartLine>.from(state.lines);
    next[idx] = line.copyWith(cantidad: line.cantidad + 1);
    state = CartState(lines: next);
    return CartAddResult.added;
  }

  void replaceWith(CartLine draft) {
    state = const CartState();
    tryAdd(draft);
  }

  void setQty(String productoId, int cantidad) {
    if (cantidad < 1) {
      state = CartState(
        lines: state.lines
            .where((line) => line.productoId != productoId)
            .toList(),
      );
      return;
    }
    final next = state.lines.map((line) {
      if (line.productoId != productoId) {
        return line;
      }
      final capped = cantidad > line.stock ? line.stock : cantidad;
      return line.copyWith(cantidad: capped);
    }).toList();
    state = CartState(lines: next);
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
