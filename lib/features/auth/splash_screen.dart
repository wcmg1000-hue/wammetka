import 'package:flutter/material.dart';

import '../../theme/wammetka_colors.dart';
import 'login_screen.dart';

/// Splash del MD: marca, frase y carga; luego Login (sesión llega en T05).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    });
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
