import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class AppCircularAvatar extends StatelessWidget {
  const AppCircularAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.7),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: hasImage ? (_, _) {} : null,
      child: !hasImage ? Text(_initial, style: context.h2) : null,
    );
  }

  String get _initial {
    if (name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }
}
