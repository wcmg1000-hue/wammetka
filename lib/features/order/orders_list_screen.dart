import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../../widgets/accent_card.dart';
import '../catalog/catalog_providers.dart';
import 'money.dart';
import 'order_models.dart';
import 'order_rules.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  String? _error;
  List<Pedido> _pedidos = <Pedido>[];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(orderRepositoryProvider).listMine();
      if (!mounted) {
        return;
      }
      setState(() {
        _pedidos = list;
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

  @override
  Widget build(BuildContext context) {
    final activos = _pedidos.where((p) => pedidoEsActivo(p.estado)).toList();
    final anteriores = _pedidos
        .where((p) => !pedidoEsActivo(p.estado))
        .toList();
    return SafeArea(
      child: Column(
        children: [
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Activos'),
              Tab(text: 'Anteriores'),
            ],
          ),
          Expanded(
            child: _loading
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
                        TextButton(
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _PedidoTab(
                        pedidos: activos,
                        empty: 'Todavía no has pedido',
                        onOpen: (id) => context.push('/pedidos/$id'),
                        onRefresh: _load,
                      ),
                      _PedidoTab(
                        pedidos: anteriores,
                        empty: 'Todavía no has pedido',
                        onOpen: (id) => context.push('/pedidos/$id'),
                        onRefresh: _load,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PedidoTab extends StatelessWidget {
  const _PedidoTab({
    required this.pedidos,
    required this.empty,
    required this.onOpen,
    required this.onRefresh,
  });

  final List<Pedido> pedidos;
  final String empty;
  final ValueChanged<String> onOpen;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (pedidos.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Text(
              empty,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pedidos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return AccentCard(
            accent: pedidoEsNuevo(pedido.estado)
                ? WammetkaColors.accent
                : WammetkaColors.primary,
            onTap: () => onOpen(pedido.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.comercioNombre ?? 'Comercio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatCopFromCentavos(pedido.totalCentavos)} · ${pedidoEstadoLabel(pedido.estado)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
