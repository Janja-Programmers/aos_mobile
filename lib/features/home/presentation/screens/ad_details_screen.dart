import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';

import 'package:africaonlinestores/features/home/presentation/controller/ad_detail_controller.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_detail_action_buttons.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_seller_store_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ads_header_info_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/product_detail_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/grid_ads_section.dart';
import 'package:africaonlinestores/features/home/shared/providers/similar_ads_provider.dart';
import 'package:africaonlinestores/features/reviews/controllers/review_controller.dart';
import 'package:africaonlinestores/features/reviews/presentation/review_ad_section.dart';

import 'package:africaonlinestores/features/seller/data/seller_provider.dart';

import 'package:africaonlinestores/shared/components/app_search_bar.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  const AdDetailsScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  final _searchCtrl = TextEditingController();

  int _selectedImage = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adAsync = ref.watch(adDetailsControllerProvider(widget.id));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: const BackButton(),
        title: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: AppSearchBar(
              readOnly: true,
              controller: _searchCtrl,
              onTap: () => context.pushNamed(AppRoutes.nSearch),
              onMicTap: () => context.pushNamed(AppRoutes.nSearch),
              onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            color: colors.surface,
            icon: const Icon(Icons.menu),
            onSelected: (index) => AppNavigation.goTo(context, ref, index),
            itemBuilder: (context) {
              final items = AppNavConfig.items(context);
              final location = GoRouterState.of(context).matchedLocation;

              return List.generate(items.length, (i) {
                final item = items[i];
                final isActive = location.contains(item.routeName);

                return PopupMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        color: isActive
                            ? context.appColors.primary
                            : context.appColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: context.p.copyWith(
                          color: isActive
                              ? context.appColors.primary
                              : context.appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),

      body: adAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (ad) {
          final sellerAsync = ref.watch(sellerProfileProvider(ad.sellerId));
          final similarAsync = ref.watch(similarAdsProvider(ad.categoryName));
          final reviewsAsync = ref.watch(reviewsProvider(ad.id));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    /// MEDIA SECTION
                    ImageHeaderSection(
                      images: ad.images,
                      videoUrl: ad.video,
                      selected: _selectedImage,
                      onSelect: (i) => setState(() => _selectedImage = i),
                    ),

                    const SizedBox(height: 12),

                    /// HEADER SECTION
                    AdHeaderInfoSection(
                      colorsPrimary: colors.primary,
                      locationName: ad.locationName,
                      country: ad.country,
                      title: ad.title,
                      currentPrice: ad.currentPrice,
                      priceUnit: ad.priceUnit,
                    ),

                    const SizedBox(height: 12),

                    /// DESCRIPTION / SPECS
                    AdProductDetailsSection(
                      description: ad.description,
                      specs: ad.specs,
                    ),

                    const SizedBox(height: 12),

                    /// REVIEWS SECTION
                    reviewsAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, _) => const SizedBox(),
                      data: (reviews) {
                        if (reviews.isEmpty) return const SizedBox();

                        return ReviewAdSection(
                          reviews: reviews,
                          totalReviews: reviews.length,
                          adId: ad.id,
                        );
                      },
                    ),

                    /// SELLER SECTION
                    sellerAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox(),
                      data: (seller) {
                        return AdSellerInfoSection(
                          shopName: seller.shopName,
                          avatar: seller.avatar,
                          rating: seller.rating,
                          totalReviews: seller.totalReviews,
                          totalFollowers: seller.totalFollowers,
                          totalAds: seller.totalAds,
                          joined: seller.joined,
                          isFollowing: seller.isFollowing,

                          onVisitStore: () {
                            context.pushNamed(
                              AppRoutes.nSeller,
                              pathParameters: {'sellerId': ad.sellerId},
                            );
                          },

                          onReview: () {
                            context.pushNamed(
                              AppRoutes.nCreateReview,
                              queryParameters: {'adId': ad.id},
                            );
                          },

                          onReport: () => AdNavigation.toReport(context, ad.id),
                          onPostSimilar: () {},
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// SIMILAR PRODUCTS
                    similarAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (items) {
                        if (items.isEmpty) return const SizedBox.shrink();

                        return GridAdsSectionBox(
                          title: "Similar Products",
                          items: items.where((e) => e.id != ad.id).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              /// ACTION BAR
              AdDetailActionBar(onCall: () {}, onMessage: () {}),
            ],
          );
        },
      ),
    );
  }
}
