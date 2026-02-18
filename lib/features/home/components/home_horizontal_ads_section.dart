import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/routing/ads_routes.dart';
import 'package:africaonlinestores/features/home/components/ad_card.dart';
import 'package:africaonlinestores/features/home/components/section_header.dart';

class HomeHorizontalAdsSection extends StatelessWidget {
  const HomeHorizontalAdsSection({
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
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── Section header ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: SectionHeader(title: title, onSeeAll: onSeeAll),
            ),

            // ───────── Horizontal rail ─────────
            LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final cardWidth = (maxW * 0.45).clamp(120.0, 260.0);
                final cardHeight = cardWidth / 0.68;

                return SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final ad = items[index];

                      return SizedBox(
                        width: cardWidth,
                        child: AdCard(
                          ad: ad,
                          onTap: () => AdNavigation.toDetail(context, ad.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
