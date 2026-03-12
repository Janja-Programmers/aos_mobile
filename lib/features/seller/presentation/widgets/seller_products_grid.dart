import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/seller/data/seller_ads_provider.dart';

class SellerProductsGrid extends ConsumerWidget {
  const SellerProductsGrid({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(sellerAdsProvider(sellerId));

    return adsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox(),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text("No products yet"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final ad = items[i];
            return AdGridCard(ad: ad, onTap: () {});
          },
        );
      },
    );
  }
}
