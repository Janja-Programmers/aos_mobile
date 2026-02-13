import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/home/components/home_brand_models.dart';

class HomeBrandCategoriesCard extends StatelessWidget {
  const HomeBrandCategoriesCard({
    super.key,
    required this.items,
    this.borderRadius,
    this.padding,
    this.title = 'You might be\nlooking for',
  });

  final List<HomeCategoryItem> items;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final String title;

  BorderRadius get _radius => borderRadius ?? BorderRadius.circular(18);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (items.isEmpty) return const SizedBox.shrink();

    final shown = items.length > 3 ? items.take(3).toList() : items;

    return ClipRRect(
      borderRadius: _radius,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Scroll only inside the remaining space (prevents overflow)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    for (int i = 0; i < shown.length; i++) ...[
                      _CategoryTile(item: shown[i]),
                      if (i != shown.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item});

  final HomeCategoryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tap = item.onTap;

    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            _IconBadge(icon: item.icon, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.p.copyWith(
                  color: colors.textPrimary,
                  height: 1.0,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.size = 32});

  final Object? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final badgeBg = colors.primary.withOpacity(0.10);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
      child: _buildIcon(colors),
    );
  }

  Widget _buildIcon(AppColorTokens colors) {
    if (icon is IconData) {
      return Icon(icon as IconData, size: 18, color: colors.primary);
    }
    return Icon(Icons.category_outlined, size: 18, color: colors.primary);
  }
}
