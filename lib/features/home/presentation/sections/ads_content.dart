import 'package:africaonlinestores/core/routing/helpers/navigation.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_models.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_categories_preview_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_grid_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_hero_carousel_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_horizontal_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_ranking_tips_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/short_horizontal_list.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_controller.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/home/presentation/controller/shorts_home_controller.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/feeds_routes.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final shortsAsync = ref.watch(shortsHomeControllerProvider);
    final colors = context.appColors;
    final l10n = context.l10n;

    return pageAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final List<HomeAdsSection> categorySections = state.sections
            .where((HomeAdsSection section) => section.isCategorySection)
            .toList(growable: false);

        return shortsAsync.when(
          loading: () => const SizedBox(height: 220),
          error: (_, _) => const SizedBox.shrink(),
          data: (shorts) {
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
                  ref.read(homePageControllerProvider.notifier).loadMore();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  await onRefresh();
                  await ref
                      .read(shortsHomeControllerProvider.notifier)
                      .refresh();
                },
                child: CustomScrollView(
                  slivers: [
                    const HomeHeroCarouselSection(),
                    const HomeCategoriesPreviewSection(),

                    /// SHORTS SECTION
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Row(
                          children: [
                            Text('Live & Shorts', style: context.h5),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                FeedsNavigation.toFeeds(context);
                              },
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ShortsHorizontalList(shorts: shorts),
                    ),

                    /// FIXED MERCHANDISING + BACKEND CATEGORY RAILS
                    _sectionSliver(context, state, 'flash_sales'),
                    if (categorySections.isNotEmpty)
                      _sectionSliver(context, state, categorySections[0].key),
                    _sectionSliver(context, state, 'new_products'),
                    if (categorySections.length > 1)
                      _sectionSliver(context, state, categorySections[1].key),
                    _sectionSliver(context, state, 'deal'),
                    const HomeRankingTipsSection(),
                    if (categorySections.length > 2)
                      _sectionSliver(context, state, categorySections[2].key),

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
                          categories: state.selectedCategories
                              .map(
                                (CategoryNode category) => HomeCategoryItem(
                                  title: category.name,
                                  icon: Icons.category_outlined,
                                  onTap: () => openAllAds(
                                    context,
                                    categoryId: category.id,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ),
                    if (categorySections.length > 3)
                      _sectionSliver(context, state, categorySections[3].key),

                    /// HERO AGAIN
                    const HomeHeroCarouselSection(),

                    /// DISCOVER
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 6),
                      sliver: GridAdsSection(
                        items: state.discoverItems,
                        title: l10n.common_discover_more,
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
                                style: context.p.copyWith(
                                  color: colors.primary,
                                ),
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
      },
    );
  }

  Widget _sectionSliver(BuildContext context, HomePageState state, String key) {
    final List<AOSAdListItem> items =
        state.sectionItems[key] ?? const <AOSAdListItem>[];
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final HomeAdsSection section = state.sections.firstWhere(
      (HomeAdsSection item) => item.key == key,
    );

    void seeAll() {
      if (key == 'new_products') {
        openAllAds(context, sort: AdsSort.recent);
        return;
      }

      if (section.promotionType == 'flash_sale') {
        openAllAds(context, dealType: DealType.flashSale);
        return;
      }

      if (section.promotionType == 'deal') {
        openAllAds(
          context,
          categoryId: section.categoryId,
          dealType: DealType.deals,
        );
        return;
      }

      final String? categoryId = section.categoryId;
      if (categoryId != null && categoryId.isNotEmpty) {
        openAllAds(context, categoryId: categoryId);
        return;
      }

      openAllAds(context);
    }

    final String title = section.title ?? homeSectionTitle(context, key);
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
