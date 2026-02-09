import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/components/ad_card.dart';
import 'package:africaonlinestores/features/home/components/section_header.dart';

/// A titled horizontal rail of ads (Popular Products, Hot Findings, etc.)
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: SectionHeader(title: title, onSeeAll: onSeeAll),
            ),

            // ───────── Horizontal rail ─────────
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive sizing derived from screen width
                final cardWidth = constraints.maxWidth * 0.55;
                final cardHeight = cardWidth / 0.68;

                return SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final ad = items[index];

                      return SizedBox(
                        width: cardWidth,
                        child: AdCard(
                          ad: ad,
                          onTap: () =>
                              context.push(AppRoutes.adDetailsPath(ad.id)),
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
