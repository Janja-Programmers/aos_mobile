import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/home/presentation/components/section_header.dart';

import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

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
    final displayItems = items.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        const SizedBox(height: 8),

        SectionCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              final height = 190.0;

              return GridView.builder(
                itemCount: displayItems.length,

                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: width / height,
                ),

                itemBuilder: (context, i) {
                  final ad = displayItems[i];

                  return AdGridCard(
                    ad: ad,
                    onTap: () => AdNavigation.toDetail(context, ad.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
