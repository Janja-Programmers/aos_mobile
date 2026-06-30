import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:africaonlinestores/core/config/app_config.dart';

class AOSMap extends StatelessWidget {
  const AOSMap({
    super.key,
    required this.onMapCreated,
    this.onStyleLoaded,
    this.onCameraMove,
    this.onCameraIdle,
    this.initialTarget = const LatLng(-1.286389, 36.817223),
    this.initialZoom = 11,
    this.myLocationEnabled = true,
  });

  final void Function(MapLibreMapController controller) onMapCreated;
  final VoidCallback? onStyleLoaded;
  final void Function(CameraPosition position)? onCameraMove;
  final VoidCallback? onCameraIdle;
  final LatLng initialTarget;
  final double initialZoom;
  final bool myLocationEnabled;

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: AppConfig.mapStyleUrl,
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: initialZoom,
      ),
      onMapCreated: onMapCreated,
      onStyleLoadedCallback: onStyleLoaded,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      myLocationEnabled: myLocationEnabled,
      myLocationTrackingMode: MyLocationTrackingMode.none,
      compassEnabled: true,
      trackCameraPosition: true,
    );
  }
}
