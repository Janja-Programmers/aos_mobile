import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/seller/presentation/sections/seller_about_section.dart';
import 'package:africaonlinestores/features/seller/presentation/sections/seller_products_section.dart';
import 'package:africaonlinestores/features/seller/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/seller/presentation/sections/seller_header_section.dart';
import 'package:africaonlinestores/features/seller/providers/seller_ads_provider.dart';

import 'package:africaonlinestores/shared/components/buttons/ad_detail_action_buttons.dart';

class SellerStorefrontScreen extends ConsumerWidget {
  const SellerStorefrontScreen({super.key, required this.sellerId});
  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerStateProvider(sellerId));
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Seller Storefront"),
        actions: [
          PopupMenuButton<int>(
            color: colors.surface,
            icon: const Icon(Icons.menu),
            onSelected: (index) => AppNavigation.goTo(context, ref, index),
            itemBuilder: (context) {
              final items = AppNavConfig.items(context);
              final location = GoRouterState.of(context).matchedLocation;

              return List.generate(items.length, (i) {
                final item = items[i];
                final isActive = location.contains(item.routeName);

                return PopupMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        color: isActive
                            ? context.appColors.primary
                            : context.appColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: context.p.copyWith(
                          color: isActive
                              ? context.appColors.primary
                              : context.appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),

      body: Builder(
        builder: (_) {
          if (state.loading && state.seller == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.seller == null) {
            return Center(child: Text(state.error!));
          }

          final seller = state.seller;

          if (seller == null) {
            return const Center(child: Text('Seller not found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(sellerStateProvider(sellerId).notifier).load();
              ref.invalidate(sellerAdsProvider(sellerId));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
          );
        },
      ),

      bottomNavigationBar: AdDetailActionBar(onCall: () {}, onMessage: () {}),
    );
  }
}
