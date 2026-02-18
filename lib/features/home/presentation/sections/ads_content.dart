import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

import 'package:africaonlinestores/features/home/presentation/components/home_brand_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_categories_preview_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_grid_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_hero_carousel_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_horizontal_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_ranking_tips_section.dart';

import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_sections.dart';
import 'package:africaonlinestores/features/home/shared/providers/home_section_ads_provider.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// Content body for the Home (Ads list) screen.
///
/// This is a sliver-based scroll view so we can compose the page from small
/// reusable "sections".
class AdListContentView extends ConsumerWidget {
  const AdListContentView({
    super.key,
    required this.items,
    required this.country,
    required this.locationLabel,
    required this.onTapLocation,
    required this.onLoadMore,
    required this.onRefresh,
    required this.loadingMore,
    required this.hasMore,
  });

  final List<AOSAdListItem> items;
  final String country;
  final String locationLabel;
  final VoidCallback onTapLocation;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final bool loadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the exact Home page arrangement requested, but fetch each
    // rail/grid from the backend using [homeAdsSections].
    HomeAdsSection? sectionByKey(String key) {
      for (final s in homeAdsSections) {
        if (s.key == key) return s;
      }
      return null;
    }

    // IMPORTANT: in a CustomScrollView.slivers list, the type is Widget (sliver widget),
    // not "Sliver" (that type doesn't exist).
    Widget sectionSliver(String key) {
      final s = sectionByKey(key);
      if (s == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return _HomeAdsSectionSliver(section: s);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
          onLoadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: HomeHeroCarouselSection(),
            ),

            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: HomeCategoriesPreviewSection(limit: 10),
            ),

            // ✅ Exact arrangement:
            // Flash Sales (rail)
            sectionSliver('flash_sales'),

            // New Products (grid)
            sectionSliver('new_products'),

            // Deals (rail)
            sectionSliver('deals'),

            // Ranking tips
            const HomeRankingTipsSection(),

            // Home Accessories (rail)
            sectionSliver('home_accessories'),

            // Electronics
            sectionSliver('laptops_and_computers'),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: HomeBrandSection(
                  promos: [
                    HomePromoItem(
                      title: 'Top Deals',
                      subtitle: 'Best Prices',
                      ctaText: 'Shop Now',
                      color: context.appColors.success,
                      icon: Icons.apartment,
                    ),

                    HomePromoItem(
                      title: 'New Arrivals',
                      subtitle: 'Fresh Stock',
                      ctaText: 'Shop Now',
                      color: context.appColors.warning,
                      icon: Icons.apartment,
                    ),

                    HomePromoItem(
                      title: 'Summer Sale',
                      subtitle: 'Upto 40%',
                      ctaText: 'Shop Now',
                      color: context.appColors.info,
                      icon: Icons.apartment,
                    ),
                  ],
                  categories: [
                    HomeCategoryItem(
                      title: 'Electronics',
                      icon: Icons.desktop_windows_outlined,
                      onTap: () => context.pushNamed(
                        AppRoutes.nAllAds,
                        pathParameters: {'categoryId': 'Electronics'},
                      ),
                    ),

                    HomeCategoryItem(
                      title: 'Fashion',
                      icon: Icons.checkroom_outlined,
                      onTap: () => context.pushNamed(
                        AppRoutes.nAllAds,
                        pathParameters: {'categoryId': 'Women\'s Fashion'},
                      ),
                    ),

                    HomeCategoryItem(
                      title: 'Garden Supplies',
                      icon: Icons.home_outlined,
                      onTap: () => context.pushNamed(
                        AppRoutes.nAllAds,
                        pathParameters: {'categoryId': 'Garden Supplies'},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Furniture
            sectionSliver('furniture'),

            // Health & Beauty
            sectionSliver('health_beauty'),

            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: HomeHeroCarouselSection(),
            ),

            // Fashion
            sectionSliver('fashion'),

            // Baby & Kids (rail)
            sectionSliver('baby_kids'),

            SliverPadding(
              padding: const EdgeInsets.only(top: 6),
              sliver: GridAdsSection(
                items: items,
                title: 'Discover more',
                onSeeAll: () => context.pushNamed(
                  AppRoutes.nAllAds,
                  pathParameters: {'categoryId': 'Electronics'},
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: loadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : (!hasMore && items.isNotEmpty)
                    ? Text(
                        'No more ads',
                        style: context.p.copyWith(
                          color: context.appColors.textMuted,
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
  }
}

class _HomeAdsSectionSliver extends ConsumerWidget {
  const _HomeAdsSectionSliver({required this.section});

  final HomeAdsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final req = HomeSectionAdsRequest(section: section);
    final asyncItems = ref.watch(homeSectionAdsProvider(req));

    VoidCallback? seeAllAds(BuildContext context) {
      final id = section.seeAllCategoryId;
      if (id == null || id.trim().isEmpty) return null;

      return () => context.pushNamed(
        AppRoutes.nAllAds,
        pathParameters: {'categoryId': id},
      );
    }

    final seeAll = seeAllAds(context);

    return asyncItems.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (items) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // New Products is intentionally a grid, others default to rail.
        if (section.key == 'new_products') {
          return GridAdsSection(
            title: section.title,
            items: items,
            onSeeAll: seeAll,
          );
        }

        return HomeHorizontalAdsSection(
          title: section.title,
          items: items,
          onSeeAll: seeAll,
        );
      },
    );
  }
}
