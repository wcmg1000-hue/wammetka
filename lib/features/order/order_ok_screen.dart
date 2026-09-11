import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../catalog/catalog_providers.dart';
import 'money.dart';
import 'order_models.dart';

class OrderOkScreen extends ConsumerStatefulWidget {
  const OrderOkScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  ConsumerState<OrderOkScreen> createState() => _OrderOkScreenState();
}

class _OrderOkScreenState extends ConsumerState<OrderOkScreen> {
  Pedido? _pedido;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    try {
      final pedido = await ref
          .read(orderRepositoryProvider)
          .getById(widget.pedidoId);
      if (!mounted) {
        return;
      }
      setState(() => _pedido = pedido);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = _pedido?.totalCentavos;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle,
                size: 72,
                color: WammetkaColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                'Pedido enviado al comercio',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shortPedidoId(widget.pedidoId),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Esperando al comercio',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Suelen responder en 10 minutos',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (total != null)
                Text(
                  '${formatCopFromCentavos(total)} · Contraentrega',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                )
              else
                const Text(
                  'Contraentrega',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/pedidos'),
                child: const Text('Ver mis pedidos'),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ir a inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
