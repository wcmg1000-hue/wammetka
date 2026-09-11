import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../order/cart_actions.dart';
import '../order/cart_controller.dart';
import '../order/cart_models.dart';
import '../order/money.dart';
import 'catalog_models.dart';
import 'catalog_providers.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, required this.comercioId});

  final String comercioId;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  bool _loading = true;
  String? _error;
  Comercio? _shop;
  List<Producto> _productos = <Producto>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final shop = await repo.getComercio(widget.comercioId);
      final products = await repo.listProductos(
        comercioId: widget.comercioId,
        soloDisponibles: true,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _shop = shop;
        _productos = products;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _add(Producto product) async {
    final shop = _shop;
    if (shop == null) {
      return;
    }
    final mun = await ref
        .read(catalogRepositoryProvider)
        .getMunicipio(shop.municipioId);
    if (!mounted) {
      return;
    }
    final draft = CartLine(
      productoId: product.id,
      comercioId: shop.id,
      comercioNombre: shop.nombre,
      nombre: product.nombre,
      precioCentavos: product.precioCentavos,
      cantidad: 1,
      stock: product.stock,
      zonaId: shop.zonaId,
      domicilioCentavos: shop.domicilioCentavos,
      comercioAbierto: shop.abierto,
      municipioHabilitado: mun?.habilitado ?? false,
    );
    final result = await addLineToCart(context, ref, draft);
    if (!mounted) {
      return;
    }
    showCartSnack(context, result);
  }

  int _qtyInCart(String productoId) {
    return ref
        .watch(cartProvider)
        .lines
        .where((l) => l.productoId == productoId)
        .fold<int>(0, (s, l) => s + l.cantidad);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final shop = _shop;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          shop?.nombre ?? 'Catálogo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sin conexión',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            )
          : Column(
              children: [
                if (shop != null && !shop.abierto)
                  Material(
                    color: WammetkaColors.error.withValues(alpha: 0.1),
                    child: const ListTile(
                      title: Text(
                        'Este comercio no recibe pedidos ahora',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (shop != null)
                  ListTile(
                    title: Text(
                      shop.horarioTexto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      shop.abierto ? 'Abierto' : 'Cerrado',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _productos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = _productos[index];
                      final qty = _qtyInCart(product.id);
                      final canAdd =
                          (shop?.abierto ?? false) && product.stock > 0;
                      return Card(
                        child: ListTile(
                          title: Text(
                            product.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            [
                              formatCopFromCentavos(product.precioCentavos),
                              if (product.stock <= 3)
                                'Últimas ${product.stock} und.',
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (qty > 0) ...[
                                IconButton(
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .setQty(product.id, qty - 1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '$qty',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              IconButton(
                                onPressed: canAdd ? () => _add(product) : null,
                                icon: const Icon(Icons.add_circle),
                                color: WammetkaColors.accent,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => context.push('/carrito'),
                  child: Text(
                    'Ver carrito · ${cart.unidades} productos · ${formatCopFromCentavos(cart.totalCentavos)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
    );
  }
}
