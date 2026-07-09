import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/activity/presentation/screens/activity_center_screen.dart';
import 'package:go_router/go_router.dart';

class ActivityRoutes {
  const ActivityRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nActivityCenter,
        path: AppRoutes.activityCenter,
        builder: (context, state) => const ActivityCenterScreen(),
      ),
    ];
  }
}
