import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import 'cart_controller.dart';
import 'money.dart';
import 'totals_block.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final textTheme = Theme.of(context).textTheme;
    if (cart.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tu carrito está vacío',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ir a inicio'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tu pedido · ${cart.comercioNombre}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...cart.lines.map(
            (line) => Card(
              child: ListTile(
                title: Text(
                  line.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${formatCopFromCentavos(line.precioCentavos)} · ${formatCopFromCentavos(line.subtotalCentavos)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => ref
                          .read(cartProvider.notifier)
                          .setQty(line.productoId, line.cantidad - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '${line.cantidad}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      onPressed: line.cantidad >= line.stock
                          ? null
                          : () => ref
                                .read(cartProvider.notifier)
                                .setQty(line.productoId, line.cantidad + 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TotalsBlock(
            subtotalCentavos: cart.subtotalCentavos,
            domicilioCentavos: cart.domicilioCentavos,
            totalCentavos: cart.totalCentavos,
          ),
          const SizedBox(height: 8),
          Text(
            'Pagas en efectivo al recibir. No incluye propina en esta versión.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push('/checkout'),
            child: const Text('Continuar a confirmar'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(cartProvider.notifier).clear(),
            child: const Text(
              'Vaciar carrito',
              style: TextStyle(color: WammetkaColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
