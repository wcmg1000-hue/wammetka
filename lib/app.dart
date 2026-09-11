import 'package:flutter/material.dart';

import '../theme/wammetka_colors.dart';
import '../theme/wammetka_theme.dart';
import 'features/auth/splash_screen.dart';

class WammetkaApp extends StatelessWidget {
  const WammetkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wammetka',
      debugShowCheckedModeBanner: false,
      theme: WammetkaTheme.light(),
      home: const SplashScreen(),
    );
  }
}

/// Color primario expuesto para tests de humo del scaffold.
Color get wammetkaPrimary => WammetkaColors.primary;
