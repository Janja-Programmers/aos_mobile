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

    final config = _ShortBadgeConfig.fromContentMode(contentMode, colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: config.color,
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
  final Color color;

  const _ShortBadgeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });

  factory _ShortBadgeConfig.fromContentMode(String? mode, dynamic colors) {
    final normalized = mode?.trim().toLowerCase();

    switch (normalized) {
      case ShortContentModes.shop:
        return _ShortBadgeConfig(
          label: 'Shop',
          icon: Icons.shopping_bag_outlined,
          color: colors.primary,
        );

      case ShortContentModes.geo:
        return _ShortBadgeConfig(
          label: 'Geo',
          icon: Icons.public_outlined,
          color: colors.success,
        );

      case ShortContentModes.talent:
        return _ShortBadgeConfig(
          label: 'Talent',
          icon: Icons.emoji_events_outlined,
          color: colors.purple,
        );

      case ShortContentModes.learn:
        return _ShortBadgeConfig(
          label: 'Learn',
          icon: Icons.school_outlined,
          color: colors.blue,
        );

      default:
        return _ShortBadgeConfig(
          label: 'Short',
          icon: Icons.play_arrow_rounded,
          color: colors.primary,
        );
    }
  }
}
