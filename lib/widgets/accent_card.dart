import 'package:flutter/material.dart';

import '../theme/wammetka_colors.dart';
import '../theme/wammetka_theme.dart';

/// Tarjeta con borde uniforme y franja de acento (lección 1.1 / 1.14).
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
  });

  final Color accent;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WammetkaColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WammetkaTheme.radiusCard),
        side: BorderSide(color: WammetkaColors.text.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: child,
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(WammetkaTheme.radiusCard),
                  bottomLeft: Radius.circular(WammetkaTheme.radiusCard),
                ),
                child: Container(width: 8, color: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
