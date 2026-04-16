import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/live/presentation/screens/go_live_screen.dart';
import 'package:africaonlinestores/features/live/presentation/screens/live_screen.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/error_listener.dart';

class LiveRoutes {
  const LiveRoutes._();

  static List<GoRoute> routes() => [
    // Chat list
    GoRoute(
      name: AppRoutes.nLiveRoom,
      path: AppRoutes.liveRoom,
      builder: (_, _) => const LiveScreen(),
    ),

    GoRoute(
      name: AppRoutes.nGoLive,
      path: AppRoutes.goLive,
      builder: (_, _) => const ErrorListener(child: GoLiveScreen()),
    ),
  ];
}

class LiveNavigation {
  const LiveNavigation._();

  static void toGoLiveScreen(BuildContext context) {
    context.pushNamed(AppRoutes.nGoLive);
  }
}
