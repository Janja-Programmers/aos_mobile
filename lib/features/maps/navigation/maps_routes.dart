import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/maps/presentation/screens/map_picker_screen.dart';
import 'package:africaonlinestores/features/maps/presentation/screens/maps_explorer_screen.dart';

class MapsRoutes {
  const MapsRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nMaps,
        path: AppRoutes.maps,
        builder: (context, state) {
          return MapsExplorerScreen(
            initialSellerId: state.uri.queryParameters['seller'],
          );
        },
      ),
      GoRoute(
        name: AppRoutes.nMapPicker,
        path: AppRoutes.mapPicker,
        builder: (context, state) {
          final extra = state.extra;
          return MapPickerScreen(
            title: state.uri.queryParameters['title'] ?? 'Choose location',
            initialPlace: extra is AOSPlace ? extra : null,
          );
        },
      ),
    ];
  }
}
