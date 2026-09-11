import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import 'auth_providers.dart';

/// Cáscara mínima post-login. Catálogo/pedido = T06.
class SessionShell extends ConsumerWidget {
  const SessionShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;
    final nombre = profile?.nombre ?? 'sesión';
    final rol = profile?.rol.name ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wammetka',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(
            color: WammetkaColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hola, $nombre',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rol: $rol',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'El catálogo y el pedido contraentrega llegan en la siguiente tarea.',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  await ref.read(sessionProvider.notifier).signOut();
                  router.go('/login');
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
