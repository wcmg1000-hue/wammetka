import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/wammetka_colors.dart';
import 'theme/wammetka_theme.dart';
import 'features/account/account_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/session_shell.dart';
import 'features/auth/splash_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/catalog/commerce_catalog_screen.dart';
import 'features/catalog/home_screen.dart';
import 'features/order/cart_screen.dart';
import 'features/order/checkout_screen.dart';
import 'features/order/commerce_order_detail_screen.dart';
import 'features/order/commerce_orders_screen.dart';
import 'features/order/order_detail_screen.dart';
import 'features/order/order_ok_screen.dart';
import 'features/order/orders_list_screen.dart';
import 'features/staff/staff_screens.dart';
import 'widgets/app_shells.dart';

GoRouter createWammetkaRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/sesion', builder: (_, _) => const SessionShell()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const ClientShell(index: 0, child: HomeScreen()),
      ),
      GoRoute(
        path: '/carrito',
        builder: (_, _) => const ClientShell(index: 1, child: CartScreen()),
      ),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(
        path: '/pedidos/:id/ok',
        builder: (_, state) =>
            OrderOkScreen(pedidoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pedidos/:id',
        builder: (_, state) =>
            OrderDetailScreen(pedidoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pedidos',
        builder: (_, _) =>
            const ClientShell(index: 2, child: OrdersListScreen()),
      ),
      GoRoute(
        path: '/cuenta',
        builder: (_, _) => const ClientShell(index: 3, child: AccountScreen()),
      ),
      GoRoute(
        path: '/comercio/pedidos/:id',
        builder: (_, state) =>
            CommerceOrderDetailScreen(pedidoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/comercio/pedidos',
        builder: (_, _) =>
            const CommerceShell(index: 0, child: CommerceOrdersScreen()),
      ),
      GoRoute(
        path: '/comercio/catalogo',
        builder: (_, _) =>
            const CommerceShell(index: 1, child: CommerceCatalogScreen()),
      ),
      GoRoute(
        path: '/comercio/cuenta',
        builder: (_, _) =>
            const CommerceShell(index: 2, child: AccountScreen()),
      ),
      GoRoute(
        path: '/comercio/:id',
        builder: (_, state) =>
            CatalogScreen(comercioId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/reparto/servicios',
        builder: (_, _) => const StaffShell(
          index: 0,
          paths: <String>['/reparto/servicios', '/reparto/cuenta'],
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.delivery_dining_outlined),
              selectedIcon: Icon(Icons.delivery_dining),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
          child: RepartoServiciosScreen(),
        ),
      ),
      GoRoute(
        path: '/reparto/cuenta',
        builder: (_, _) => const StaffShell(
          index: 1,
          paths: <String>['/reparto/servicios', '/reparto/cuenta'],
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.delivery_dining_outlined),
              selectedIcon: Icon(Icons.delivery_dining),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
          child: AccountScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/pedidos',
        builder: (_, _) => const StaffShell(
          index: 0,
          paths: <String>['/admin/pedidos', '/admin/cuenta'],
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
          child: AdminPedidosScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/cuenta',
        builder: (_, _) => const StaffShell(
          index: 1,
          paths: <String>['/admin/pedidos', '/admin/cuenta'],
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
          child: AccountScreen(),
        ),
      ),
    ],
  );
}

class WammetkaApp extends StatelessWidget {
  WammetkaApp({super.key, GoRouter? router})
    : _router = router ?? createWammetkaRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Wammetka',
        debugShowCheckedModeBanner: false,
        theme: WammetkaTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}

/// Color primario expuesto para tests de humo del scaffold.
Color get wammetkaPrimary => WammetkaColors.primary;
