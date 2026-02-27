import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_models.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_categories_preview_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_grid_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_hero_carousel_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_horizontal_ads_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_ranking_tips_section.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/home/presentation/shimmers/home_page_skeleton.dart';
import 'package:africaonlinestores/features/home/shared/providers/home_page_providers.dart';

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

    return pageAsync.when(
      loading: () => const HomePageSkeleton(),
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
                const HomeHeroCarouselSection(),

                const HomeCategoriesPreviewSection(limit: 10),

                _sectionSliver(context, state, 'flash_sales'),
                _sectionSliver(context, state, 'new_products'),
                _sectionSliver(context, state, 'deals'),

                const HomeRankingTipsSection(),

                _sectionSliver(context, state, 'home_accessories'),
                _sectionSliver(context, state, 'laptops_and_computers'),

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

                _sectionSliver(context, state, 'furniture'),
                _sectionSliver(context, state, 'health_beauty'),

                const HomeHeroCarouselSection(),

                _sectionSliver(context, state, 'fashion'),
                _sectionSliver(context, state, 'baby_kids'),

                SliverPadding(
                  padding: const EdgeInsets.only(top: 6),
                  sliver: GridAdsSection(
                    items: state.discoverItems,
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
                    child: state.loadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : (!state.hasMore && state.discoverItems.isNotEmpty)
                        ? Text(
                            'No more ads',
                            style: context.p.copyWith(
                              color: context.appColors.primary,
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
  }

  Widget _sectionSliver(BuildContext context, HomePageState state, String key) {
    final items = state.sectionItems[key] ?? [];

    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    VoidCallback? seeAll;

    final section = state.sections.firstWhere(
      (s) => s.key == key,
      orElse: () => state.sections.first,
    );

    if (section.seeAllCategoryId != null &&
        section.seeAllCategoryId!.trim().isNotEmpty) {
      seeAll = () => context.pushNamed(
        AppRoutes.nAllAds,
        pathParameters: {'categoryId': section.seeAllCategoryId!},
      );
    }

    if (key == 'new_products') {
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
  }
}
