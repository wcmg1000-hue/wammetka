import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/wammetka_colors.dart';
import '../catalog/catalog_providers.dart';
import 'money.dart';
import 'order_errors.dart';
import 'order_models.dart';
import 'order_rules.dart';

class CommerceOrderDetailScreen extends ConsumerStatefulWidget {
  const CommerceOrderDetailScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  ConsumerState<CommerceOrderDetailScreen> createState() =>
      _CommerceOrderDetailScreenState();
}

class _CommerceOrderDetailScreenState
    extends ConsumerState<CommerceOrderDetailScreen> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  Pedido? _pedido;

  static const _causales = <String>['Sin stock', 'Fuera de horario', 'Otro'];

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

  Future<void> _aceptar() async {
    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(orderRepositoryProvider)
          .responder(pedidoId: widget.pedidoId, aceptar: true);
      if (!mounted) {
        return;
      }
      setState(() => _pedido = _pedido?.copyWith(estado: updated.estado));
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

  Future<void> _rechazar() async {
    final causal = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Rechazar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ..._causales.map(
                (c) => ListTile(
                  title: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.of(ctx).pop(c),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (causal == null) {
      return;
    }
    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(orderRepositoryProvider)
          .responder(pedidoId: widget.pedidoId, aceptar: false, nota: causal);
      if (!mounted) {
        return;
      }
      setState(() => _pedido = _pedido?.copyWith(estado: updated.estado));
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

  Future<void> _preparado() async {
    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(orderRepositoryProvider)
          .marcarPreparado(widget.pedidoId);
      if (!mounted) {
        return;
      }
      setState(() => _pedido = _pedido?.copyWith(estado: updated.estado));
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
              child: TextButton(
                onPressed: _load,
                child: const Text('Reintentar'),
              ),
            )
          : pedido == null
          ? const Center(child: Text('Pedido no encontrado'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  pedidoEstadoLabel(pedido.estado),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  pedido.clienteNombre ?? 'Cliente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (pedido.clienteTelefono != null)
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: pedido.clienteTelefono!),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Número copiado')),
                      );
                    },
                    child: Text(
                      pedido.clienteTelefono!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
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
                Text(
                  'Subtotal productos ${formatCopFromCentavos(pedido.subtotalCentavos)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  pedido.direccionTexto,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                if (pedidoEsNuevo(pedido.estado)) ...[
                  FilledButton(
                    onPressed: _busy ? null : _aceptar,
                    child: const Text('Aceptar pedido'),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _rechazar,
                    child: const Text(
                      'Rechazar',
                      style: TextStyle(color: WammetkaColors.error),
                    ),
                  ),
                ],
                if (pedido.estado == 'aceptado')
                  FilledButton(
                    onPressed: _busy ? null : _preparado,
                    child: const Text('Marcar preparado'),
                  ),
              ],
            ),
    );
  }
}
