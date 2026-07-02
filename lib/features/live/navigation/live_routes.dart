import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/live/presentation/screens/go_live_screen.dart';
import 'package:africaonlinestores/features/live/presentation/screens/live_screen.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/error_listener.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveRoutes {
  const LiveRoutes._();

  static List<GoRoute> routes() => [
    // JOINLIVE Screen
    GoRoute(
      name: AppRoutes.nLiveRoom,
      path: AppRoutes.liveRoom,
      builder: (_, state) {
        final liveId = state.uri.queryParameters['live_id'] ?? '';

        return LiveScreen(liveId: liveId);
      },
    ),

    // GOLIVE Screen
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

  static void toLiveRoom(BuildContext context, {required String liveId}) {
    context.pushNamed(
      AppRoutes.nLiveRoom,
      queryParameters: {'live_id': liveId},
    );
  }
}
