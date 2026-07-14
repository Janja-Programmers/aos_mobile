import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/ads/ads_listing/configs/ad_listing_empty_config.dart';
import 'package:africaonlinestores/features/ads/ads_listing/controllers/ad_listing_controller.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_content.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/sections/ad_listing_empty.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/widgets/ad_listing_tabs.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/widgets/fix_issue_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/home/presentation/sections/ads_error.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        queryParameters: {
          if (draftId != null && draftId.trim().isNotEmpty)
            'draftId': draftId.trim(),
          if (adId != null && adId.trim().isNotEmpty) 'adId': adId.trim(),
        },
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
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: AdListErrorView(
                message: state.error!,
                onRetry: controller.reload,
              ),
            ),
          ],
        );
      }

      if (state.items.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: AdListingEmptyView(
                title: AdListingEmptyConfig.title(state.selectedTab),
                description: AdListingEmptyConfig.description(
                  state.selectedTab,
                ),
                primaryLabel: AdListingEmptyConfig.primaryLabel(
                  state.selectedTab,
                ),
                onPrimaryAction: () async {
                  await openCreateOrEdit();
                },
                onLearnMore: () => context.pushNamed(AppRoutes.nSellerTips),
              ),
            ),
          ],
        );
      }

      return AdListingContentView(
        items: state.items,
        tab: state.selectedTab,
        onDelete: controller.deleteListing,
        onEdit: (ad) async {
          if (state.selectedTab == AdTab.drafts) {
            await openCreateOrEdit(draftId: ad.id);
            return;
          }

          if (state.selectedTab == AdTab.declined) {
            final changed = await showFixIssueSheet(
              context: context,
              ref: ref,
              ad: ad,
              onEdit: () => AdNavigation.toReducedEditListing(
                context,
                adId: ad.id,
              ),
            );
            if (changed) await refreshAfterReturn();
            return;
          }

          final changed = await AdNavigation.toReducedEditListing(
            context,
            adId: ad.id,
          );
          if (changed ?? false) await refreshAfterReturn();
        },
        onMarkAvailable: controller.markAvailable,
        onRenew: controller.renew,
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

          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshAll,
              child: buildBody(),
            ),
          ),
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
