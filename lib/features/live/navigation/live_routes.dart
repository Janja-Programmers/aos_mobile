import 'package:africaonlinestores/features/live/presentation/screens/live_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

class LiveRoutes {
  const LiveRoutes._();

  static List<GoRoute> routes() => [
    // Chat list
    GoRoute(
      name: AppRoutes.nLiveRoom,
      path: AppRoutes.liveRoom,
      builder: (_, _) => const LiveScreen(),
    ),
  ];
}
