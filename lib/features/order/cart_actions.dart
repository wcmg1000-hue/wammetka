import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/wammetka_colors.dart';
import 'cart_controller.dart';
import 'cart_models.dart';

Future<CartAddResult> addLineToCart(
  BuildContext context,
  WidgetRef ref,
  CartLine draft,
) async {
  final cart = ref.read(cartProvider);
  final result = ref.read(cartProvider.notifier).tryAdd(draft);
  if (result != CartAddResult.mix || !context.mounted) {
    return result;
  }
  final other = cart.comercioNombre ?? 'otro comercio';
  final accepted = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text(
          'Vaciar carrito',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: Text(
          'Tu carrito tiene productos de $other. ¿Vaciar y agregar de ${draft.comercioNombre}?',
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Vaciar y continuar'),
          ),
        ],
      );
    },
  );
  if (accepted == true) {
    ref.read(cartProvider.notifier).replaceWith(draft);
    return CartAddResult.added;
  }
  return CartAddResult.mix;
}

void showCartSnack(BuildContext context, CartAddResult result) {
  final messenger = ScaffoldMessenger.of(context);
  switch (result) {
    case CartAddResult.added:
      messenger.showSnackBar(
        const SnackBar(content: Text('Agregado al carrito')),
      );
    case CartAddResult.closed:
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Este comercio no recibe pedidos ahora'),
          backgroundColor: WammetkaColors.error,
        ),
      );
    case CartAddResult.noStock:
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No hay stock suficiente'),
          backgroundColor: WammetkaColors.error,
        ),
      );
    case CartAddResult.mix:
      break;
  }
}
