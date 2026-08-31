import 'dart:io';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  const ChatBackground({
    super.key,
    required this.child,
    required this.patternAssetPath,
    required this.preferences,
  });

  final Widget child;
  final String patternAssetPath;
  final ChatLocalPreferencesState preferences;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final solid = preferences.solidWallpaper;
    final galleryPath = preferences.wallpaperImagePath?.trim();
    final useGallery = preferences.hasGalleryWallpaper && galleryPath != null;
    final Size viewportSize = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: solid?.color ?? colors.surface),
        ),

        if (useGallery)
          Positioned.fill(
            child: Image(
              image: AppImageDecode.fileProvider(
                context,
                File(galleryPath),
                logicalWidth: viewportSize.width,
                logicalHeight: viewportSize.height,
              ),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return ColoredBox(color: solid?.color ?? colors.surface);
              },
            ),
          )
        else if (solid == null)
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
                color: _overlayColor(
                  context: context,
                  isDark: isDark,
                  hasCustomWallpaper: solid != null || useGallery,
                ),
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }

  Color _overlayColor({
    required BuildContext context,
    required bool isDark,
    required bool hasCustomWallpaper,
  }) {
    final colors = context.appColors;
    if (hasCustomWallpaper) {
      return colors.black.withValues(alpha: isDark ? 0.18 : 0.08);
    }

    return colors.surface.withValues(alpha: isDark ? 0.45 : 0.25);
  }
}
