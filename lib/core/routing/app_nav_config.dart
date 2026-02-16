import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/core/routing/app_nav_item.dart';

class AppNavConfig {
  static const items = [
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      routeName: AppRoutes.nHome,
    ),
    AppNavItem(
      label: 'Categories',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      routeName: AppRoutes.nCategories,
    ),
    AppNavItem(
      label: 'Selling',
      icon: Icons.add,
      activeIcon: Icons.add,
      routeName: AppRoutes.nMyAds,
      requiresAuth: true,
    ),
    AppNavItem(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      routeName: AppRoutes.nHome,
    ),
    AppNavItem(
      label: 'Account',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      routeName: AppRoutes.nAccount,
    ),
  ];
}
