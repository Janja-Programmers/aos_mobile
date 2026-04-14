import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/ads/ads_listing/configs/ad_listing_empty_config.dart';
import 'package:africaonlinestores/features/ads/ads_listing/controllers/ad_listing_controller.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_content.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_empty.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_error.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/widgets/ad_listing_tabs.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class AdListingScreen extends ConsumerWidget {
  const AdListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adListingControllerProvider);
    final controller = ref.read(adListingControllerProvider.notifier);

    Future<void> refreshAfterReturn() async {
      await controller.refreshAll();
    }

    Future<void> openCreateOrEdit({String? draftId, String? adId}) async {
      await context.pushNamed(
        AppRoutes.nCreateAd,
        queryParameters: {'draftId': ?draftId, 'adId': ?adId},
      );

      await refreshAfterReturn();
    }

    void onContactSupport(AOSAdListItem ad) {
      ShowSnack(
        context,
        'Support flow coming soon for "${ad.title.isEmpty ? 'this ad' : ad.title}"',
      ).info();
    }

    Widget buildBody() {
      if (state.error != null) {
        return AdListingErrorView(
          message: state.error!,
          onRetry: controller.reload,
        );
      }

      if (state.items.isEmpty) {
        return AdListingEmptyView(
          title: AdListingEmptyConfig.title(state.selectedTab),
          description: AdListingEmptyConfig.description(state.selectedTab),
          primaryLabel: AdListingEmptyConfig.primaryLabel(state.selectedTab),
          onPrimaryAction: () async {
            await openCreateOrEdit();
          },
          onLearnMore: () => context.pushNamed(AppRoutes.nSellerTips),
        );
      }

      return AdListingContentView(
        items: state.items,
        tab: state.selectedTab,
        onDelete: controller.abandonDraft,
        onEdit: (ad) async {
          final isDraft = ad.id.startsWith('DRAFT');

          await openCreateOrEdit(
            draftId: isDraft ? ad.id : null,
            adId: isDraft ? null : ad.id,
          );
        },
        onContactSupport: onContactSupport,
        onMarkSold: controller.markSold,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: Column(
        children: [
          AdListingTabs(
            tabs: state.tabs,
            selected: state.selectedTab,
            counts: state.counts,
            onChanged: controller.changeTab,
          ),

          Expanded(child: buildBody()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await openCreateOrEdit();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
