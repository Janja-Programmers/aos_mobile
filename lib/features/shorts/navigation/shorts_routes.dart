import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/shorts/application/screens/post_short/post_short_screen.dart';
import 'package:africaonlinestores/features/shorts/application/screens/shorts/shorts_screen.dart';

class ShortsRoutes {
  const ShortsRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes];

  static final List<GoRoute> _publicRoutes = [
    // ───────────── SHORTS FEED ─────────────
    GoRoute(
      name: AppRoutes.nShorts,
      path: AppRoutes.shorts,
      builder: (context, state) => const ShortsScreen(),
    ),

    // ───────────── CREATE SHORT ─────────────
    GoRoute(
      name: AppRoutes.nCreateShort,
      path: AppRoutes.createShort,
      builder: (context, state) => const PostShortScreen(),
    ),
  ];
}

class ShortsNavigation {
  const ShortsNavigation._();

  // ───────────── OPEN FEED ─────────────

  static void toShorts(BuildContext context) {
    context.pushNamed(AppRoutes.nShorts);
  }

  // ───────────── CREATE SHORT ─────────────

  static Future<void> toCreateShort(BuildContext context) {
    return context.pushNamed(AppRoutes.nCreateShort);
  }
}
