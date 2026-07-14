import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/ads/ads_all/presentation/screens/all_ads_screen.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/reduced_edit_listing_screen.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/screens/ad_listing_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_list_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/marketing_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/photography_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/ranking_tips_screen.dart';
import 'package:africaonlinestores/features/sellers/presentation/selling_tips_screen.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:africaonlinestores/shared/utils/parse_sort.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdsRoutes {
  const AdsRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes, ..._sellerRoutes];

  /// ---------------------------
  /// Public Browsing
  /// ---------------------------

  static final List<GoRoute> _publicRoutes = [
    GoRoute(
      name: AppRoutes.nHome,
      path: AppRoutes.home,
      builder: (_, _) => const AdListScreen(),
    ),

    GoRoute(
      name: AppRoutes.nAllAds,
      path: AppRoutes.allAds,
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['category'];

        final dealTypeParam = state.uri.queryParameters['promotion_type'];

        final sortParam = state.uri.queryParameters['sort'];

        final dealType = DealTypeX.fromString(dealTypeParam);

        final sort = parseSort(sortParam);

        final mode = state.uri.queryParameters['mode'] == 'wishlist'
            ? AllAdsMode.wishlist
            : AllAdsMode.normal;

        return AllAdsScreen(
          parentCategoryId: categoryId,
          initialCategoryId: categoryId,
          mode: mode,
          dealType: dealType,
          sort: sort,
        );
      },
    ),

    GoRoute(
      name: AppRoutes.nPhotoTips,
      path: AppRoutes.photoTips,
      builder: (context, state) => const PhotographyTipsScreen(),
    ),

    GoRoute(
      name: AppRoutes.nMarketTips,
      path: AppRoutes.marketTips,
      builder: (context, state) => const MarketingTipsScreen(),
    ),

    GoRoute(
      name: AppRoutes.nRankTips,
      path: AppRoutes.rankTips,
      builder: (context, state) => const RankingTipsScreen(),
    ),
  ];

  /// ---------------------------
  /// Seller Flow
  /// ---------------------------

  static final List<GoRoute> _sellerRoutes = [
    GoRoute(
      name: AppRoutes.nMyAds,
      path: AppRoutes.myAds,
      builder: (_, _) => const AdListingScreen(),
    ),

    GoRoute(
      name: AppRoutes.nEditListing,
      path: AppRoutes.editListing,
      builder: (context, state) => ReducedEditListingScreen(
        adId: state.pathParameters['adId'] ?? '',
      ),
    ),

    GoRoute(
      name: AppRoutes.nSellerTips,
      path: AppRoutes.sellerTips,
      builder: (context, state) => const SellingTipsScreen(),
    ),
  ];
}

class AdNavigation {
  const AdNavigation._();

  static void toDetail(BuildContext context, String adId) {
    context.pushNamed(AppRoutes.nAdDetails, pathParameters: {'id': adId});
  }

  static void toCreateAd(BuildContext context) {
    context.pushNamed(AppRoutes.nCreateAd);
  }

  static void toEditAd(
    BuildContext context, {
    String? adId,
    String? draftId,
    AdStatus? status,
  }) {
    assert(
      adId != null || draftId != null,
      'toEditAd requires either adId or draftId',
    );

    context.pushNamed(
      AppRoutes.nCreateAd,
      queryParameters: {
        if (adId != null && adId.isNotEmpty) 'adId': adId,
        if (draftId != null && draftId.isNotEmpty) 'draftId': draftId,
        if (status != null) 'status': status.name,
      },
    );
  }

  static Future<bool?> toReducedEditListing(
    BuildContext context, {
    required String adId,
  }) {
    return context.pushNamed<bool>(
      AppRoutes.nEditListing,
      pathParameters: {'adId': adId},
    );
  }

  static void toMyAds(BuildContext context) {
    context.pushNamed(AppRoutes.nMyAds);
  }

  static void toAllAds(BuildContext context, String categoryId) {
    context.pushNamed(
      AppRoutes.nAllAds,
      queryParameters: {'category': categoryId},
    );
  }

  static void toWishlist(BuildContext context) {
    context.pushNamed(AppRoutes.nAllAds, queryParameters: {'mode': 'wishlist'});
  }

  static void toReportAd(BuildContext context, String adId) {
    context.pushNamed(AppRoutes.nReportAd, pathParameters: {'adId': adId});
  }
}
