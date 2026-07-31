import 'dart:async';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_seller_store_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ads_header_info_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/product_detail_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/seller_location_section.dart';
import 'package:africaonlinestores/features/home/presentation/controller/ad_detail_controller.dart';
import 'package:africaonlinestores/features/home/shared/providers/similar_ads_provider.dart';
import 'package:africaonlinestores/features/reviews/application/controllers/review_controller.dart';
import 'package:africaonlinestores/features/reviews/application/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/reviews/application/state/review_state.dart';
import 'package:africaonlinestores/features/reviews/presentation/sections/review_ad_section.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_profile_provider.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:africaonlinestores/shared/components/buttons/ad_detail_action_buttons.dart';
import 'package:africaonlinestores/shared/components/cards/ad_card_horizontal.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  const AdDetailsScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<AdDetailsScreen> createState() {
    return _AdDetailsScreenState();
  }
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  int _selectedImage = 0;
  bool _isCalling = false;

  void _handleWishlistTap(AOSAdDetails ad) {
    unawaited(
      AppNavigation.requireAuth(
        context,
        ref,
        onAuthenticated: () {
          unawaited(_toggleWishlist(ad));
        },
      ),
    );
  }

  Future<void> _toggleWishlist(AOSAdDetails ad) async {
    final success = await ref
        .read(wishlistControllerProvider.notifier)
        .toggle(ad.id, currentValue: ad.isWishlisted);

    if (!success && mounted) {
      ShowSnack(context, context.l10n.wishlist_update_error).error();
    }
  }

  Future<void> _shareAd(AOSAdDetails ad) async {
    final adId = Uri.encodeComponent(ad.id.trim());
    final url = '${AppConfig.normalizedBaseUrl}/ads/detail/$adId';

    final title = ad.title.trim().isEmpty ? 'AOS ad' : ad.title.trim();

    final location = [
      ad.locationName.trim(),
      ad.country.trim(),
    ].where((value) => value.isNotEmpty).join(', ');

    final text = [
      'Check out $title on AOS.',
      if (ad.currentPrice?.trim().isNotEmpty ?? false)
        'Price: ${ad.currentPrice!.trim()}',
      if (location.isNotEmpty) 'Location: $location',
      url,
    ].join('\n');

    try {
      final renderObject = context.findRenderObject();

      final shareOrigin = renderObject is RenderBox && renderObject.hasSize
          ? renderObject.localToGlobal(Offset.zero) & renderObject.size
          : const Rect.fromLTWH(0, 0, 1, 1);

      await SharePlus.instance.share(
        ShareParams(
          title: 'Share ad',
          subject: title,
          text: text,
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ShowSnack(context, 'Unable to open share options.').error();
    }
  }

  Future<void> _openCreateReview(AOSAdDetails ad) async {
    final created = await ReviewNavigation.toCreateReview(context, ad.id);

    if (!mounted || created != true) {
      return;
    }

    // Refresh the actual review list and its summary first.
    await ref.read(reviewControllerProvider(ad.id).notifier).loadInitial();

    if (!mounted) {
      return;
    }

    // Refresh only data affected by the new review.
    // Existing data remains visible because the corresponding AsyncValue.when
    // calls use skipLoadingOnRefresh.
    ref.invalidate(adDetailsControllerProvider(ad.id));

    ref.invalidate(sellerProfileProvider(ad.sellerId));
  }

  Future<void> _startCall(AOSAdDetails ad, AOSSellerProfile? seller) async {
    if (_isCalling) {
      return;
    }

    setState(() {
      _isCalling = true;
    });

    try {
      await AppNavigation.requireAuth(
        context,
        ref,
        onAuthenticated: () async {
          await ref
              .read(callStarterServiceProvider)
              .startOutgoingCall(
                userId: seller?.effectiveUserId ?? ad.sellerId,
                callType: AOSCallType.audio,
                receiver: _buildReceiver(ad, seller),
              );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    }
  }

  void _startMessage(
    AOSAdDetails ad,
    AsyncValue<AOSSellerProfile> sellerAsync,
  ) {
    AppNavigation.requireAuth(
      context,
      ref,
      onAuthenticated: () {
        final seller = sellerAsync.value;

        if (seller == null) {
          ShowSnack(
            context,
            'Seller information is still loading. Please try again.',
          ).info();

          return;
        }

        ChatActions.startChat(
          context: context,
          ref: ref,
          user: seller.effectiveUserId,
          displayName: seller.displayName,
          initialMessage: "Hi, I'm interested in ${ad.title}",
          adId: ad.id,
          adTitle: ad.title,
          adPrice: ad.currentPrice,
          adImage: ad.primaryImage,
          adImageFileId: ad.primaryImageFileId,
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final adAsync = ref.watch(adDetailsControllerProvider(widget.id));

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
              onTap: () {
                SearchNavigation.toSearchscreen(context);
              },
              onMicTap: () {
                SearchNavigation.toSearchscreen(context);
              },
              onCameraTap: () {
                SearchNavigation.toSearchscreen(context);
              },
            ),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            color: colors.surface,
            icon: const Icon(Icons.menu),
            onSelected: (index) {
              AppNavigation.goTo(context, ref, index);
            },
            itemBuilder: (context) {
              final items = AppNavConfig.items(context);
              final location = GoRouterState.of(context).matchedLocation;

              return List.generate(items.length, (index) {
                final item = items[index];
                final isActive = item.matchesLocation(location);

                return PopupMenuItem<int>(
                  value: index,
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
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
        skipLoadingOnRefresh: true,
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, _) {
          return _MainRetryView(
            message: 'Unable to load this ad.',
            detail: error.toString(),
            onRetry: () {
              ref.invalidate(adDetailsControllerProvider(widget.id));
            },
          );
        },
        data: (ad) {
          final sellerAsync = ref.watch(sellerProfileProvider(ad.sellerId));

          final similarAsync = ref.watch(similarAdsProvider(ad.categoryName));

          final reviewState = ref.watch(reviewControllerProvider(ad.id));

          final currentUser = ref.watch(currentUserProvider);

          final isOwnAd = currentUser?.toString().trim() == ad.sellerId.trim();

          final isAuthenticated = ref.watch(isAuthenticatedProvider);

          final wishlistState = isAuthenticated
              ? ref.watch(wishlistControllerProvider)
              : null;

          final isFavorite =
              isAuthenticated &&
              (wishlistState?.resolve(ad.id, fallback: ad.isWishlisted) ??
                  ad.isWishlisted);

          final isFavoritePending =
              wishlistState?.pending.contains(ad.id) ?? false;

          final reviewSummary = reviewState.summary;

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
                      isFavorite: isFavorite,
                      isFavoritePending: isFavoritePending,
                      onSelect: (index) {
                        setState(() {
                          _selectedImage = index;
                        });
                      },
                      onShareTap: () {
                        _shareAd(ad);
                      },
                      onFavoriteTap: isFavoritePending
                          ? null
                          : () {
                              _handleWishlistTap(ad);
                            },
                    ),
                    const SizedBox(height: 12),

                    AdHeaderInfoSection(
                      colorsPrimary: colors.primary,
                      locationName: ad.locationName,
                      country: ad.country,
                      title: ad.title,
                      rating: reviewSummary?.averageRating ?? ad.averageRating,
                      reviewCount:
                          reviewSummary?.totalReviews ?? ad.totalReviews,
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

                    _ReviewsSection(
                      adId: ad.id,
                      reviewState: reviewState,
                      onRetry: () {
                        ref
                            .read(reviewControllerProvider(ad.id).notifier)
                            .loadInitial();
                      },
                    ),

                    sellerAsync.when(
                      skipLoadingOnRefresh: true,
                      loading: () {
                        return const _SectionLoadingCard();
                      },
                      error: (_, _) {
                        return _SectionRetryCard(
                          message: 'Unable to load seller information.',
                          onRetry: () {
                            ref.invalidate(sellerProfileProvider(ad.sellerId));
                          },
                        );
                      },
                      data: (seller) {
                        return Column(
                          children: [
                            AdSellerInfoSection(
                              displayName: seller.displayName,
                              avatar: seller.avatar,
                              rating: seller.rating,
                              totalReviews: seller.totalReviews,
                              totalFollowers: seller.totalFollowers,
                              totalAds: seller.totalAds,
                              joined: seller.joined,
                              isFollowing: seller.isFollowing,
                              isVerified: seller.isVerified,
                              reviewState: reviewState,
                              onVisitStore: () {
                                SellerNavigation.toSellerStore(
                                  context,
                                  ad.sellerId,
                                  seller: seller,
                                );
                              },
                              onReview: () {
                                _openCreateReview(ad);
                              },
                              onReport: () {
                                AdNavigation.toReportAd(context, ad.id);
                              },
                              onPostSimilar: () {
                                AdNavigation.toCreateAd(context);
                              },
                            ),

                            if (seller.location != null) ...[
                              const SizedBox(height: 12),
                              SellerLocationSection(
                                sellerId: ad.sellerId,
                                location: seller.location!,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    similarAsync.when(
                      skipLoadingOnRefresh: true,
                      loading: () {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      error: (_, _) {
                        return _SectionRetryCard(
                          message: 'Unable to load similar products.',
                          onRetry: () {
                            ref.invalidate(similarAdsProvider(ad.categoryName));
                          },
                        );
                      },
                      data: (items) {
                        final filteredItems = items
                            .where((item) => item.id != ad.id)
                            .toList(growable: false);

                        if (filteredItems.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return SectionCard(
                          title: 'Similar Products',
                          child: SizedBox(
                            height: 205,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return SizedBox(
                                  width: 164,
                                  child: AdHorizontalCard(
                                    ad: item,
                                    onTap: () =>
                                        AdNavigation.toDetail(context, item.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              if (!isOwnAd)
                AdDetailActionBar(
                  onCall: () {
                    _startCall(ad, sellerAsync.value);
                  },
                  onMessage: () {
                    _startMessage(ad, sellerAsync);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.adId,
    required this.reviewState,
    required this.onRetry,
  });

  final String adId;
  final ReviewState reviewState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Keep existing reviews visible while a background refresh is running.
    if (reviewState.reviews.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SectionCard(
          child: ReviewAdSection(
            reviews: reviewState.reviews,
            totalReviews:
                reviewState.summary?.totalReviews ?? reviewState.reviews.length,
            adId: adId,
          ),
        ),
      );
    }

    if (reviewState.error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SectionRetryCard(
          message: 'Unable to load reviews.',
          onRetry: onRetry,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionRetryCard extends StatelessWidget {
  const _SectionRetryCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: [
              Icon(Icons.cloud_off_outlined, color: colors.textMuted),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: context.pMuted),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainRetryView extends StatelessWidget {
  const _MainRetryView({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: context.pStrong),
            const SizedBox(height: 6),
            Text(detail, textAlign: TextAlign.center, style: context.pMuted),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

CallParticipant _buildReceiver(AOSAdDetails ad, AOSSellerProfile? seller) {
  final sellerName = seller?.displayName.trim();

  return CallParticipant(
    userId: seller?.effectiveUserId ?? ad.sellerId,
    displayName: sellerName != null && sellerName.isNotEmpty
        ? sellerName
        : ad.sellerId,
    avatarUrl: seller?.avatar,
  );
}
