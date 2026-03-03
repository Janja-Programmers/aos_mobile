import 'package:africaonlinestores/features/home/shared/providers/marketplace_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';

import 'package:africaonlinestores/features/ads/ads_report/report_ad_screen.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/domain/aos_review.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/shared/ui/ad_review_create.dart';

import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';
import 'package:africaonlinestores/features/seller/data/seller_controller.dart';

import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_detail_action_buttons.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_seller_store_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ad_reviews_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/ads_header_info_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/product_detail_section.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/grid_ads_section.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  const AdDetailsScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  bool _loading = true;
  String? _err;

  AOSAdDetails? _ad;
  int _selectedImage = 0;

  List<AOSAdListItem> _similar = [];
  bool _loadingSimilar = false;

  AOSSellerProfile? _seller;
  bool _loadingSeller = false;

  List<AOSReview> _reviews = [];
  bool _loadingReviews = false;

  final _searchCtrl = TextEditingController();

  MarketContext? _market;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _market = await ref.read(marketContextProvider.future);
      if (mounted) {
        await _load();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // =============================
  // MAIN LOAD
  // =============================
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    final res = await ref.read(adsApiProvider).getAd(id: widget.id);
    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _loading = false;
        _err = f.message;
      }),
      (json) {
        final data = json['data'];
        final adJson = (data is Map) ? (data['item'] ?? data) : null;

        if (adJson is! Map) {
          setState(() {
            _loading = false;
            _err = 'Failed to load ad.';
          });
          return;
        }

        final ad = AOSAdDetails.fromJson(Map<String, dynamic>.from(adJson));

        final cleanImages = ad.images
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final thumbCount = cleanImages.take(4).length;
        final hasVideo = (ad.video?.trim().isNotEmpty ?? false);
        final mediaCount = thumbCount + (hasVideo ? 1 : 0);

        setState(() {
          _ad = ad;
          _loading = false;
          _selectedImage = _selectedImage.clamp(
            0,
            mediaCount > 0 ? mediaCount - 1 : 0,
          );
        });

        _loadSimilar();
        _loadSeller();
        _loadReviews();
      },
    );
  }

  // =============================
  // SIMILAR
  // =============================
  Future<void> _loadSimilar() async {
    if (_ad == null || _loadingSimilar) return;

    setState(() => _loadingSimilar = true);

    final res = await ref
        .read(adsApiProvider)
        .listAds(
          country: _market!.country,
          categoryId: _ad!.categoryName,
          limit: 7,
        );

    if (!mounted) return;

    res.fold((_) => setState(() => _loadingSimilar = false), (json) {
      final raw = json['data']?['items'];
      if (raw is List) {
        final items = raw
            .whereType<Map>()
            .map((m) => AOSAdListItem.fromJson(Map<String, dynamic>.from(m)))
            .where((x) => x.id != widget.id)
            .take(6)
            .toList();

        setState(() {
          _similar = items;
          _loadingSimilar = false;
        });
      }
    });
  }

  // =============================
  // SELLER
  // =============================
  Future<void> _loadSeller() async {
    if (_ad == null) return;

    setState(() => _loadingSeller = true);

    final sellerId = _ad!.sellerId;

    final res = await ref
        .read(sellerApiProvider)
        .getSellerProfile(sellerId: sellerId);

    if (!mounted) return;

    res.fold((_) => setState(() => _loadingSeller = false), (json) {
      final data = json['data'];
      if (data is Map) {
        setState(() {
          _seller = AOSSellerProfile.fromJson(Map<String, dynamic>.from(data));
          _loadingSeller = false;
        });
      } else {
        setState(() => _loadingSeller = false);
      }
    });
  }

  // =============================
  // REVIEWS
  // =============================
  Future<void> _loadReviews() async {
    if (_ad == null || _loadingReviews) return;

    setState(() => _loadingReviews = true);

    final res = await ref.read(adsApiProvider).getAdReviews(adId: _ad!.id);

    if (!mounted) return;

    res.fold((_) => setState(() => _loadingReviews = false), (json) {
      final raw = json['data']?['items'];
      if (raw is List) {
        final items = raw
            .whereType<Map>()
            .map((e) => AOSReview.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        setState(() {
          _reviews = items;
          _loadingReviews = false;
        });
      } else {
        setState(() => _loadingReviews = false);
      }
    });
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
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
              onSubmitted: (_) {},
              onMicTap: () => context.pushNamed(AppRoutes.nSearch),
              onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _err != null
          ? Center(child: Text(_err!))
          : _ad == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ImageHeaderSection(
                        images: _ad!.images,
                        videoUrl: _ad!.video,
                        selected: _selectedImage,
                        onSelect: (i) => setState(() => _selectedImage = i),
                      ),
                      const SizedBox(height: 12),

                      AdHeaderInfoSection(
                        colorsPrimary: colors.primary,
                        locationName: _ad!.locationName,
                        country: _ad!.country,
                        title: _ad!.title,
                        currentPrice: _ad!.currentPrice,
                        priceUnit: _ad!.priceUnit,
                      ),
                      const SizedBox(height: 12),

                      AdProductDetailsSection(
                        description: _ad!.description,
                        specs: _ad!.specs,
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
                                builder: (_) => ReviewScreen(adId: _ad!.id),
                              ),
                            );
                          },
                          onReport: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportAdScreen(adId: _ad!.id),
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
                          title: 'Similar Products',
                          items: _similar,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                AdDetailActionBar(onCall: () {}, onMessage: () {}),
              ],
            ),
    );
  }
}
