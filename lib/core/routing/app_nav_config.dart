import 'package:africaonlinestores/core/routing/app_nav_item.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class AppNavConfig {
  const AppNavConfig._();

  static List<AppNavItem> items(BuildContext context) {
    final l10n = context.l10n;

    return [
      AppNavItem(
        label: l10n.nav_home,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        routeName: AppRoutes.nHome,
        destinationPath: AppRoutes.home,
        activePathPrefixes: const [
          AppRoutes.categories,
          AppRoutes.allAds,
          AppRoutes.adList,
          '/ads/detail',
          AppRoutes.photoTips,
          AppRoutes.marketTips,
          AppRoutes.rankTips,
        ],
      ),
      const AppNavItem(
        label: 'Feed',
        icon: Icons.play_circle_outlined,
        activeIcon: Icons.play_circle,
        routeName: AppRoutes.nFeeds,
        destinationPath: AppRoutes.feeds,
        activePathPrefixes: ['/shorts'],
      ),
      const AppNavItem(
        label: 'Post',
        icon: Icons.add,
        activeIcon: Icons.add,
        routeName: AppRoutes.nStartSelling,
        destinationPath: AppRoutes.startSelling,
        activePathPrefixes: [
          AppRoutes.startSelling,
          AppRoutes.myAds,
          '/ads/edit',
          AppRoutes.createAd,
          AppRoutes.selectCategory,
          AppRoutes.selectLocation,
          AppRoutes.sellerTips,
        ],
        requiresAuth: true,
      ),
      const AppNavItem(
        label: 'Connect',
        icon: Icons.contact_phone_outlined,
        activeIcon: Icons.contact_phone,
        routeName: AppRoutes.nConnect,
        destinationPath: AppRoutes.connect,
        activePathPrefixes: [AppRoutes.connect, '/chats', '/calls'],
        requiresAuth: true,
        behavior: AppNavBehavior.push,
      ),
      AppNavItem(
        label: l10n.nav_account,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        routeName: AppRoutes.nAccount,
        destinationPath: AppRoutes.account,
        activePathPrefixes: const [AppRoutes.account],
      ),
    ];
  }

  static int indexForLocation(BuildContext context, String location) {
    final items = AppNavConfig.items(context);
    final index = items.indexWhere((item) => item.matchesLocation(location));
    return index < 0 ? 0 : index;
  }
}
