import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/maps/presentation/screens/map_picker_screen.dart';
import 'package:africaonlinestores/features/maps/presentation/screens/maps_explorer_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapsRoutes {
  const MapsRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nMaps,
        path: AppRoutes.maps,
        builder: (context, state) {
          final extra = state.extra;
          return MapsExplorerScreen(
            initialSellerId: state.uri.queryParameters['seller'],
            initialPlace: extra is AOSPlace ? extra : null,
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


class MapsNavigation {
  const MapsNavigation._();

  static Future<T?> toExplorer<T>(
    BuildContext context, {
    String? sellerId,
    AOSPlace? place,
  }) {
    return context.pushNamed<T>(
      AppRoutes.nMaps,
      queryParameters: {
        if (sellerId != null && sellerId.trim().isNotEmpty)
          'seller': sellerId.trim(),
      },
      extra: place,
    );
  }
}
