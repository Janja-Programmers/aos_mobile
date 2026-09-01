import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class FeedCategoryOption {
  final String id;
  final IconData icon;
  final String? contentMode;

  const FeedCategoryOption({
    required this.id,
    required this.icon,
    this.contentMode,
  });

  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (id) {
      'shop' => l10n.feedCategoryShop,
      'geo' => l10n.feedCategoryGeo,
      'vibes' => l10n.feedCategoryVibes,
      'learn' => l10n.feedCategoryLearn,
      _ => l10n.feedCategoryAll,
    };
  }
}

const List<FeedCategoryOption> feedCategoryOptions = [
  FeedCategoryOption(id: 'all', icon: Icons.grid_view_rounded),
  FeedCategoryOption(
    id: 'shop',
    icon: Icons.shopping_bag_outlined,
    contentMode: ShortContentModes.shop,
  ),
  FeedCategoryOption(
    id: 'geo',
    icon: Icons.public_outlined,
    contentMode: ShortContentModes.geo,
  ),
  FeedCategoryOption(
    id: 'vibes',
    icon: Icons.emoji_events_outlined,
    contentMode: ShortContentModes.vibes,
  ),
  FeedCategoryOption(
    id: 'learn',
    icon: Icons.school_outlined,
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

  Color _selectedColor(BuildContext context, FeedCategoryOption option) {
    final colors = context.appColors;

    return switch (option.id) {
      'geo' => Colors.green,
      'vibes' => Colors.purple,
      'learn' => Colors.blue,
      _ => colors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 2.0).toDouble();
    final height = 42.0 + ((textScale - 1.0) * 12.0);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: feedCategoryOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = feedCategoryOptions[index];
          final isSelected = option.id == selectedId;
          final label = option.label(context);
          final selectedColor = _selectedColor(context, option);

          return Semantics(
            button: true,
            selected: isSelected,
            label: label,
            child: Material(
              color: isSelected ? selectedColor : colors.surface,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? selectedColor : colors.border,
                ),
              ),
              child: InkWell(
                onTap: () => onSelected(option),
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        option.icon,
                        size: 15,
                        color: isSelected ? colors.white : colors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.small.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? colors.white : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
