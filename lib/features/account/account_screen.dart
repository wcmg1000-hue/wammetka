import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/supabase_bootstrap.dart';
import '../../theme/wammetka_colors.dart';
import '../auth/auth_errors.dart';
import '../auth/auth_providers.dart';
import '../catalog/catalog_providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _busy = false;
  String? _notice;
  String? _error;
  String? _municipioNombre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMunicipio();
    });
  }

  Future<void> _loadMunicipio() async {
    final id = ref.read(sessionProvider)?.municipioId;
    if (id == null) {
      return;
    }
    try {
      final mun = await ref.read(catalogRepositoryProvider).getMunicipio(id);
      if (!mounted) {
        return;
      }
      setState(() => _municipioNombre = mun?.nombre);
    } catch (_) {}
  }

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

  Future<void> _salir() async {
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Cerrar sesión',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        content: const Text(
          '¿Quieres salir de Wammetka?',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    await ref.read(sessionProvider.notifier).signOut();
    router.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(sessionProvider);
    final email = SupabaseHolder.client?.auth.currentUser?.email ?? '';
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            profile?.nombre ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _municipioNombre ?? 'Municipio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'v0.1.0',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
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
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _busy ? null : _guardarPerfil,
            child: const Text('Guardar perfil'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _salir,
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
