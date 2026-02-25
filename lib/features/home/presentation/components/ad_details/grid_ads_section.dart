import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';

class GridAdsSectionBox extends StatelessWidget {
  const GridAdsSectionBox({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
    this.isService = false,
  });

  final String title;
  final List<AOSAdListItem> items;
  final VoidCallback? onSeeAll;
  final bool isService;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;

    double aspectRatio;
    if (width < 360) {
      aspectRatio = 0.58;
    } else {
      aspectRatio = isService ? 0.56 : 0.62;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(child: Text(title, style: context.h5)),
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
                      style: context.p.copyWith(
                        color: context.appColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        /// Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, i) {
              final ad = items[i];
              return AdGridCard(
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
