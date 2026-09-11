import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/catalog_providers.dart';
import '../features/order/cart_controller.dart';
import '../features/auth/auth_providers.dart';
import '../theme/wammetka_colors.dart';

class ClientShell extends ConsumerWidget {
  const ClientShell({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  static const _paths = <String>['/home', '/carrito', '/pedidos', '/cuenta'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidades = ref.watch(cartProvider).unidades;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => context.go(_paths[value]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unidades > 0,
              label: Text('$unidades'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unidades > 0,
              label: Text('$unidades'),
              child: const Icon(Icons.shopping_bag),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}

class CommerceShell extends ConsumerStatefulWidget {
  const CommerceShell({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  ConsumerState<CommerceShell> createState() => _CommerceShellState();
}

class _CommerceShellState extends ConsumerState<CommerceShell> {
  bool? _abierto;
  bool _busy = false;

  static const _paths = <String>[
    '/comercio/pedidos',
    '/comercio/catalogo',
    '/comercio/cuenta',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAbierto();
    });
  }

  Future<void> _loadAbierto() async {
    final comercioId = ref.read(sessionProvider)?.comercioId;
    if (comercioId == null) {
      return;
    }
    try {
      final shop = await ref
          .read(catalogRepositoryProvider)
          .getComercio(comercioId);
      if (!mounted) {
        return;
      }
      setState(() => _abierto = shop?.abierto);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _abierto = false);
    }
  }

  Future<void> _toggle(bool value) async {
    final comercioId = ref.read(sessionProvider)?.comercioId;
    if (comercioId == null) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(catalogRepositoryProvider)
          .setComercioAbierto(comercioId: comercioId, abierto: value);
      if (!mounted) {
        return;
      }
      setState(() => _abierto = value);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cambiar el estado del comercio'),
          backgroundColor: WammetkaColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wammetka',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Row(
            children: [
              Text(
                'Comercio abierto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Switch(
                value: _abierto ?? false,
                onChanged: _busy || _abierto == null ? null : _toggle,
              ),
            ],
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.index,
        onDestinationSelected: (value) => context.go(_paths[value]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}

class StaffShell extends StatelessWidget {
  const StaffShell({
    super.key,
    required this.index,
    required this.child,
    required this.paths,
    required this.destinations,
    this.title = 'Wammetka',
  });

  final int index;
  final Widget child;
  final List<String> paths;
  final List<NavigationDestination> destinations;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => context.go(paths[value]),
        destinations: destinations,
      ),
    );
  }
}
