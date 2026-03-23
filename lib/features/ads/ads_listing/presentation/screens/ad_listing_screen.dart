import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/ads_listing/configs/ad_listing_empty_config.dart';
import 'package:africaonlinestores/features/ads/ads_listing/controllers/ad_listing_controller.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_content.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_empty.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_error.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_loading.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_tabs.dart';
import 'package:go_router/go_router.dart';

class AdListingScreen extends ConsumerWidget {
  const AdListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adListingControllerProvider);
    final controller = ref.read(adListingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("My Listings")),

      body: Column(
        children: [
          AdListingTabs(
            tabs: state.tabs,
            selected: state.selectedTab,
            counts: state.counts,
            onChanged: controller.changeTab,
          ),

          Expanded(
            child: state.loading
                ? const AdListingLoadingView()
                : state.error != null
                ? AdListingErrorView(
                    message: state.error!,
                    onRetry: controller.reload,
                  )
                : state.items.isEmpty
                ? AdListingEmptyView(
                    title: AdListingEmptyConfig.title(state.selectedTab),
                    description: AdListingEmptyConfig.description(
                      state.selectedTab,
                    ),
                    primaryLabel: AdListingEmptyConfig.primaryLabel(
                      state.selectedTab,
                    ),
                    onPrimaryAction: () =>
                        context.pushNamed(AppRoutes.nCreateAd),
                    onLearnMore: () => context.pushNamed(AppRoutes.nSellerTips),
                  )
                : AdListingContentView(
                    items: state.items,
                    onEdit: (ad) {
                      final isDraft = ad.id.startsWith('DRAFT');

                      context.pushNamed(
                        AppRoutes.nCreateAd,
                        queryParameters: isDraft
                            ? {'draftId': ad.id}
                            : {'adId': ad.id},
                      );
                    },
                    onMarkSold: controller.markSold,
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.nCreateAd),
        child: const Icon(Icons.add),
      ),
    );
  }
}
