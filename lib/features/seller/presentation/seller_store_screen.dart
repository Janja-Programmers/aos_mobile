import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/seller/data/seller_provider.dart';
import 'package:africaonlinestores/features/seller/presentation/widgets/seller_bottom_bar.dart';
import 'package:africaonlinestores/features/seller/presentation/widgets/seller_header.dart';
import 'package:africaonlinestores/features/seller/presentation/widgets/seller_products_grid.dart';
import 'package:africaonlinestores/features/seller/presentation/widgets/seller_products_toolbar.dart';

class SellerStorefrontScreen extends ConsumerWidget {
  const SellerStorefrontScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerAsync = ref.watch(sellerProfileProvider(sellerId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Seller Storefront"),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),

      body: sellerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (seller) {
          return Column(
            children: [
              /// Seller header
              SellerHeaderCard(seller: seller),

              const SizedBox(height: 12),

              /// Toolbar
              const SellerProductsToolbar(),

              const SizedBox(height: 12),

              /// Products
              Expanded(child: SellerProductsGrid(sellerId: sellerId)),
            ],
          );
        },
      ),

      bottomNavigationBar: const SellerBottomBar(),
    );
  }
}
