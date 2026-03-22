import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/seller/presentation/sections/seller_about_section.dart';
import 'package:africaonlinestores/features/seller/presentation/sections/seller_products_section.dart';
import 'package:africaonlinestores/features/seller/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/seller/presentation/sections/seller_header_section.dart';

import 'package:africaonlinestores/shared/components/buttons/ad_detail_action_buttons.dart';

class SellerStorefrontScreen extends ConsumerWidget {
  const SellerStorefrontScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerStateProvider(sellerId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Seller Storefront"),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),

      body: Builder(
        builder: (_) {
          /// 🔄 LOADING
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          final seller = state.seller;

          /// ⚠️ SAFETY
          if (seller == null) {
            return const Center(child: Text('Seller not found'));
          }

          /// ✅ DATA
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SellerHeaderSection(seller: seller, sellerId: sellerId),
                    const SizedBox(height: 12),

                    SellerAboutSection(about: seller.aboutShop),
                    const SizedBox(height: 16),

                    SellerProductsSection(sellerId: sellerId),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AdDetailActionBar(onCall: () {}, onMessage: () {}),
    );
  }
}
