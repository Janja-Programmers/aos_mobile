import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_horizontal.dart';
import 'package:africaonlinestores/features/home/presentation/components/section_header.dart';

class HomeHorizontalAdsSection extends StatelessWidget {
  const HomeHorizontalAdsSection({
    super.key,
    required this.title,
    required this.items,
    required this.onSeeAll,
  });

  final String title;
  final List<AOSAdListItem> items;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: SectionHeader(title: title, onSeeAll: onSeeAll),
          ),

          /// Horizontal List
          SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final ad = items[index];

                return AdHorizontalCard(
                  ad: ad,
                  onTap: () => AdNavigation.toDetail(context, ad.id),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
