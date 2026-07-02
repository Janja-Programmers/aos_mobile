import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;
  final String patternAssetPath;

  const ChatBackground({
    super.key,
    required this.child,
    required this.patternAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.surface)),

        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: isDark ? 0.18 : 0.10,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isDark
                      ? colors.white.withValues(alpha: 0.45)
                      : colors.black.withValues(alpha: 0.35),
                  BlendMode.srcIn,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(patternAssetPath),
                      repeat: ImageRepeat.repeat,
                      scale: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: isDark ? 0.45 : 0.25),
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }
}
