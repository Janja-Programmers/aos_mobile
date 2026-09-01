import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/ads_sort_filter_sheets.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_ads_provider.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerProductsSection extends ConsumerWidget {
  const SellerProductsSection({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerAdsProvider(sellerId));
    final controller = ref.read(sellerAdsProvider(sellerId).notifier);
    final hasDiscoverySelection =
        state.selectedSort != null || state.hasFilters;
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardAspectRatio = width < 360 || textScale > 1.3 ? 0.58 : 0.78;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Products', style: context.h6),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All Items',
                  selected: !hasDiscoverySelection,
                  onTap: controller.resetSortAndFilters,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: state.selectedSort == null
                      ? 'Sort by'
                      : adsSortLabel(state.selectedSort),
                  selected: state.selectedSort != null,
                  showArrow: true,
                  onTap: () => showAdsSortSheet(
                    context,
                    selectedSort: state.selectedSort,
                    onChanged: controller.setSortType,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Filter',
                  selected: state.hasFilters,
                  showArrow: true,
                  onTap: () => showAdsFilterSheet(
                    context,
                    initialPriceMin: state.filterMinPrice,
                    initialPriceMax: state.filterMaxPrice,
                    initialRatingMin: state.filterMinRating,
                    initialVerifiedSellers: false,
                    showVerifiedSellerFilter: false,
                    onApply: controller.applyFilters,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (state.loading && state.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.items.isEmpty)
            _ProductsFailure(
              message: state.error!,
              onRetry: () => unawaited(controller.refresh()),
            )
          else if (state.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No products found')),
            )
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: cardAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final ad = state.items[i];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AdGridCard(
                    ad: ad,
                    onTap: () => AdNavigation.toDetail(context, ad.id),
                  ),
                );
              },
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              _ProductsFailure(
                message: state.error!,
                onRetry: () => unawaited(controller.load()),
              ),
            ] else if (state.hasMore) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: state.loadingMore
                      ? null
                      : () => unawaited(controller.load()),
                  child: state.loadingMore
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load more'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.selected = false,
    this.showArrow = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.p.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : colors.textPrimary,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: selected ? Colors.white : colors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsFailure extends StatelessWidget {
  const _ProductsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: context.pMuted),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
