import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/utils/chart_actions.dart';

import 'package:africaonlinestores/features/home/presentation/controller/ad_detail_controller.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_seller_store_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ads_header_info_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/product_detail_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/grid_ads_section.dart';
import 'package:africaonlinestores/features/home/shared/providers/similar_ads_provider.dart';

import 'package:africaonlinestores/features/reviews/controllers/review_controller.dart';
import 'package:africaonlinestores/features/reviews/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/reviews/presentation/sections/review_ad_section.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';
import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';
import 'package:africaonlinestores/features/seller/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/seller/providers/seller_profile_provider.dart';

import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:africaonlinestores/shared/components/buttons/ad_detail_action_buttons.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

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
              onTap: () => SearchNavigation.toSearchscreen(context),
              onMicTap: () => SearchNavigation.toSearchscreen(context),
              onCameraTap: () => SearchNavigation.toSearchscreen(context),
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
          final reviewState = ref.watch(reviewControllerProvider(ad.id));
          bool isCalling = false;

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
                      rating: ad.averageRating,
                      reviewCount: ad.totalReviews,
                      currentPrice: ad.currentPrice,
                      priceUnit: ad.priceUnit,
                      priceType: ad.priceType,
                    ),

                    const SizedBox(height: 12),

                    AdProductDetailsSection(
                      description: ad.description,
                      specs: ad.specs,
                    ),

                    const SizedBox(height: 12),

                    /// ✅ FIXED: Only affect reviews section
                    if (reviewState.loading)
                      const SizedBox.shrink()
                    else if (reviewState.error != null)
                      const SizedBox.shrink()
                    else if (reviewState.reviews.isEmpty)
                      const SizedBox.shrink()
                    else
                      SectionCard(
                        child: ReviewAdSection(
                          reviews: reviewState.reviews,
                          totalReviews: reviewState.reviews.length,
                          adId: ad.id,
                        ),
                      ),

                    /// SELLER SECTION
                    sellerAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
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
                          onVisitStore: () => SellerNavigation.toSellerStore(
                            context,
                            ad.sellerId,
                          ),
                          onReview: () =>
                              ReviewNavigation.toCreateReview(context, ad.id),
                          onReport: () => AdNavigation.toReport(context, ad.id),
                          onPostSimilar: () => AdNavigation.toCreate(context),
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

                        return SectionCard(
                          child: GridAdsSectionBox(
                            title: "Similar Products",
                            items: items.where((e) => e.id != ad.id).toList(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              /// ACTION BAR
              AdDetailActionBar(
                onCall: () async {
                  if (isCalling) return;

                  isCalling = true;

                  try {
                    await AppNavigation.requireAuth(
                      context,
                      ref,
                      onAuthenticated: () async {
                        final manager = ref.read(callManagerProvider.notifier);

                        if (ad.sellerId.isEmpty) {
                          debugPrint('❌ sellerId is empty');
                          return;
                        }

                        await manager.startOutgoingCall(
                          userId: ad.sellerId,
                          callType: AOSCallType.audio,
                          receiver: _buildReceiver(ad, sellerAsync.value),
                        );
                      },
                    );
                  } finally {
                    isCalling = false;
                  }
                },

                onMessage: () {
                  AppNavigation.requireAuth(
                    context,
                    ref,
                    onAuthenticated: () {
                      final seller = sellerAsync.value;

                      ChatActions.startChat(
                        context: context,
                        ref: ref,
                        user: ad.sellerId,
                        displayName: seller!.shopName,
                        initialMessage: "Hi, I'm interested in ${ad.title}",
                        adId: ad.id,
                        adTitle: ad.title,
                        adPrice: ad.currentPrice,
                        adImage: ad.primaryImage,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

CallParticipant _buildReceiver(AOSAdDetails ad, AOSSellerProfile? seller) {
  final sellerName = seller?.shopName.trim();

  return CallParticipant(
    userId: ad.sellerId,
    displayName: sellerName != null && sellerName.isNotEmpty
        ? sellerName
        : ad.sellerId,
    avatarUrl: seller?.avatar,
  );
}
