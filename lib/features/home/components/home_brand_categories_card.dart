import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/home/components/home_brand_models.dart';

/// Right side of HomeBrandSection:
/// - dynamic category "pills/cards"
/// - uses provided models only (no catalog dependency)
class HomeBrandCategoriesCard extends StatelessWidget {
  const HomeBrandCategoriesCard({
    super.key,
    required this.items,
    this.borderRadius,
    this.onTap,
    this.padding,
  });

  final List<HomeCategoryItem> items;
  final BorderRadius? borderRadius;
  final ValueChanged<HomeCategoryItem>? onTap;

  /// Optional outer padding for the grid area.
  /// If null, defaults to a tight layout (caller controls spacing via parent).
  final EdgeInsetsGeometry? padding;

  BorderRadius get _radius => borderRadius ?? BorderRadius.circular(16);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Keep it lightweight + avoid nested scroll: parent controls scrolling
    return ClipRRect(
      borderRadius: _radius,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: _radius,
          border: Border.all(color: context.appColors.border),
        ),
        padding: padding ?? const EdgeInsets.all(10),
        child: _PillsWrap(items: items, onTap: onTap),
      ),
    );
  }
}

class _PillsWrap extends StatelessWidget {
  const _PillsWrap({required this.items, this.onTap});

  final List<HomeCategoryItem> items;
  final ValueChanged<HomeCategoryItem>? onTap;

  @override
  Widget build(BuildContext context) {
    // “Dynamic pills” layout: wraps and fills available space.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Keeps same UI even when pills exceed available height.
          // If your old design was non-scrollable, remove this scroll view.
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                _CategoryPill(
                  item: item,
                  onTap: onTap,
                  maxWidth: constraints.maxWidth,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.item, required this.maxWidth, this.onTap});

  final HomeCategoryItem item;
  final double maxWidth;
  final ValueChanged<HomeCategoryItem>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(item),
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasIcon(item))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PillIcon(icon: item.icon),
                ),
              Flexible(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasIcon(HomeCategoryItem item) {
    // Supports both IconData and String? safely
    return true;
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.icon});

  final Object? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: _buildIcon(colors),
    );
  }

  Widget _buildIcon(AppColorTokens colors) {
    // If model provides an actual IconData, render it
    if (icon is IconData) {
      return Icon(icon as IconData, size: 14, color: colors.textSecondary);
    }

    // If it’s a String (e.g. "tag", "phone", "car"), keep UI safe:
    // you can later map string->icon here without changing call sites.
    if (icon is String && (icon as String).trim().isNotEmpty) {
      return Icon(
        Icons.local_offer_outlined,
        size: 14,
        color: colors.textSecondary,
      );
    }

    return Icon(
      Icons.local_offer_outlined,
      size: 14,
      color: colors.textSecondary,
    );
  }
}
