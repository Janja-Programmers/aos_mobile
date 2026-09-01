import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShortThumbnail extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final bool showGradient;
  final Color? fallbackBackgroundColor;
  final IconData fallbackIcon;

  const ShortThumbnail({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.height,
    this.showGradient = false,
    this.fallbackBackgroundColor,
    this.fallbackIcon = Icons.video_library_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fallbackColor = fallbackBackgroundColor ?? colors.surface;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double? logicalWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : null;
        final double? logicalHeight =
            height ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : null);
        final AppImageDecodeSize decodeSize = AppImageDecode.forBox(
          context,
          logicalWidth: logicalWidth,
          logicalHeight: logicalHeight,
        );

        final Widget child = Stack(
          fit: StackFit.passthrough,
          children: [
            imageUrl.trim().isEmpty
                ? _Fallback(
                    height: height,
                    backgroundColor: fallbackColor,
                    icon: fallbackIcon,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: fit,
                    width: double.infinity,
                    height: height,
                    memCacheWidth: decodeSize.width,
                    memCacheHeight: decodeSize.height,
                    placeholder: (context, url) => _Placeholder(
                      height: height,
                      backgroundColor: fallbackColor,
                    ),
                    errorWidget: (context, url, error) => _Fallback(
                      height: height,
                      backgroundColor: fallbackColor,
                      icon: fallbackIcon,
                    ),
                  ),
            if (showGradient)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.black.withValues(alpha: .04),
                          colors.black.withValues(alpha: .10),
                          colors.black.withValues(alpha: .70),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );

        if (height == null) {
          return child;
        }

        return SizedBox(height: height, width: double.infinity, child: child);
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double? height;
  final Color backgroundColor;

  const _Placeholder({required this.height, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: height ?? 180,
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final double? height;
  final Color backgroundColor;
  final IconData icon;

  const _Fallback({
    required this.height,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: height ?? 180,
      width: double.infinity,
      color: backgroundColor,
      child: Icon(icon, color: colors.textMuted, size: 30),
    );
  }
}
