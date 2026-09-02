import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_controller_provider.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/ads_all_empty_screen.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/ads_sort_filter_sheets.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/category_pills.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/deals_pills.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/sticky_header_delegate.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_grid.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_list.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final isWishlist = mode == AllAdsMode.wishlist;
    final canShowCategoryPills =
        showPills && state.children.isNotEmpty && !isWishlist;
    final showDealsRow = !isWishlist && dealType != DealType.all;

    final title = _resolveTitle();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          slivers: [
            if (isWishlist)
              SliverAppBar(
                backgroundColor: context.appColors.surface,
                pinned: true,
                centerTitle: false,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: context.appColors.textPrimary,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: _WishlistSearchField(
                  initialText: state.wishlistQuery,
                  onChanged: controller.setWishlistSearch,
                ),
              )
            else
              SliverAppBar(
                backgroundColor: context.appColors.surface,
                pinned: true,
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

            if (showDealsRow)
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

            if (canShowCategoryPills)
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

            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                height: 58,
                child: _AdsToolbar(
                  selectedSort: state.selectedSort,
                  hasFilters: state.hasFilters,
                  onSort: () => showAdsSortSheet(
                    context,
                    selectedSort: state.selectedSort,
                    onChanged: controller.setSortType,
                  ),
                  onFilter: () => showAdsFilterSheet(
                    context,
                    initialPriceMin: state.filterMinPrice,
                    initialPriceMax: state.filterMaxPrice,
                    initialRatingMin: state.filterMinRating,
                    initialVerifiedSellers: state.filterVerifiedSellers,
                    showVerifiedSellerFilter: isWishlist,
                    onApply: controller.applyFilters,
                  ),
                  onToggleView: controller.toggleView,
                  view: state.view,
                ),
              ),
            ),

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

  String _emptyMessage() {
    if (mode == AllAdsMode.wishlist) {
      return 'No items in your wishlist';
    }

    if (parentCategoryId != null && parentCategoryId!.isNotEmpty) {
      return 'No items in $parentCategoryId';
    }

    if (dealType != DealType.all) {
      return 'No ${dealType.label.toLowerCase()} available';
    }

    return 'No ads found';
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
        child: AdsEmptyState(message: state.error!),
      );
    }

    if (state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AdsEmptyState(message: _emptyMessage()),
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

class _WishlistSearchField extends StatefulWidget {
  const _WishlistSearchField({
    required this.initialText,
    required this.onChanged,
  });

  final String initialText;
  final ValueChanged<String> onChanged;

  @override
  State<_WishlistSearchField> createState() => _WishlistSearchFieldState();
}

class _WishlistSearchFieldState extends State<_WishlistSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant _WishlistSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != _controller.text &&
        widget.initialText != oldWidget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: context.p.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search wishlist...',
          hintStyle: context.pMuted,
          prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted),
          filled: true,
          fillColor: colors.elevated,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _AdsToolbar extends StatelessWidget {
  const _AdsToolbar({
    required this.selectedSort,
    required this.hasFilters,
    required this.onSort,
    required this.onFilter,
    required this.onToggleView,
    required this.view,
  });

  final AdsSort? selectedSort;
  final bool hasFilters;
  final VoidCallback onSort;
  final VoidCallback onFilter;
  final VoidCallback onToggleView;
  final ViewMode view;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSort,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    adsSortLabel(selectedSort),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.primary,
                  size: 22,
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: view == ViewMode.grid ? 'List view' : 'Grid view',
            onPressed: onToggleView,
            icon: Icon(
              view == ViewMode.grid
                  ? Icons.grid_view_rounded
                  : Icons.view_agenda_outlined,
              color: colors.textMuted,
            ),
          ),
          TextButton.icon(
            onPressed: onFilter,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.tune_rounded, color: colors.textPrimary),
                if (hasFilters)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(
              'Filter',
              style: context.p.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
