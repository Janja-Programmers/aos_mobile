import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
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
      return Image.network(
        url,
        fit: BoxFit.cover,
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

    return Container(
      color: colors.white,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}
