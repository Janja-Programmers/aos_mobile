import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';

class AppCircularAvatar extends StatefulWidget {
  const AppCircularAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 32,
    this.backgroundColor,
    this.textColor,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  State<AppCircularAvatar> createState() => _AppCircularAvatarState();
}

class _AppCircularAvatarState extends State<AppCircularAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant AppCircularAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final rawImageUrl = widget.imageUrl?.trim();
    final avatarUrl = buildFileUrl(rawImageUrl)?.trim();

    final hasAvatar =
        avatarUrl != null && avatarUrl.isNotEmpty && !_imageFailed;

    final bgColor =
        widget.backgroundColor ?? colors.primary.withValues(alpha: 0.7);
    final textColor = widget.textColor ?? colors.white;

    final ImageProvider<Object>? backgroundImage = hasAvatar
        ? AppImageDecode.networkProvider(
            context,
            avatarUrl,
            logicalWidth: widget.radius * 2,
            logicalHeight: widget.radius * 2,
          )
        : null;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: bgColor,
      backgroundImage: backgroundImage,
      onBackgroundImageError: hasAvatar
          ? (_, _) {
              if (mounted) {
                setState(() => _imageFailed = true);
              }
            }
          : null,
      child: hasAvatar
          ? null
          : FittedBox(
              child: Text(
                _initial,
                textAlign: TextAlign.center,
                style: context.h4.copyWith(color: textColor, height: 1),
              ),
            ),
    );
  }

  String get _initial {
    final name = widget.name.trim();

    if (name.isEmpty) return '?';

    return name.characters.first.toUpperCase();
  }
}
