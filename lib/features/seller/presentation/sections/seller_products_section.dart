import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/providers/seller_ads_provider.dart';

import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class SellerProductsSection extends ConsumerWidget {
  const SellerProductsSection({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(sellerAdsProvider(sellerId));

    return SectionCard(
      title: "Products",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _FilterChip(label: 'All Items', selected: true),
              SizedBox(width: 8),
              _FilterChip(label: 'Sort by'),
              SizedBox(width: 8),
              _FilterChip(label: 'Categories'),
            ],
          ),

          const SizedBox(height: 12),

          adsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),

            error: (e, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Failed to load products')),
            ),

            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("No products yet")),
                );
              }

              return GridView.builder(
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? colors.primary.withOpacity(.15) : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? colors.primary : colors.border),
      ),
      child: Text(
        label,
        style: context.p.copyWith(
          color: selected ? colors.primary : colors.textPrimary,
        ),
      ),
    );
  }
}
