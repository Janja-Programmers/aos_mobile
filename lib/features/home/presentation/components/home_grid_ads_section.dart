import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/features/home/presentation/components/section_header.dart';

class GridAdsSection extends StatelessWidget {
  const GridAdsSection({
    super.key,
    required this.title,
    required this.items,
    required this.onSeeAll,
    this.isService = false,
  });

  final String title;
  final List<AOSAdListItem> items;
  final VoidCallback onSeeAll;
  final bool isService;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double aspectRatio;

    if (width < 360) {
      aspectRatio = 0.58;
    } else {
      aspectRatio = isService ? 0.78 : 0.8;
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(title: title, onSeeAll: onSeeAll),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final ad = items[i];

              return AdGridCard(
                ad: ad,
                onTap: () => AdNavigation.toDetail(context, ad.id),
              );
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }
}
