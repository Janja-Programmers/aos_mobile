import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/home/presentation/components/section_header.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_horizontal.dart';

class ForYouAdsSectionBox extends StatelessWidget {
  const ForYouAdsSectionBox({
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
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SECTION HEADER
        SectionHeader(title: title, onSeeAll: onSeeAll),

        const SizedBox(height: 8),

        /// HORIZONTAL ADS LIST
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final ad = items[i];

              return AdHorizontalCard(
                ad: ad,
                onTap: () => AdNavigation.toDetail(context, ad.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
