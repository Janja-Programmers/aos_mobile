import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/ads_report/report_ad_screen.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/domain/aos_review.dart';
import 'package:africaonlinestores/features/ads/shared/ui/ad_review_create.dart';
import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';

import 'package:africaonlinestores/features/home/presentation/controller/ad_detail_controller.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_detail_action_buttons.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_seller_store_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_reviews_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ads_header_info_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/product_detail_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/grid_ads_section.dart';

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

  final List<AOSAdListItem> _similar = [];
  final bool _loadingSimilar = false;

  AOSSellerProfile? _seller;
  final bool _loadingSeller = false;

  final List<AOSReview> _reviews = [];
  final bool _loadingReviews = false;

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
              final items = AppNavConfig.items;
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
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ImageHeaderSection(
                      images: ad.images,
                      videoUrl: ad.video,
                      selected: _selectedImage,
                      onSelect: (i) => setState(() => _selectedImage = i),
                    ),

                    const SizedBox(height: 12),

                    AdHeaderInfoSection(
                      colorsPrimary: colors.primary,
                      locationName: ad.locationName,
                      country: ad.country,
                      title: ad.title,
                      currentPrice: ad.currentPrice,
                      priceUnit: ad.priceUnit,
                    ),

                    const SizedBox(height: 12),

                    AdProductDetailsSection(
                      description: ad.description,
                      specs: ad.specs,
                    ),

                    const SizedBox(height: 12),

                    if (_loadingReviews)
                      const Center(child: CircularProgressIndicator())
                    else if (_reviews.isNotEmpty)
                      AdReviewsSection(
                        reviews: _reviews,
                        totalReviews: _reviews.length,
                        onSeeAll: () {},
                      ),

                    const SizedBox(height: 12),

                    if (_loadingSeller)
                      const Center(child: CircularProgressIndicator())
                    else if (_seller != null)
                      AdSellerInfoSection(
                        shopName: _seller!.shopName,
                        avatar: _seller!.avatar,
                        rating: _seller!.rating,
                        totalReviews: _seller!.totalReviews,
                        totalFollowers: _seller!.totalFollowers,
                        totalAds: _seller!.totalAds,
                        joined: _seller!.joined,
                        isFollowing: _seller!.isFollowing,
                        onVisitStore: () {},
                        onReview: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewScreen(adId: ad.id),
                            ),
                          );
                        },
                        onReport: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportAdScreen(adId: ad.id),
                            ),
                          );
                        },
                        onPostSimilar: () {},
                      ),

                    const SizedBox(height: 12),

                    if (_loadingSimilar)
                      const Center(child: CircularProgressIndicator())
                    else
                      GridAdsSectionBox(
                        title: "Similar Products",
                        items: _similar,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              AdDetailActionBar(onCall: () {}, onMessage: () {}),
            ],
          );
        },
      ),
    );
  }
}
