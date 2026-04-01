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
  });

  final String name;
  final String? imageUrl;
  final double radius;

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

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: colors.primary.withOpacity(0.7),

      /// ✅ Only use image if valid
      backgroundImage: hasImage ? NetworkImage(imgUrl!) : null,

      /// 🔥 Handle failure
      onBackgroundImageError: hasImage
          ? (_, _) => setState(() => _imageFailed = true)
          : null,

      /// ✅ Fallback to initials
      child: !hasImage
          ? Text(_initial, style: context.h2.copyWith(color: colors.white))
          : null,
    );
  }

  String get _initial {
    if (widget.name.isEmpty) return '?';
    return widget.name.characters.first.toUpperCase();
  }
}
