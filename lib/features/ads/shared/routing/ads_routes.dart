import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/ads/ads_create/create_ad_flow_screen.dart';
import 'package:africaonlinestores/features/ads/ads_seller/my_ads_screen.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_category_screen.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_details_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_list_screen.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_screen.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

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
      builder: (context, state) =>
          AllAdsScreen(parentCategoryId: _param(state, 'categoryId')),
    ),

    GoRoute(
      name: AppRoutes.nAdDetails,
      path: AppRoutes.adDetails,
      builder: (context, state) => AdDetailsScreen(id: _param(state, 'id')),
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

    GoRoute(
      name: AppRoutes.nCreateAd,
      path: AppRoutes.createAd,
      builder: (_, _) => const CreateAdFlowScreen(),
    ),

    GoRoute(
      name: AppRoutes.nSelectCategory,
      path: AppRoutes.selectCategory,
      builder: (context, state) => SelectCategoryScreen(
        parent: state.extra is CategoryNode
            ? state.extra as CategoryNode
            : null,
      ),
    ),

    GoRoute(
      name: AppRoutes.nSelectLocation,
      path: AppRoutes.selectLocation,
      builder: (_, _) => const SelectLocationScreen(),
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
