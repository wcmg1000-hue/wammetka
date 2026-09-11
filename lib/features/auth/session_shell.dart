import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import 'auth_errors.dart';
import 'auth_providers.dart';

/// Cáscara mínima post-login. Catálogo/pedido = T06.
class SessionShell extends ConsumerStatefulWidget {
  const SessionShell({super.key});

  @override
  ConsumerState<SessionShell> createState() => _SessionShellState();
}

class _SessionShellState extends ConsumerState<SessionShell> {
  bool _busy = false;
  String? _notice;
  String? _error;

  Future<void> _guardarPerfil() async {
    setState(() {
      _busy = true;
      _notice = null;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).syncOwnProfile();
      if (!mounted) {
        return;
      }
      setState(() => _notice = 'Perfil guardado');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = mapAuthFailure(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_notice != null) ...[
                const SizedBox(height: 12),
                Text(
                  _notice!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: WammetkaColors.success,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: WammetkaColors.error,
                  ),
                ),
              ],
              const Spacer(),
              OutlinedButton(
                onPressed: _busy ? null : _guardarPerfil,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar perfil'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
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
