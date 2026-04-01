import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_controller_provider.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
// import 'package:africaonlinestores/features/ads/ads_all/presentation/sheets/filter_sheet.dart';
// import 'package:africaonlinestores/features/ads/ads_all/presentation/sheets/sort_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/category_pills.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/deals_pills.dart';
// import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/view_toggle_bar.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/sticky_header_delegate.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';

import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_list.dart';

class AllAdsScreen extends ConsumerWidget {
  const AllAdsScreen({
    super.key,
    required this.parentCategoryId,
    this.initialCategoryId,
    this.dealType = DealType.all,
    this.sort,
    this.showPills = true,
    this.bannerUrl,
    this.mode = AllAdsMode.normal,
  });

  final String? parentCategoryId;
  final String? initialCategoryId;
  final DealType dealType;
  final AdsSort? sort;
  final bool showPills;
  final String? bannerUrl;
  final AllAdsMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = AllAdsParams(
      parentCategoryId: parentCategoryId,
      initialCategoryId: initialCategoryId,
      dealType: dealType,
      sort: sort,
      mode: mode,
    );

    final state = ref.watch(allAdsControllerProvider(params));
    final controller = ref.read(allAdsControllerProvider(params).notifier);

    // final isWishlist = mode == AllAdsMode.wishlist;

    // final canShowCategoryPills =
    //     showPills && state.children.isNotEmpty && !isWishlist;

    // final showDealsRow = !isWishlist && dealType != DealType.all;

    final title = _resolveTitle();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          slivers: [
            /// 1️⃣ TITLE
            SliverAppBar(
              backgroundColor: context.appColors.surface,
              pinned: true,
              floating: false,
              centerTitle: false,
              elevation: 0,
              title: Text(title, style: context.h5),

              actions: [
                IconButton(
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                  color: context.appColors.primary,
                  icon: Icon(
                    Icons.search,
                    color: context.appColors.textPrimary,
                    size: 23,
                  ),
                  onPressed: () => SearchNavigation.toSearchscreen(context),
                ),
                const SizedBox(width: 8),
              ],
            ),

            /// 2️⃣ DEALS PILLS
            // if (showDealsRow)
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                height: 42,
                child: DealsPills(
                  selected: state.selectedDealType,
                  onSelect: controller.setDealType,
                ),
              ),
            ),

            /// 3️⃣ CATEGORY PILLS
            // if (canShowCategoryPills)
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                height: 42,
                child: CategoryPills(
                  children: state.children,
                  selectedId: state.selectedCategoryId,
                  onSelect: controller.setCategory,
                  parentLabel: parentCategoryId,
                ),
              ),
            ),

            /// 4️⃣ SORT / FILTER ROW
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: StickyHeaderDelegate(
            //     height: 56,
            //     child: ViewToggleBar(
            //       view: state.view,
            //       onToggle: controller.toggleView,
            //       onSort: () => showSortSheet(context),
            //       onFilter: () => showFilterSheet(context),
            //     ),
            //   ),
            // ),

            /// CONTENT
            _buildContent(state, context),

            if (state.loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _resolveTitle() {
    if (mode == AllAdsMode.wishlist) {
      return 'My Wishlist';
    }

    if (dealType != DealType.all) {
      return dealType.label;
    }

    if (parentCategoryId != null && parentCategoryId!.isNotEmpty) {
      return parentCategoryId!;
    }

    return 'All Ads';
  }

  Widget _buildContent(AllAdsState state, BuildContext context) {
    if (state.loading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            "No Ads for selected category and type",
            style: context.bodyStrong,
          ),
        ),
      );
    }

    if (state.view == ViewMode.grid) {
      final width = MediaQuery.of(context).size.width;

      double aspectRatio;

      if (width < 360) {
        aspectRatio = 0.58;
      } else {
        aspectRatio = 0.8;
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          delegate: SliverChildBuilderDelegate((context, i) {
            final ad = state.items[i];
            return AdGridCard(
              ad: ad,
              onTap: () => AdNavigation.toDetail(context, ad.id),
            );
          }, childCount: state.items.length),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      sliver: SliverList.separated(
        itemBuilder: (context, i) {
          final ad = state.items[i];
          return AdListItem(
            ad: ad,
            onTap: () => AdNavigation.toDetail(context, ad.id),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: state.items.length,
      ),
    );
  }
}
