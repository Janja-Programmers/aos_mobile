import 'package:africaonlinestores/features/home/components/home_brand_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

import 'package:africaonlinestores/features/home/components/home_categories_preview_section.dart';
import 'package:africaonlinestores/features/home/components/home_hero_carousel_section.dart';
import 'package:africaonlinestores/features/home/components/home_horizontal_ads_section.dart';
import 'package:africaonlinestores/features/home/components/home_ranking_tips_section.dart';
import 'package:africaonlinestores/features/home/components/home_grid_ads_section.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Content body for the Home (Ads list) screen.
///
/// This is a sliver-based scroll view so we can compose the page from small
/// reusable "sections".
class AdListContentView extends ConsumerWidget {
  const AdListContentView({
    super.key,
    required this.items,
    required this.country,
    required this.search,
    required this.locationLabel,
    required this.onTapLocation,
    required this.onLoadMore,
    required this.onRefresh,
    required this.loadingMore,
    required this.hasMore,
  });

  final List<AOSAdListItem> items;
  final String country;
  final Widget search;
  final String locationLabel;
  final VoidCallback onTapLocation;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final bool loadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the same incoming ads list to populate multiple rails.
    // Later, these can be backed by dedicated endpoints (popular/hot/new...)
    final popular = items.take(8).toList();
    // final hot = items.skip(4).take(8).toList();
    final nearYou = items.skip(10).take(8).toList();
    final homeAccessories = items.skip(2).take(8).toList();
    final healthBeauty = items.skip(6).take(8).toList();
    final babyKids = items.skip(12).take(8).toList();

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
            PinnedHeaderSliver(child: search),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: HomeHeroCarouselSection(),
            ),

            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: HomeCategoriesPreviewSection(limit: 4),
            ),

            HomeHorizontalAdsSection(title: 'Flash Sales', items: popular),

            GridAdsSection(title: 'New Products', items: nearYou),

            HomeHorizontalAdsSection(title: 'Deals', items: popular),

            const HomeRankingTipsSection(),

            HomeHorizontalAdsSection(
              title: 'Home Accessories',
              items: homeAccessories,
            ),

            HomeHorizontalAdsSection(
              title: 'Health & Beauty',
              items: healthBeauty,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: HomeBrandSection(
                  promos: const [
                    HomePromoItem(
                      title: 'Top Deals',
                      subtitle: 'Best Prices',
                      ctaText: 'Shop Now',
                    ),
                    HomePromoItem(
                      title: 'New Arrivals',
                      subtitle: 'Fresh Picks',
                      ctaText: 'Explore',
                    ),
                    HomePromoItem(
                      title: 'Hot Discounts',
                      subtitle: 'Limited Time',
                      ctaText: 'Grab Now',
                    ),
                  ],
                  categories: [
                    HomeCategoryItem(
                      title: 'Electronics',
                      icon: Icons.desktop_windows_outlined,
                      onTapTrailing: () {},
                    ),
                    HomeCategoryItem(
                      title: 'Fashion',
                      icon: Icons.checkroom_outlined,
                      onTapTrailing: () {},
                    ),
                    HomeCategoryItem(
                      title: 'Home &\nGarden',
                      icon: Icons.home_outlined,
                      onTapTrailing: () {},
                    ),
                  ],
                ),
              ),
            ),

            HomeHorizontalAdsSection(title: 'Top Category', items: popular),

            HomeHorizontalAdsSection(title: 'Popular Category', items: popular),

            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: HomeHeroCarouselSection(),
            ),

            HomeHorizontalAdsSection(title: 'Baby & Kids', items: babyKids),

            SliverPadding(
              padding: const EdgeInsets.only(top: 6),
              sliver: GridAdsSection(items: items, title: 'Discover more'),
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
