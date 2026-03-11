import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/features/search/widgets/search_empty_state.dart';

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

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final ad = items[i];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTapItem(ad.id),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: AdGridCard(ad: ad, onTap: () => onTapItem(ad.id)),
            ),
          ),
        );
      },
    );
  }
}
