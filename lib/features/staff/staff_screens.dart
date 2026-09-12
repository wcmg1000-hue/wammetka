import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../catalog/catalog_providers.dart';
import '../order/money.dart';
import '../order/order_models.dart';
import '../order/order_rules.dart';

class AdminPedidosScreen extends ConsumerStatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  ConsumerState<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends ConsumerState<AdminPedidosScreen> {
  bool _loading = true;
  List<Pedido> _pedidos = <Pedido>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    try {
      final list = await ref.read(orderRepositoryProvider).listMine();
      if (!mounted) {
        return;
      }
      setState(() {
        _pedidos = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pedidos.isEmpty) {
      return const Center(
        child: Text(
          'No hay pedidos',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return ListView.builder(
      itemCount: _pedidos.length,
      itemBuilder: (context, index) {
        final pedido = _pedidos[index];
        return ListTile(
          title: Text(
            '${shortPedidoId(pedido.id)} · ${pedido.comercioNombre ?? 'Comercio'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${pedidoEstadoLabel(pedido.estado)} · ${formatCopFromCentavos(pedido.totalCentavos)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => context.push('/pedidos/${pedido.id}'),
        );
      },
    );
  }
}
