import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class FeedAvatarImage extends StatelessWidget {
  final String? avatar;
  final String fallbackText;

  const FeedAvatarImage({
    super.key,
    required this.avatar,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final url = avatar?.trim();

    if (url != null && url.isNotEmpty) {
      return AppNetworkImage(
        url: url,
        errorBuilder: (_, _, _) {
          return _FallbackAvatar(text: fallbackText);
        },
      );
    }

    return _FallbackAvatar(text: fallbackText);
  }
}

class _FallbackAvatar extends StatelessWidget {
  final String text;

  const _FallbackAvatar({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initial = text.trim().isEmpty ? '?' : text.trim()[0].toUpperCase();

    return ColoredBox(
      color: colors.primary.withValues(alpha: .12),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
