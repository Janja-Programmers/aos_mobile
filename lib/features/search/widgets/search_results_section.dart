import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/search/widgets/search_empty_state.dart';

import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class SearchResultsSection extends StatelessWidget {
  const SearchResultsSection({
    super.key,
    required this.loading,
    required this.error,
    required this.items,
    required this.onTapItem,
    this.visualSearchTitle,
    this.visualSearchSubtitle,
    this.onClearVisualSearch,
  });

  final bool loading;
  final String? error;
  final List<AOSAdListItem> items;
  final ValueChanged<String> onTapItem;
  final String? visualSearchTitle;
  final String? visualSearchSubtitle;
  final VoidCallback? onClearVisualSearch;

  bool get _isVisualSearch => visualSearchTitle != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (_isVisualSearch) ...[
          _VisualSearchCard(
            title: visualSearchTitle!,
            subtitle:
                visualSearchSubtitle ??
                (loading ? "Searching similar products..." : ""),
            onClear: onClearVisualSearch,
          ),
          const SizedBox(height: 8),
        ],

        if (loading)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else if (items.isEmpty)
          const SearchEmptyState()
        else
          SectionCard(
            child: GridView.builder(
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
          ),
      ],
    );
  }
}

class _VisualSearchCard extends StatelessWidget {
  const _VisualSearchCard({
    required this.title,
    required this.subtitle,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.image_search_outlined, color: colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.p.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.p.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close, color: colors.error),
              style: IconButton.styleFrom(
                backgroundColor: colors.error.withOpacity(0.10),
              ),
            ),
        ],
      ),
    );
  }
}
