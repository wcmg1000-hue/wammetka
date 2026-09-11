import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import 'auth_providers.dart';

/// Splash del MD: marca, frase y carga; restaura sesión (T05) con tope 3 s.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_boot());
    });
  }

  Future<void> _boot() async {
    final router = GoRouter.of(context);
    try {
      final profile = await ref
          .read(sessionProvider.notifier)
          .restore()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) {
        return;
      }
      if (profile != null) {
        router.go('/sesion');
      } else {
        router.go('/login');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      router.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Wammetka',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineLarge?.copyWith(
                  color: WammetkaColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Compra local, llega de verdad',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: WammetkaColors.text,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const Spacer(),
              Text(
                'v0.1.0',
                style: textTheme.bodySmall?.copyWith(
                  color: WammetkaColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
