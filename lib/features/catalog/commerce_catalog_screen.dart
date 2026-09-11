import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/wammetka_colors.dart';
import '../auth/auth_providers.dart';
import '../order/money.dart';
import '../order/order_errors.dart';
import '../order/order_rules.dart';
import 'catalog_models.dart';
import 'catalog_providers.dart';

class CommerceCatalogScreen extends ConsumerStatefulWidget {
  const CommerceCatalogScreen({super.key});

  @override
  ConsumerState<CommerceCatalogScreen> createState() =>
      _CommerceCatalogScreenState();
}

class _CommerceCatalogScreenState extends ConsumerState<CommerceCatalogScreen> {
  bool _loading = true;
  String? _error;
  List<Producto> _productos = <Producto>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final comercioId = ref.read(sessionProvider)?.comercioId;
    if (comercioId == null) {
      setState(() {
        _error = 'Tu perfil no tiene comercio asignado';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref
          .read(catalogRepositoryProvider)
          .listProductos(comercioId: comercioId, soloDisponibles: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _productos = list;
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

  Future<void> _toggle(Producto product, bool value) async {
    try {
      await ref
          .read(catalogRepositoryProvider)
          .setProductoDisponible(productoId: product.id, disponible: value);
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mapOrderFailure(error))));
    }
  }

  Future<void> _ocultar(Producto product) async {
    await _toggle(product, false);
  }

  Future<void> _nuevo({Producto? existing}) async {
    final comercioId = ref.read(sessionProvider)?.comercioId;
    if (comercioId == null) {
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ProductoForm(
        existing: existing,
        onSave: (nombre, precio, stock, sku) async {
          await ref
              .read(catalogRepositoryProvider)
              .upsertProducto(
                id: existing?.id,
                comercioId: comercioId,
                nombre: nombre,
                precioCentavos: precio,
                stock: stock,
                sku: sku,
              );
        },
        onHide: existing == null
            ? null
            : () async {
                await _ocultar(existing);
              },
      ),
    );
    if (saved == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => _nuevo(),
              child: const Text('Nuevo producto'),
            ),
          ),
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
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _productos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = _productos[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _nuevo(existing: product),
                          title: Text(
                            product.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${formatCopFromCentavos(product.precioCentavos)} · stock ${product.stock}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Switch(
                                value: product.disponible,
                                onChanged: (v) => _toggle(product, v),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _ProductoForm extends StatefulWidget {
  const _ProductoForm({required this.onSave, this.existing, this.onHide});

  final Producto? existing;
  final Future<void> Function()? onHide;
  final Future<void> Function(
    String nombre,
    int precioCentavos,
    int stock,
    String? sku,
  )
  onSave;

  @override
  State<_ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<_ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  late final TextEditingController _stock;
  late final TextEditingController _sku;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nombre = TextEditingController(text: existing?.nombre ?? '');
    _precio = TextEditingController(
      text: existing == null ? '' : '${existing.precioCentavos ~/ 100}',
    );
    _stock = TextEditingController(
      text: existing == null ? '0' : '${existing.stock}',
    );
    _sku = TextEditingController(text: existing?.sku ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    _sku.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final precio = OrderRules.pesosToCentavos(_precio.text);
    final stock = int.parse(_stock.text.trim());
    if (precio == null) {
      setState(() => _error = 'El precio debe ser mayor que 0');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onSave(_nombre.text, precio, stock, _sku.text);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
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
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: OrderRules.productoNombre,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio COP'),
                validator: OrderRules.precioPesos,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
                validator: OrderRules.stock,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sku,
                decoration: const InputDecoration(labelText: 'SKU opcional'),
              ),
              if (_error != null)
                Text(
                  _error!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: WammetkaColors.error),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _guardar,
                child: const Text('Guardar'),
              ),
              if (widget.onHide != null)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          await widget.onHide!();
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop(true);
                        },
                  child: const Text(
                    'Ocultar producto',
                    style: TextStyle(color: WammetkaColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
