import 'package:africaonlinestores/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_controller.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_screen.dart';
import 'package:africaonlinestores/features/ads/ads_seller/my_ads_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_details_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_list_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/home_search_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/marketing_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/photography_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/ranking_tips_screen.dart';

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
        final args = state.extra as AllAdsArgs?;

        return AllAdsScreen(
          parentCategoryId: args?.parentCategoryId ?? '',
          initialCategoryId: args?.initialCategoryId,
          mode: args?.mode ?? AllAdsMode.normal,
        );
      },
    ),

    GoRoute(
      name: AppRoutes.nAdDetails,
      path: AppRoutes.adDetails,
      builder: (context, state) => AdDetailsScreen(id: _param(state, 'id')),
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
      builder: (_, _) => const MyAdsScreen(),
    ),
  ];

  /// ---------------------------
  /// Helpers
  /// ---------------------------

  static String _param(GoRouterState state, String key) =>
      Uri.decodeComponent(state.pathParameters[key] ?? '');
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
