import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';

import 'package:africaonlinestores/features/ads/ads_all/presentation/screens/all_ads_screen.dart';
import 'package:africaonlinestores/features/ads/ads_listing/presentation/screens/ad_listing_screen.dart';

import 'package:africaonlinestores/features/home/presentation/screens/ad_list_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/marketing_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/photography_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/ranking_tips_screen.dart';

import 'package:africaonlinestores/features/search/search_screen.dart';

import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

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
        final categoryId = state.uri.queryParameters['categoryId'];
        final dealTypeParam = state.uri.queryParameters['dealType'];

        final dealType = DealTypeX.fromString(dealTypeParam);

        final mode = state.uri.queryParameters['mode'] == 'wishlist'
            ? AllAdsMode.wishlist
            : AllAdsMode.normal;

        return AllAdsScreen(
          parentCategoryId: categoryId,
          initialCategoryId: categoryId,
          mode: mode,
          dealType: dealType,
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

    GoRoute(
      name: AppRoutes.nSearch,
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
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
  ];
}

class AdNavigation {
  const AdNavigation._();

  static void toDetail(BuildContext context, String adId) {
    context.pushNamed(AppRoutes.nAdDetails, pathParameters: {'id': adId});
  }

  static void toCreate(BuildContext context) {
    context.pushNamed(AppRoutes.nCreateAd);
  }

  static void toMyAds(BuildContext context) {
    context.pushNamed(AppRoutes.nMyAds);
  }

  static void toAllAds(BuildContext context, String categoryId) {
    context.pushNamed(
      AppRoutes.nAllAds,
      pathParameters: {'categoryId': categoryId},
    );
  }
}
