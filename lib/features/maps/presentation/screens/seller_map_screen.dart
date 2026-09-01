// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/location/location_service.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/polyline6_decoder.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/maps/data/maps_api.dart';
import 'package:africaonlinestores/features/maps/data/seller_maps_api.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/maps/domain/aos_route.dart';
import 'package:africaonlinestores/features/maps/domain/seller_location_response.dart';
import 'package:africaonlinestores/features/maps/domain/seller_map_point.dart';
import 'package:africaonlinestores/features/maps/presentation/widgets/maplibre_platform_chrome.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_profile_provider.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class SellerMapScreen extends ConsumerStatefulWidget {
  const SellerMapScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<SellerMapScreen> createState() => _SellerMapScreenState();
}

class _SellerMapScreenState extends ConsumerState<SellerMapScreen> {
  static const double _offRouteThresholdMeters = 85;
  static const Duration _rerouteCooldown = Duration(seconds: 12);
  static const double _arrivalMeters = 35;

  late final MapsApi _mapsApi;
  late final SellerMapsApi _sellerMapsApi;
  final FlutterTts _tts = FlutterTts();

  MapLibreMapController? _map;
  SellerLocationResponse? _locationResponse;
  AOSRoute? _route;
  List<LatLng> _routePoints = const [];
  List<SellerMapPoint> _nearbyPoints = const [];
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;
  DateTime? _lastRerouteAt;
  int _maneuverIndex = 0;
  bool _loadingLocation = true;
  bool _routeLoading = false;
  bool _navigating = false;
  bool _showSteps = false;
  bool _showNearby = false;
  bool _voiceEnabled = true;
  bool _rerouting = false;
  final Set<int> _spokenManeuvers = <int>{};

  AOSPlace? get _destination => _locationResponse?.location;

  @override
  void initState() {
    super.initState();
    _mapsApi = ref.read(mapsApiProvider);
    _sellerMapsApi = ref.read(sellerMapsApiProvider);
    unawaited(_loadLocation());
  }

  @override
  void dispose() {
    _map?.onCircleTapped.remove(_handleNearbyCircleTap);
    unawaited(_positionSubscription?.cancel());
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final result = await _sellerMapsApi.getSellerLocation(
      seller: widget.sellerId,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _loadingLocation = false);
        ShowSnack(context, failure.message).error();
      },
      (response) {
        setState(() {
          _locationResponse = response;
          _loadingLocation = false;
        });
      },
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _map?.onCircleTapped.remove(_handleNearbyCircleTap);
    _map = controller;
    controller.onCircleTapped.add(_handleNearbyCircleTap);
  }

  void _handleNearbyCircleTap(Circle circle) {
    if (!_showNearby || _navigating) return;

    final geometry = circle.options.geometry;
    if (geometry == null) return;

    SellerMapPoint? matched;
    for (final point in _nearbyPoints) {
      final sameLatitude =
          (point.latitude - geometry.latitude).abs() < 0.0000001;
      final sameLongitude =
          (point.longitude - geometry.longitude).abs() < 0.0000001;
      if (sameLatitude && sameLongitude) {
        matched = point;
        break;
      }
    }

    if (matched is SellerPinPoint) {
      final sellerId = matched.seller.trim();
      if (sellerId.isNotEmpty && mounted) {
        SellerNavigation.toSellerStore(context, sellerId);
      }
      return;
    }

    if (matched is SellerClusterPoint) {
      unawaited(_map?.animateCamera(CameraUpdate.newLatLngZoom(geometry, 16)));
    }
  }

  Future<void> _locateMe() async {
    try {
      final position = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );
      if (!mounted) return;
      final current = LatLng(position.latitude, position.longitude);
      setState(() => _currentLocation = current);
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(current, 16));
    } on LocationServiceException catch (error) {
      if (mounted) ShowSnack(context, error.message).error();
    }
  }

  Future<void> _toggleNearby() async {
    final next = !_showNearby;
    setState(() => _showNearby = next);
    if (!next) {
      _nearbyPoints = const [];
      await _redrawNearby();
      return;
    }
    await _loadNearbyPoints();
  }

  Future<void> _loadNearbyPoints() async {
    final map = _map;
    if (map == null || !_showNearby || _navigating) return;
    final bounds = await map.getVisibleRegion();
    const zoom = 14;
    final result = await _sellerMapsApi.listSellerMapPoints(
      south: bounds.southwest.latitude,
      north: bounds.northeast.latitude,
      west: bounds.southwest.longitude,
      east: bounds.northeast.longitude,
      zoom: zoom,
    );
    if (!mounted) return;
    result.fold((_) {}, (items) {
      _nearbyPoints = items;
      unawaited(_redrawNearby());
    });
  }

  Future<void> _redrawNearby() async {
    final map = _map;
    if (map == null) return;
    await map.clearCircles();
    if (!_showNearby || _navigating) return;
    for (final point in _nearbyPoints) {
      final radius = point is SellerClusterPoint ? 16.0 : 9.0;
      await map.addCircle(
        CircleOptions(
          geometry: LatLng(point.latitude, point.longitude),
          circleRadius: radius,
          circleColor: _hexColor(context.appColors.primary),
          circleOpacity: .88,
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF',
        ),
      );
    }
  }

  Future<void> _startDirections() async {
    if (_routeLoading || _navigating) return;
    final destination = _destination;
    if (destination == null || !destination.hasLocation) return;

    setState(() => _routeLoading = true);
    try {
      final position = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );
      if (!mounted) return;
      final current = LatLng(position.latitude, position.longitude);
      final result = await _mapsApi.getRouteToSeller(
        originLatitude: current.latitude,
        originLongitude: current.longitude,
        destinationSeller: widget.sellerId,
      );
      if (!mounted) return;
      await result.fold<Future<void>>(
        (failure) async {
          ShowSnack(context, failure.message).error();
        },
        (route) async {
          setState(() {
            _currentLocation = current;
            _route = route;
            _routePoints = _decodeRoute(route);
            _maneuverIndex = 0;
            _navigating = true;
            _showNearby = false;
            _nearbyPoints = const [];
            _spokenManeuvers.clear();
          });
          await _redrawNearby();
          await _drawRoute();
          await _updateNavigation(current, forceSpeak: true);
          await _positionSubscription?.cancel();
          _positionSubscription = LocationService.getNavigationPositionStream()
              .listen(
                (position) => unawaited(_handleNavigationPosition(position)),
                onError: (Object error) {
                  if (mounted) ShowSnack(context, error.toString()).error();
                },
              );
        },
      );
    } on LocationServiceException catch (error) {
      if (mounted) ShowSnack(context, error.message).error();
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  Future<void> _handleNavigationPosition(Position position) async {
    if (!mounted || !_navigating) return;
    final current = LatLng(position.latitude, position.longitude);
    setState(() => _currentLocation = current);
    await _map?.animateCamera(CameraUpdate.newLatLng(current));
    await _updateNavigation(current);
  }

  Future<void> _updateNavigation(
    LatLng current, {
    bool forceSpeak = false,
  }) async {
    final route = _route;
    if (route == null || _routePoints.isEmpty) return;

    final destination = _routePoints.last;
    final remaining = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      destination.latitude,
      destination.longitude,
    );
    if (remaining <= _arrivalMeters) {
      await _stopNavigation(clearRoute: true);
      if (mounted) ShowSnack(context, 'You have arrived.').success();
      return;
    }

    final nearest = _nearestRoutePoint(current);
    final maneuvers = route.maneuvers;
    final nextIndex = _maneuverForShapeIndex(maneuvers, nearest.index);
    if (mounted) setState(() => _maneuverIndex = nextIndex);
    await _speakManeuver(nextIndex, force: forceSpeak);

    if (nearest.distanceMeters > _offRouteThresholdMeters) {
      await _reroute(current);
    }
  }

  Future<void> _reroute(LatLng current) async {
    if (_rerouting) return;
    final now = DateTime.now();
    if (_lastRerouteAt != null &&
        now.difference(_lastRerouteAt!) < _rerouteCooldown) {
      return;
    }
    _lastRerouteAt = now;
    if (mounted) setState(() => _rerouting = true);

    final result = await _mapsApi.refreshRouteToSeller(
      currentLatitude: current.latitude,
      currentLongitude: current.longitude,
      destinationSeller: widget.sellerId,
    );
    if (!mounted) return;
    await result.fold<Future<void>>(
      (failure) async {
        ShowSnack(context, failure.message).error();
      },
      (route) async {
        setState(() {
          _route = route;
          _routePoints = _decodeRoute(route);
          _maneuverIndex = 0;
          _spokenManeuvers.clear();
        });
        await _drawRoute();
        await _speak('Rerouting');
      },
    );
    if (mounted) setState(() => _rerouting = false);
  }

  Future<void> _drawRoute() async {
    final map = _map;
    if (map == null) return;
    await map.clearLines();
    if (_routePoints.isEmpty) return;
    await map.addLine(
      LineOptions(
        geometry: _routePoints,
        lineColor: _hexColor(context.appColors.primary),
        lineWidth: 6,
        lineOpacity: .92,
      ),
    );
    if (_currentLocation != null) {
      await map.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 16.5),
      );
    }
  }

  Future<void> _stopNavigation({bool clearRoute = false}) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _navigating = false;
      _showSteps = false;
      _maneuverIndex = 0;
      _spokenManeuvers.clear();
      if (clearRoute) {
        _route = null;
        _routePoints = const [];
      }
    });
    if (clearRoute) await _map?.clearLines();
  }

  Future<void> _speakManeuver(int index, {bool force = false}) async {
    if (!_voiceEnabled || !_navigating) return;
    final maneuvers = _route?.maneuvers ?? const <AOSRouteManeuver>[];
    if (maneuvers.isEmpty) return;
    final safeIndex = index.clamp(0, maneuvers.length - 1);
    if (!force && _spokenManeuvers.contains(safeIndex)) return;
    _spokenManeuvers.add(safeIndex);
    await _speak(maneuvers[safeIndex].bestVoiceText);
  }

  Future<void> _speak(String text) async {
    if (!_voiceEnabled || text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text.trim());
  }

  List<LatLng> _decodeRoute(AOSRoute route) {
    final shape = route.firstShape;
    if (shape == null || shape.isEmpty) return const [];
    return Polyline6Decoder.decode(shape);
  }

  _NearestPoint _nearestRoutePoint(LatLng current) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var index = 0; index < _routePoints.length; index++) {
      final point = _routePoints[index];
      final distance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = index;
      }
    }
    return _NearestPoint(index: bestIndex, distanceMeters: bestDistance);
  }

  int _maneuverForShapeIndex(List<AOSRouteManeuver> maneuvers, int shapeIndex) {
    if (maneuvers.isEmpty) return 0;
    for (var index = 0; index < maneuvers.length; index++) {
      final maneuver = maneuvers[index];
      final end = maneuver.endShapeIndex;
      if (end != null && shapeIndex <= end) return index;
    }
    return maneuvers.length - 1;
  }

  String _distanceAway(AOSPlace destination) {
    final current = _currentLocation;
    if (current == null) return '';
    final meters = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      destination.latitude,
      destination.longitude,
    );
    if (meters < 1000) return '${meters.round()} m away';
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sellerAsync = ref.watch(sellerProfileProvider(widget.sellerId));
    final destination = _destination;

    if (_loadingLocation || sellerAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return sellerAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _UnavailableMap(onBack: () => context.pop()),
      data: (seller) {
        if (destination == null || !destination.hasLocation) {
          return _UnavailableMap(onBack: () => context.pop());
        }
        final target = LatLng(destination.latitude, destination.longitude);
        final maneuvers = _route?.maneuvers ?? const <AOSRouteManeuver>[];
        final activeManeuver = maneuvers.isEmpty
            ? null
            : maneuvers[_maneuverIndex.clamp(0, maneuvers.length - 1)];
        final avatar = buildFileUrl(seller.avatar);

        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Back',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.shortLabel.isNotEmpty
                                  ? destination.shortLabel
                                  : seller.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.h5.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              destination.locality ??
                                  destination.displayAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.smallMuted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_currentLocation == null)
                        IconButton.filledTonal(
                          tooltip: 'Use my location',
                          onPressed: () => unawaited(_locateMe()),
                          icon: Icon(
                            Icons.my_location_rounded,
                            color: colors.primary,
                          ),
                        )
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            child: Text(
                              _distanceAway(destination),
                              style: context.small.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: MapLibreMap(
                              styleString: AppConfig.mapStyleUrl,
                              initialCameraPosition: CameraPosition(
                                target: target,
                                zoom: 14,
                              ),
                              myLocationEnabled: true,
                              trackCameraPosition: true,
                              attributionButtonMargins:
                                  aosMapAttributionButtonMargins,
                              onMapCreated: _onMapCreated,
                              onStyleLoadedCallback: () {
                                unawaited(_drawRoute());
                                unawaited(_redrawNearby());
                              },
                              onCameraIdle: () =>
                                  unawaited(_loadNearbyPoints()),
                            ),
                          ),
                          Center(
                            child: IgnorePointer(
                              child: Icon(
                                Icons.location_pin,
                                size: 48,
                                color: colors.primary,
                              ),
                            ),
                          ),
                          if (!_navigating)
                            PositionedDirectional(
                              top: 12,
                              start: 12,
                              child: OutlinedButton.icon(
                                onPressed: () => unawaited(_toggleNearby()),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: _showNearby
                                      ? colors.primary
                                      : colors.surface,
                                  foregroundColor: _showNearby
                                      ? colors.white
                                      : colors.textPrimary,
                                  side: BorderSide(
                                    color: _showNearby
                                        ? colors.primary
                                        : colors.border,
                                  ),
                                ),
                                icon: const Icon(Icons.layers_outlined),
                                label: const Text('Nearby sellers'),
                              ),
                            ),
                          PositionedDirectional(
                            top: 12,
                            end: 12,
                            child: Column(
                              children: [
                                _MapControl(
                                  icon: Icons.add_rounded,
                                  tooltip: 'Zoom in',
                                  onTap: () => unawaited(
                                    _map?.animateCamera(CameraUpdate.zoomIn()),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _MapControl(
                                  icon: Icons.remove_rounded,
                                  tooltip: 'Zoom out',
                                  onTap: () => unawaited(
                                    _map?.animateCamera(CameraUpdate.zoomOut()),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _MapControl(
                                  icon: Icons.navigation_rounded,
                                  tooltip: 'Use my location',
                                  onTap: () => unawaited(_locateMe()),
                                ),
                              ],
                            ),
                          ),
                          if (_navigating && activeManeuver != null)
                            PositionedDirectional(
                              top: 12,
                              start: 12,
                              end: 84,
                              child: _NavigationInstruction(
                                maneuver: activeManeuver,
                                rerouting: _rerouting,
                                voiceEnabled: _voiceEnabled,
                                onVoice: () {
                                  setState(
                                    () => _voiceEnabled = !_voiceEnabled,
                                  );
                                  if (!_voiceEnabled) {
                                    unawaited(_tts.stop());
                                  } else {
                                    unawaited(
                                      _speakManeuver(
                                        _maneuverIndex,
                                        force: true,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          PositionedDirectional(
                            start: 12,
                            end: 12,
                            bottom: 12,
                            child: _SellerRouteCard(
                              sellerName: seller.displayName,
                              verified: seller.isVerified,
                              avatar: avatar,
                              address: destination.displayAddress,
                              route: _route,
                              navigating: _navigating,
                              routeLoading: _routeLoading,
                              showSteps: _showSteps,
                              maneuvers: maneuvers,
                              onDirections: () => unawaited(_startDirections()),
                              onEnd: () =>
                                  unawaited(_stopNavigation(clearRoute: true)),
                              onToggleSteps: () {
                                setState(() => _showSteps = !_showSteps);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SellerRouteCard extends StatelessWidget {
  const _SellerRouteCard({
    required this.sellerName,
    required this.verified,
    required this.avatar,
    required this.address,
    required this.route,
    required this.navigating,
    required this.routeLoading,
    required this.showSteps,
    required this.maneuvers,
    required this.onDirections,
    required this.onEnd,
    required this.onToggleSteps,
  });

  final String sellerName;
  final bool verified;
  final String? avatar;
  final String address;
  final AOSRoute? route;
  final bool navigating;
  final bool routeLoading;
  final bool showSteps;
  final List<AOSRouteManeuver> maneuvers;
  final VoidCallback onDirections;
  final VoidCallback onEnd;
  final VoidCallback onToggleSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface.withValues(alpha: .94),
      elevation: 10,
      borderRadius: BorderRadius.circular(22),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: showSteps ? MediaQuery.sizeOf(context).height * .48 : 150,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: avatar == null
                        ? SizedBox(
                            width: 44,
                            height: 44,
                            child: ColoredBox(
                              color: colors.elevated,
                              child: const Icon(Icons.storefront_outlined),
                            ),
                          )
                        : AppNetworkImage(url: avatar!, width: 44, height: 44),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                sellerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.pStrong.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (verified) ...[
                              const SizedBox(width: 4),
                              const VerifiedBadge(size: 16),
                            ],
                          ],
                        ),
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.smallMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (navigating)
                    OutlinedButton.icon(
                      onPressed: onEnd,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('End'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: routeLoading ? null : onDirections,
                      style: FilledButton.styleFrom(
                        foregroundColor: colors.white,
                      ),
                      icon: routeLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.white,
                              ),
                            )
                          : const Icon(Icons.navigation_rounded),
                      label: const Text('Directions'),
                    ),
                ],
              ),
              if (navigating && route != null) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: colors.border),
                TextButton.icon(
                  onPressed: onToggleSteps,
                  icon: const Icon(Icons.route_outlined),
                  label: Expanded(
                    child: Text(
                      '${route!.durationLabel} · ${route!.distanceLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  iconAlignment: IconAlignment.start,
                ),
                if (showSteps)
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: maneuvers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final maneuver = maneuvers[index];
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.flag_outlined,
                              color: colors.primary,
                            ),
                            title: Text(maneuver.bestVoiceText),
                            subtitle: maneuver.distanceDisplay == null
                                ? null
                                : Text(maneuver.distanceDisplay!),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationInstruction extends StatelessWidget {
  const _NavigationInstruction({
    required this.maneuver,
    required this.rerouting,
    required this.voiceEnabled,
    required this.onVoice,
  });

  final AOSRouteManeuver maneuver;
  final bool rerouting;
  final bool voiceEnabled;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF168A4F),
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rerouting)
                    const Text(
                      'Rerouting…',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  Text(
                    maneuver.bestVoiceText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: voiceEnabled ? 'Mute directions' : 'Enable directions',
              onPressed: onVoice,
              icon: Icon(
                voiceEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface.withValues(alpha: .94),
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: colors.primary),
      ),
    );
  }
}

class _UnavailableMap extends StatelessWidget {
  const _UnavailableMap({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_outlined, size: 48),
                const SizedBox(height: 12),
                Text('Location unavailable', style: context.h5),
                const SizedBox(height: 6),
                Text(
                  'This seller has not published a storefront location.',
                  textAlign: TextAlign.center,
                  style: context.pMuted,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onBack,
                  style: FilledButton.styleFrom(
                    foregroundColor: context.appColors.white,
                  ),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NearestPoint {
  const _NearestPoint({required this.index, required this.distanceMeters});

  final int index;
  final double distanceMeters;
}

String _hexColor(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
