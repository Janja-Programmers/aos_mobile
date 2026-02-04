import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/components/ad_card.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Popular products section (title row + grid of ad cards).
class HomePopularAdsSection extends StatelessWidget {
  const HomePopularAdsSection({
    super.key,
    required this.items,
    required this.country,
  });

  final List<AOSAdListItem> items;
  final String country;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [Text('Discover more on AOS', style: context.h5)],
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
