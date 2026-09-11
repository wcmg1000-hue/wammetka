import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/role_home.dart';
import 'auth_providers.dart';

/// Redirige al home del rol. Conservada por compatibilidad de `/sesion`.
class SessionShell extends ConsumerStatefulWidget {
  const SessionShell({super.key});

  @override
  ConsumerState<SessionShell> createState() => _SessionShellState();
}

class _SessionShellState extends ConsumerState<SessionShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      router.go(homePathFor(ref.read(sessionProvider)?.rol));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
