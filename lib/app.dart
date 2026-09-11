import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/wammetka_colors.dart';
import '../theme/wammetka_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/session_shell.dart';
import 'features/auth/splash_screen.dart';

GoRouter createWammetkaRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/sesion', builder: (_, _) => const SessionShell()),
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
