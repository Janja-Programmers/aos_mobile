import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';

class ShortBadge extends StatelessWidget {
  final String? contentMode;

  const ShortBadge({super.key, this.contentMode});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final config = _ShortBadgeConfig.fromContentMode(contentMode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: colors.white, size: 13),
          const SizedBox(width: 3),
          Text(
            config.label,
            style: context.small.copyWith(
              color: colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortBadgeConfig {
  final String label;
  final IconData icon;

  const _ShortBadgeConfig({required this.label, required this.icon});

  factory _ShortBadgeConfig.fromContentMode(String? mode) {
    final normalized = mode?.trim().toLowerCase();

    switch (normalized) {
      case ShortContentModes.shop:
        return const _ShortBadgeConfig(
          label: 'Shop',
          icon: Icons.shopping_bag_outlined,
        );

      case ShortContentModes.geo:
        return const _ShortBadgeConfig(
          label: 'Geo',
          icon: Icons.public_outlined,
        );

      case ShortContentModes.talents:
        return const _ShortBadgeConfig(
          label: 'Talent',
          icon: Icons.emoji_events_outlined,
        );

      case ShortContentModes.learn:
        return const _ShortBadgeConfig(
          label: 'Health & Tech',
          icon: Icons.biotech_outlined,
        );

      default:
        return const _ShortBadgeConfig(
          label: 'Short',
          icon: Icons.play_arrow_rounded,
        );
    }
  }
}
