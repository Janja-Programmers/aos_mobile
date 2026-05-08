import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class ShortAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  /// Allows reuse in normal card rows and overlay metrics.
  final double size;
  final double? fontSize;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderWidth;

  const ShortAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 24,
    this.fontSize,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initials = _getInitials(name);

    final fallbackBackground =
        backgroundColor ?? colors.primary.withOpacity(.12);
    final fallbackTextColor = textColor ?? colors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? colors.border,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: avatarUrl == null || avatarUrl!.trim().isEmpty
            ? _FallbackAvatar(
                initials: initials,
                backgroundColor: fallbackBackground,
                textColor: fallbackTextColor,
                fontSize: fontSize ?? _defaultFontSize(size),
              )
            : CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: fallbackBackground),
                errorWidget: (_, _, _) => _FallbackAvatar(
                  initials: initials,
                  backgroundColor: fallbackBackground,
                  textColor: fallbackTextColor,
                  fontSize: fontSize ?? _defaultFontSize(size),
                ),
              ),
      ),
    );
  }

  double _defaultFontSize(double size) {
    if (size <= 24) return 10;
    if (size <= 30) return 11;
    if (size <= 38) return 13;
    return 15;
  }

  String _getInitials(String name) {
    final clean = name.trim();

    if (clean.isEmpty) return '?';

    final parts = clean.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _FallbackAvatar extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const _FallbackAvatar({
    required this.initials,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: context.small.copyWith(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
