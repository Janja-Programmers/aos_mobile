import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/shorts/feeds/screens/feed_screen.dart';

class FeedsRoutes {
  const FeedsRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes];

  static final List<GoRoute> _publicRoutes = [
    // ───────────── FEED ─────────────
    GoRoute(
      name: AppRoutes.nFeeds,
      path: AppRoutes.feeds,
      builder: (context, state) => const FeedScreen(),
    ),
  ];
}

class FeedsNavigation {
  const FeedsNavigation._();

  // ───────────── OPEN FEED ─────────────

  static void toFeeds(BuildContext context) {
    context.pushNamed(AppRoutes.nFeeds);
  }
}
