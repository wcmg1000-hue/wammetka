import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../auth/auth_providers.dart';
import '../catalog/catalog_providers.dart';
import '../order/money.dart';
import '../order/order_errors.dart';
import '../order/order_models.dart';
import '../order/order_rules.dart';

class RepartoServiciosScreen extends ConsumerStatefulWidget {
  const RepartoServiciosScreen({super.key, this.enCurso = false});

  final bool enCurso;

  @override
  ConsumerState<RepartoServiciosScreen> createState() =>
      _RepartoServiciosScreenState();
}

class _RepartoServiciosScreenState
    extends ConsumerState<RepartoServiciosScreen> {
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
      final uid = ref.read(sessionProvider)?.id;
      final filtered = list.where((pedido) {
        if (widget.enCurso) {
          return (pedido.estado == 'asignado' || pedido.estado == 'recogido') &&
              pedido.repartidorId == uid;
        }
        return DispatchRules.isOferta(pedido.estado, pedido.repartidorId);
      }).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _pedidos = filtered;
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.enCurso
                ? 'No tienes servicios en curso'
                : 'No hay servicios disponibles',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _pedidos.length,
      itemBuilder: (context, index) {
        final pedido = _pedidos[index];
        return ListTile(
          title: Text(
            '${pedido.comercioNombre ?? 'Comercio'} · ${shortPedidoId(pedido.id)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${pedidoEstadoLabel(pedido.estado)} · misma zona · ${formatCopFromCentavos(pedido.domicilioCentavos)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => context.push('/reparto/${pedido.id}'),
        );
      },
    );
  }
}

class RepartoPedidoDetailScreen extends ConsumerStatefulWidget {
  const RepartoPedidoDetailScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  ConsumerState<RepartoPedidoDetailScreen> createState() =>
      _RepartoPedidoDetailScreenState();
}

class _RepartoPedidoDetailScreenState
    extends ConsumerState<RepartoPedidoDetailScreen> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  Pedido? _pedido;
  final _nota = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
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

  Future<void> _run(Future<Pedido> Function() action) async {
    setState(() => _busy = true);
    try {
      final updated = await action();
      if (!mounted) {
        return;
      }
      setState(
        () => _pedido = _pedido?.copyWith(
          estado: updated.estado,
          repartidorId: updated.repartidorId,
        ),
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
    final uid = ref.watch(sessionProvider)?.id ?? '';
    final rol = ref.watch(sessionProvider)?.rol.name ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pedido == null ? 'Servicio' : shortPedidoId(pedido.id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                _error!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : pedido == null
          ? const Center(child: Text('Servicio no encontrado'))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  pedido.comercioNombre ?? 'Comercio',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  pedidoEstadoLabel(pedido.estado),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Misma zona · domicilio ${formatCopFromCentavos(pedido.domicilioCentavos)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  pedido.direccionTexto,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (pedido.comercioTelefono != null) ...[
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
                const SizedBox(height: 16),
                ...pedido.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '×${item.cantidad}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (DispatchRules.canAcceptServicio(
                  rol: rol,
                  estado: pedido.estado,
                  repartidorId: pedido.repartidorId,
                ))
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(orderRepositoryProvider)
                                .aceptarServicio(widget.pedidoId),
                          ),
                    child: const Text('Aceptar servicio'),
                  ),
                if (DispatchRules.canMarkRecogido(
                  rol: rol,
                  estado: pedido.estado,
                  actorId: uid,
                  repartidorId: pedido.repartidorId,
                )) ...[
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(orderRepositoryProvider)
                                .marcarRecogido(widget.pedidoId),
                          ),
                    child: const Text('Marcar recogido'),
                  ),
                ],
                if (DispatchRules.canMarkEntregado(
                  rol: rol,
                  estado: pedido.estado,
                  actorId: uid,
                  repartidorId: pedido.repartidorId,
                )) ...[
                  TextField(
                    controller: _nota,
                    enabled: !_busy,
                    maxLines: 3,
                    maxLength: 180,
                    decoration: const InputDecoration(
                      labelText: 'Nota de entrega',
                      hintText: 'Ej. Entregado en portería',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(orderRepositoryProvider)
                                .marcarEntregado(
                                  pedidoId: widget.pedidoId,
                                  nota: _nota.text,
                                ),
                          ),
                    child: const Text('Marcar entregado'),
                  ),
                ],
                if (pedido.estado == 'entregado')
                  Text(
                    'Entregado',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: WammetkaColors.success),
                  ),
              ],
            ),
    );
  }
}
