import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

class AppCircularAvatar extends StatefulWidget {
  const AppCircularAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 40,
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
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final hasImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty && !_imageFailed;

    final imgUrl = buildFileUrl(widget.imageUrl);

    final bgColor = widget.backgroundColor ?? colors.primary.withOpacity(0.7);

    final textColor = widget.textColor ?? colors.white;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: bgColor,

      /// ✅ Only use image if valid
      backgroundImage: hasImage ? NetworkImage(imgUrl!) : null,

      /// 🔥 Handle failure
      onBackgroundImageError: hasImage
          ? (_, _) => setState(() => _imageFailed = true)
          : null,

      /// ✅ Fallback to initials
      child: !hasImage
          ? FittedBox(
              child: Text(
                _initial,
                textAlign: TextAlign.center,
                style: context.h4.copyWith(color: textColor, height: 1),
              ),
            )
          : null,
    );
  }

  String get _initial {
    if (widget.name.isEmpty) return '?';
    return widget.name.characters.first.toUpperCase();
  }
}
