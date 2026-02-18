import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/marketing_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/photography_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/sections/tips/ranking_tips_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_details_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_list_screen.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_screen.dart';
import 'package:africaonlinestores/features/home/presentation/screens/home_search_screen.dart';

class HomeRoutes {
  const HomeRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nHome,
        path: AppRoutes.home,
        builder: (context, state) => const AdListScreen(),
      ),

      GoRoute(
        name: AppRoutes.nAdList,
        path: AppRoutes.adList,
        builder: (context, state) => const AdListScreen(),
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
        builder: (context, state) => const HomeSearchScreen(),
      ),

      GoRoute(
        name: AppRoutes.nAdDetails,
        path: AppRoutes.adDetails, // /ads/details/:id
        builder: (context, state) {
          final raw = state.pathParameters['id'] ?? '';
          final id = Uri.decodeComponent(raw);
          return AdDetailsScreen(id: id);
        },
      ),

      // ✅ more specific dynamic route FIRST
      GoRoute(
        name: AppRoutes.nAllAds,
        path: AppRoutes.allAds, // /ads/all/:categoryId
        builder: (context, state) {
          final raw = state.pathParameters['categoryId'] ?? '';
          final categoryId = Uri.decodeComponent(raw);

          final showPills = state.uri.queryParameters['pills'] != '0';
          final initialRaw = state.uri.queryParameters['selected'];
          final banner = state.uri.queryParameters['banner'];

          final initial = (initialRaw ?? '').trim().isEmpty
              ? null
              : Uri.decodeComponent(initialRaw!.trim());

          return AllAdsScreen(
            parentCategoryId: categoryId,
            initialCategoryId: initial,
            showPills: showPills,
            bannerUrl: (banner ?? '').trim().isEmpty ? null : banner,
          );
        },
      ),
    ];
  }
}
