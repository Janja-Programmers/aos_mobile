import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/components/ad_card.dart';
import 'package:africaonlinestores/features/home/components/section_header.dart';

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
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: SectionHeader(title: title, onSeeAll: onSeeAll),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final ad = items[i];
              return AdCard(
                ad: ad,
                onTap: () => context.pushNamed(
                  AppRoutes.nAdDetails,
                  pathParameters: {'id': ad.id},
                ),
              );
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }
}
