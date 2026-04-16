import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/routing/app_nav_item.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';

class AppNavConfig {
  static List<AppNavItem> items(BuildContext context) {
    final l10n = context.l10n;

    return [
      AppNavItem(
        label: l10n.nav_home,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        routeName: AppRoutes.nHome,
      ),
      AppNavItem(
        label: l10n.nav_categories,
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        routeName: AppRoutes.nCategories,
      ),
      AppNavItem(
        label: l10n.nav_selling,
        icon: Icons.add,
        activeIcon: Icons.add,
        routeName: AppRoutes.nStartSelling,
        requiresAuth: true,
      ),
      const AppNavItem(
        label: "Feeds",
        icon: Icons.play_circle_outlined,
        activeIcon: Icons.play_circle_outlined,
        routeName: AppRoutes.nFeeds,
      ),
      AppNavItem(
        label: l10n.nav_account,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        routeName: AppRoutes.nAccount,
      ),
    ];
  }
}
