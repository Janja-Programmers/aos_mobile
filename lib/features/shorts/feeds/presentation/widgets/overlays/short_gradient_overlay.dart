import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

/// ─────────────────────────────────────────────
/// SHORT GRADIENT OVERLAY
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → Render readability gradient
/// → No positioning
/// → No input handling
///

class ShortGradientOverlay extends StatelessWidget {
  const ShortGradientOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            stops: const [0.0, 0.5, 0.8, 1.0],

            colors: [
              Colors.transparent,

              /// subtle mid fade
              colors.surface.withValues(alpha: 0.15),

              /// stronger lower fade
              colors.surface.withValues(alpha: 0.6),

              /// solid bottom
              colors.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
      ),
    );
  }
}
