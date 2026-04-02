import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/routing/navigation.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

import 'package:africaonlinestores/features/catalog/shared/routing/catalog_routes.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_models.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_categories_preview_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_grid_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_hero_carousel_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_horizontal_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_ranking_tips_section.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_controller.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

import 'package:africaonlinestores/shared/enums/ads_sort.dart';

class AdListContentView extends ConsumerWidget {
  const AdListContentView({
    super.key,
    required this.onTapLocation,
    required this.onRefresh,
  });

  final VoidCallback onTapLocation;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(homePageControllerProvider);
    final colors = context.appColors;
    final l10n = context.l10n;

    return pageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
              ref.read(homePageControllerProvider.notifier).loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              slivers: [
                /// HERO
                const HomeHeroCarouselSection(),

                /// CATEGORY PREVIEW
                const HomeCategoriesPreviewSection(limit: 10),

                /// FLASH SALES
                _sectionSliver(context, state, 'flash_sales'),

                /// SERVICES
                _sectionSliver(context, state, 'services'),

                /// NEW PRODUCTS
                _sectionSliver(context, state, 'new_products'),

                /// ELECTRONIC DEALS
                _sectionSliver(context, state, 'electronic_deal'),

                /// DEALS
                _sectionSliver(context, state, 'deal'),

                /// RANKING TIPS
                const HomeRankingTipsSection(),

                /// FURNITURE
                _sectionSliver(context, state, 'furniture'),

                /// ELECTRONICS
                _sectionSliver(context, state, 'electronics'),

                /// BRAND SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: HomeBrandSection(
                      promos: [
                        HomePromoItem(
                          title: l10n.home_top_deals,
                          subtitle: l10n.home_best_prices,
                          ctaText: l10n.home_shop_now,
                          color: colors.success,
                          icon: Icons.apartment,
                        ),
                        HomePromoItem(
                          title: 'New Arrivals',
                          subtitle: 'Fresh Stock',
                          ctaText: l10n.home_shop_now,
                          color: colors.warning,
                          icon: Icons.apartment,
                        ),
                        HomePromoItem(
                          title: 'Summer Sale',
                          subtitle: 'Upto 40%',
                          ctaText: l10n.home_shop_now,
                          color: colors.info,
                          icon: Icons.apartment,
                        ),
                      ],
                      categories: [
                        HomeCategoryItem(
                          title: l10n.home_electronics,
                          icon: Icons.desktop_windows_outlined,
                          onTap: () =>
                              openAllAds(context, categoryId: 'Electronics'),
                        ),
                        HomeCategoryItem(
                          title: l10n.home_fashion,
                          icon: Icons.checkroom_outlined,
                          onTap: () => openAllAds(
                            context,
                            categoryId: "Women's Fashion",
                          ),
                        ),
                        HomeCategoryItem(
                          title: 'Garden Supplies',
                          icon: Icons.home_outlined,
                          onTap: () => openAllAds(
                            context,
                            categoryId: 'Garden Supplies',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// FASHION
                _sectionSliver(context, state, 'fashion'),

                /// BABIES & KIDS
                _sectionSliver(context, state, 'kids'),

                /// HERO AGAIN
                const HomeHeroCarouselSection(),

                /// BEAUTY
                _sectionSliver(context, state, 'beauty'),

                /// DISCOVER
                SliverPadding(
                  padding: const EdgeInsets.only(top: 6),
                  sliver: GridAdsSection(
                    items: state.discoverItems,
                    title: l10n.common_discover_more,
                    onSeeAll: () => CatalogNavigation.toAllCategories(context),
                  ),
                ),

                /// PAGINATION FOOTER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: state.loadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : (!state.hasMore && state.discoverItems.isNotEmpty)
                        ? Text(
                            l10n.ads_no_more_ads,
                            style: context.p.copyWith(color: colors.primary),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionSliver(BuildContext context, HomePageState state, String key) {
    final items = state.sectionItems[key] ?? [];

    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final section = state.sections.firstWhere(
      (s) => s.key == key,
      orElse: () => state.sections.first,
    );

    void seeAll() {
      final category = (section.preferredCategoryNames.isNotEmpty)
          ? section.preferredCategoryNames.first
          : null;

      final promotion = section.promotionType;

      // 🔥 PRIORITY ORDER MATTERS

      if (key == 'new_products') {
        openAllAds(context, sort: AdsSort.recent);
        return;
      }

      if (promotion == 'flash_sale') {
        openAllAds(context, dealType: DealType.flashSale);
        return;
      }

      if (promotion == 'deal') {
        openAllAds(context, categoryId: category, dealType: DealType.deals);
        return;
      }

      if (category != null) {
        openAllAds(context, categoryId: category);
      } else {
        openAllAds(context);
      }
    }

    final title = homeSectionTitle(context, key);

    if (key == 'new_products') {
      return GridAdsSection(title: title, items: items, onSeeAll: seeAll);
    }

    return HomeHorizontalAdsSection(
      title: title,
      items: items,
      onSeeAll: seeAll,
    );
  }
}
