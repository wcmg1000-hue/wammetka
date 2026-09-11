import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../../widgets/accent_card.dart';
import '../catalog/catalog_providers.dart';
import 'money.dart';
import 'order_models.dart';
import 'order_rules.dart';

class CommerceOrdersScreen extends ConsumerStatefulWidget {
  const CommerceOrdersScreen({super.key});

  @override
  ConsumerState<CommerceOrdersScreen> createState() =>
      _CommerceOrdersScreenState();
}

class _CommerceOrdersScreenState extends ConsumerState<CommerceOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  String? _error;
  List<Pedido> _pedidos = <Pedido>[];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
    final nuevos = _pedidos.where((p) => pedidoEsNuevo(p.estado)).toList();
    final curso = _pedidos
        .where((p) => pedidoEnCursoComercio(p.estado))
        .toList();
    final cerrados = _pedidos
        .where(
          (p) => !pedidoEsNuevo(p.estado) && !pedidoEnCursoComercio(p.estado),
        )
        .toList();
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Nuevos'),
            Tab(text: 'En curso'),
            Tab(text: 'Cerrados'),
          ],
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: TextButton(
                    onPressed: _load,
                    child: const Text('Reintentar'),
                  ),
                )
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _Bandeja(
                      pedidos: nuevos,
                      empty: 'No hay pedidos nuevos',
                      onRefresh: _load,
                    ),
                    _Bandeja(
                      pedidos: curso,
                      empty: 'No hay pedidos en curso',
                      onRefresh: _load,
                    ),
                    _Bandeja(
                      pedidos: cerrados,
                      empty: 'No hay pedidos cerrados',
                      onRefresh: _load,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Bandeja extends StatelessWidget {
  const _Bandeja({
    required this.pedidos,
    required this.empty,
    required this.onRefresh,
  });

  final List<Pedido> pedidos;
  final String empty;
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
          final hour =
              '${pedido.createdAt.hour.toString().padLeft(2, '0')}:${pedido.createdAt.minute.toString().padLeft(2, '0')}';
          return AccentCard(
            accent: pedidoEsNuevo(pedido.estado)
                ? WammetkaColors.accent
                : WammetkaColors.primary,
            onTap: () => context.push('/comercio/pedidos/${pedido.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pedido.clienteNombre ?? 'Cliente',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (pedidoEsNuevo(pedido.estado))
                      const Text(
                        'Nuevo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$hour · ${pedido.items.length} productos · ${formatCopFromCentavos(pedido.subtotalCentavos)}',
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
