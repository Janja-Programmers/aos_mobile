import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';

class FeedCategoryOption {
  final String id;
  final String label;
  final IconData icon;
  final String? contentMode;

  const FeedCategoryOption({
    required this.id,
    required this.label,
    required this.icon,
    this.contentMode,
  });
}

const List<FeedCategoryOption> feedCategoryOptions = [
  FeedCategoryOption(id: 'all', label: 'All', icon: Icons.grid_view_rounded),
  FeedCategoryOption(
    id: 'shop',
    label: 'Shop',
    icon: Icons.shopping_bag_outlined,
    contentMode: ShortContentModes.shop,
  ),
  FeedCategoryOption(
    id: 'places',
    label: 'Geography',
    icon: Icons.public_outlined,
    contentMode: ShortContentModes.places,
  ),
  FeedCategoryOption(
    id: 'vibes',
    label: 'Talents',
    icon: Icons.emoji_events_outlined,
    contentMode: ShortContentModes.vibes,
  ),
  FeedCategoryOption(
    id: 'learn',
    label: 'Health & Tech',
    icon: Icons.biotech_outlined,
    contentMode: ShortContentModes.learn,
  ),
];

class FeedCategoryChips extends StatelessWidget {
  final String selectedId;
  final ValueChanged<FeedCategoryOption> onSelected;
  final EdgeInsetsGeometry padding;

  const FeedCategoryChips({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: feedCategoryOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = feedCategoryOptions[index];
          final isSelected = option.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(option),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option.icon,
                    size: option.id == 'learn' ? 13 : 15,
                    color: isSelected ? colors.white : colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    option.label,
                    style: context.small.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? colors.white : colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
