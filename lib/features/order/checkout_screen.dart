import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../catalog/catalog_providers.dart';
import 'cart_controller.dart';
import 'order_errors.dart';
import 'order_rules.dart';
import 'totals_block.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccion = TextEditingController();
  final _refs = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _direccion.dispose();
    _refs.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      setState(() => _error = 'El carrito está vacío');
      return;
    }
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final orders = ref.read(orderRepositoryProvider);
      final shop = await repo.getComercio(cart.comercioId!);
      final mun = shop == null
          ? null
          : await repo.getMunicipio(shop.municipioId);
      final enCurso = await orders.countEnCurso();
      final fullAddress = _refs.text.trim().isEmpty
          ? _direccion.text
          : '${_direccion.text.trim()} · ${_refs.text.trim()}';
      final pedido = await orders.crearPedido(
        cart: cart,
        direccion: fullAddress,
        comercioAbierto: shop?.abierto ?? false,
        municipioHabilitado: mun?.habilitado ?? false,
        pedidosEnCurso: enCurso,
      );
      ref.read(cartProvider.notifier).clear();
      router.go('/pedidos/${pedido.id}/ok');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = mapOrderFailure(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final textTheme = Theme.of(context).textTheme;
    if (cart.isEmpty && !_busy) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Confirmar pedido',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: const Center(
          child: Text(
            'Tu carrito está vacío',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirmar pedido',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _direccion,
                      enabled: !_busy,
                      maxLength: 180,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: OrderRules.direccion,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _refs,
                      enabled: !_busy,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Referencias (opcional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Contraentrega',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TotalsBlock(
                subtotalCentavos: cart.subtotalCentavos,
                domicilioCentavos: cart.domicilioCentavos,
                totalCentavos: cart.totalCentavos,
              ),
              const SizedBox(height: 12),
              Text(
                'Al confirmar, el comercio debe aceptar tu pedido.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Icon(
                  _error == kOrderOfflineMessage
                      ? Icons.cloud_off_outlined
                      : Icons.error_outline,
                  color: WammetkaColors.error,
                ),
                Text(
                  _error == kOrderOfflineMessage ? 'Sin conexión' : _error!,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: WammetkaColors.error,
                  ),
                ),
                if (_error == kOrderOfflineMessage)
                  Text(
                    'Revisa tus datos e inténtalo de nuevo. Tu pedido no se envió.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _confirmar,
                child: const Text('Confirmar pedido'),
              ),
              TextButton(
                onPressed: _busy ? null : () => context.pop(),
                child: const Text('Volver al carrito'),
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x66F7F4EF),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
