import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/wammetka_colors.dart';
import '../catalog/catalog_providers.dart';
import 'money.dart';
import 'order_errors.dart';
import 'order_models.dart';
import 'order_rules.dart';
import 'totals_block.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  Pedido? _pedido;

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
      final pedido = await ref
          .read(orderRepositoryProvider)
          .getById(widget.pedidoId);
      if (!mounted) {
        return;
      }
      setState(() {
        _pedido = pedido;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = mapOrderFailure(error);
        _loading = false;
      });
    }
  }

  Future<void> _cancelar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Cancelar pedido',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        content: const Text(
          '¿Cancelar este pedido? El stock vuelve al comercio.',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(orderRepositoryProvider)
          .cancelar(widget.pedidoId);
      if (!mounted) {
        return;
      }
      setState(
        () => _pedido = _pedido?.copyWith(estado: updated.estado) ?? updated,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mapOrderFailure(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = _pedido;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pedido == null ? 'Pedido' : shortPedidoId(pedido.id),
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
                  const Icon(Icons.cloud_off_outlined),
                  const Text(
                    'Sin conexión',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            )
          : pedido == null
          ? const Center(
              child: Text(
                'Pedido no encontrado',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  pedidoEstadoLabel(pedido.estado),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _Timeline(estado: pedido.estado),
                const SizedBox(height: 16),
                ...pedido.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${item.cantidad} × ${formatCopFromCentavos(item.precioCentavos)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      formatCopFromCentavos(item.subtotalCentavos),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TotalsBlock(
                  subtotalCentavos: pedido.subtotalCentavos,
                  domicilioCentavos: pedido.domicilioCentavos,
                  totalCentavos: pedido.totalCentavos,
                ),
                const SizedBox(height: 12),
                Text(
                  pedido.direccionTexto,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (pedido.comercioTelefono != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: pedido.comercioTelefono!),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Número copiado')),
                      );
                    },
                    child: Text(
                      'Llamar al comercio · ${pedido.comercioTelefono}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (pedidoEsNuevo(pedido.estado)) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _busy ? null : _cancelar,
                    child: const Text(
                      'Cancelar pedido',
                      style: TextStyle(color: WammetkaColors.error),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.estado});

  final String estado;

  static const _steps = <String>[
    'Enviado',
    'Aceptado',
    'Preparado',
    'En camino',
    'Entregado',
  ];

  int get _index {
    switch (estado) {
      case 'pendiente_comercio':
      case 'creado':
        return 0;
      case 'aceptado':
        return 1;
      case 'preparado':
        return 2;
      case 'asignado':
      case 'recogido':
        return 3;
      case 'entregado':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _index;
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundColor: i <= current
                      ? WammetkaColors.primary
                      : WammetkaColors.text.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 4),
                Text(
                  _steps[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
