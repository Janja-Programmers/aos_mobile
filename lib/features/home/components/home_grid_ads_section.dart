import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/components/ad_card.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Popular products section (title row + grid of ad cards).
class GridAdsSection extends StatelessWidget {
  const GridAdsSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
  });

  final String title;
  final List<AOSAdListItem> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.h5.copyWith(color: colors.primary),
                  ),
                ),

                if (onSeeAll != null)
                  InkWell(
                    onTap: onSeeAll,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text(
                        'See all',
                        style: context.p.copyWith(color: colors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              // ✅ Taller tiles -> more room for title/subtitle/price
              // Old: 0.75 (too short)
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final ad = items[i];
              return AdCard(
                ad: ad,
                onTap: () => context.push(AppRoutes.adDetailsPath(ad.id)),
              );
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }
}
