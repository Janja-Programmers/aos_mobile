import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/search/widgets/search_empty_state.dart';

import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';

class SearchResultsSection extends StatelessWidget {
  const SearchResultsSection({
    super.key,
    required this.loading,
    required this.error,
    required this.items,
    required this.onTapItem,
  });

  final bool loading;
  final String? error;
  final List<AOSAdListItem> items;
  final ValueChanged<String> onTapItem;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          error!,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.error, fontWeight: FontWeight.w600),
        ),
      );
    }

    if (items.isEmpty) {
      return const SearchEmptyState();
    }
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) {
              final ad = items[i];
              return AdGridCard(
                ad: ad,
                onTap: () => AdNavigation.toDetail(context, ad.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
