import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/ads_all/all_ads_controller.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_state.dart';
import 'package:africaonlinestores/features/ads/ads_all/sheets/filter_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_all/sheets/sort_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_all/widget/category_pills.dart';
import 'package:africaonlinestores/features/ads/ads_all/widget/view_toggle_bar.dart';
import 'package:africaonlinestores/features/ads/ads_all/widget/ad_list_tile.dart';
import 'package:africaonlinestores/features/ads/ads_all/widget/sticky_header_delegate.dart';

import 'package:africaonlinestores/features/home/presentation/components/ad_card.dart';

class AllAdsScreen extends ConsumerWidget {
  const AllAdsScreen({
    super.key,
    required this.parentCategoryId,
    this.initialCategoryId,
    this.showPills = true,
    this.bannerUrl,
  });

  final String parentCategoryId;
  final String? initialCategoryId;
  final bool showPills;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      allAdsControllerProvider(AllAdsArgs(parentCategoryId, initialCategoryId)),
    );

    final controller = ref.read(
      allAdsControllerProvider(
        AllAdsArgs(parentCategoryId, initialCategoryId),
      ).notifier,
    );

    final canShowPills = showPills && state.children.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          slivers: [
            /// 🔥 Sticky App Bar
            const SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              title: Text('All Ads'),
            ),

            /// 🔥 Sticky Pills
            if (canShowPills)
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  height: 52,
                  child: CategoryPills(
                    children: state.children,
                    selectedId: state.selectedCategoryId,
                    onSelect: controller.setCategory,
                  ),
                ),
              ),

            /// 🔥 Sticky Sort / Filter Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                height: 56,
                child: ViewToggleBar(
                  view: state.view,
                  onToggle: controller.toggleView,
                  onSort: () => showSortSheet(context),
                  onFilter: () => showFilterSheet(context),
                ),
              ),
            ),

            /// 🔥 Content
            _buildContent(state, context),

            /// Pagination loader
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

  Widget _buildContent(AllAdsState state, BuildContext context) {
    /// Initial loading
    if (state.loading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    /// Error
    if (state.error != null && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(state.error!)),
      );
    }

    /// Grid View
    if (state.view == ViewMode.grid) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          delegate: SliverChildBuilderDelegate((context, i) {
            final ad = state.items[i];
            return AdCard(ad: ad, onTap: () {});
          }, childCount: state.items.length),
        ),
      );
    }

    /// List View
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: SliverList.separated(
        itemBuilder: (context, i) {
          final ad = state.items[i];
          return AdListTile(ad: ad, onTap: () {});
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: state.items.length,
      ),
    );
  }
}
