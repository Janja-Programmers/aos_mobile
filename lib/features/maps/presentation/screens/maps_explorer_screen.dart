import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:africaonlinestores/core/location/location_service.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/polyline6_decoder.dart';
import 'package:africaonlinestores/features/maps/data/maps_api.dart';
import 'package:africaonlinestores/features/maps/data/seller_maps_api.dart';
import 'package:africaonlinestores/features/maps/domain/aos_route.dart';
import 'package:africaonlinestores/features/maps/domain/seller_location_response.dart';
import 'package:africaonlinestores/features/maps/domain/seller_map_point.dart';
import 'package:africaonlinestores/features/maps/domain/seller_nearby_item.dart';
import 'package:africaonlinestores/features/maps/presentation/widgets/aos_map.dart';
import 'package:africaonlinestores/features/maps/presentation/widgets/floating_map_button.dart';
import 'package:africaonlinestores/features/maps/presentation/widgets/status_bottom_sheet.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class MapsExplorerScreen extends ConsumerStatefulWidget {
  const MapsExplorerScreen({super.key, this.initialSellerId});

  final String? initialSellerId;

  @override
  ConsumerState<MapsExplorerScreen> createState() => _MapsExplorerScreenState();
}

enum BuyerMapMode { nearby, explore, storefront }

enum RouteUiState { idle, preview, navigating }

class _MapsExplorerScreenState extends ConsumerState<MapsExplorerScreen> {
  final _tts = FlutterTts();
  final _sellerController = TextEditingController();
  final _radiusController = TextEditingController(text: '20');

  MapLibreMapController? _map;
  CameraPosition _camera = const CameraPosition(
    target: LatLng(-1.286389, 36.817223),
    zoom: 11,
  );

  BuyerMapMode _mode = BuyerMapMode.nearby;
  RouteUiState _routeUiState = RouteUiState.idle;
  bool _loading = false;

  LatLng? _buyerLocation;
  List<SellerNearbyItem> _nearbySellers = [];
  List<SellerMapPoint> _mapPoints = [];
  SellerPinPoint? _selectedPin;
  SellerLocationResponse? _storefrontLocation;
  AOSRoute? _route;

  bool _voiceEnabled = true;
  bool _rerouting = false;
  int _navInstructionIndex = 0;
  double? _offRouteMeters;
  double? _distanceToNextManeuverMeters;
  LatLng? _liveUserLocation;
  DateTime? _lastRerouteAt;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _navigationRefreshTimer;
  Timer? _mapPointDebounce;
  List<LatLng> _routePoints = const [];
  final Set<int> _spokenManeuverIndexes = <int>{};
  final Set<int> _spokenAlertIndexes = <int>{};

  MapsApi get _mapsApi => ref.read(mapsApiProvider);
  SellerMapsApi get _sellerApi => ref.read(sellerMapsApiProvider);

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.0);

    final initialSeller = widget.initialSellerId?.trim();
    if (initialSeller != null && initialSeller.isNotEmpty) {
      _sellerController.text = initialSeller;
      _mode = BuyerMapMode.storefront;
      Future.microtask(_loadStorefrontLocation);
    }
  }

  @override
  void dispose() {
    _sellerController.dispose();
    _radiusController.dispose();
    _positionSubscription?.cancel();
    _navigationRefreshTimer?.cancel();
    _mapPointDebounce?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    final snack = ShowSnack(context, message);
    error ? snack.error() : snack.success();
  }

  void _setMode(BuyerMapMode mode) {
    setState(() => _mode = mode);
    if (mode == BuyerMapMode.explore) {
      _scheduleMapPointsLoad(immediate: true);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );
      final current = LatLng(pos.latitude, pos.longitude);
      setState(() => _buyerLocation = current);
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(current, 15));
      _snack('Your location is set.');
    } catch (e) {
      _snack(e.toString(), error: true);
    }
  }

  void _useMapCenterAsBuyer() {
    setState(() => _buyerLocation = _camera.target);
    _snack('Map center is set as your starting point.');
  }

  Future<LatLng> _currentOriginForRouting({bool preferGps = false}) async {
    if (preferGps) {
      try {
        final pos = await LocationService.getCurrentPosition(
          timeLimit: const Duration(seconds: 12),
        );
        final current = LatLng(pos.latitude, pos.longitude);
        if (mounted) setState(() => _buyerLocation = current);
        return current;
      } catch (_) {
        // Fall back quietly while navigation is refreshing.
      }
    }
    return _buyerLocation ?? _camera.target;
  }

  Future<void> _loadNearbySellers() async {
    final origin = _buyerLocation ?? _camera.target;
    final radius = double.tryParse(_radiusController.text.trim()) ?? 20;
    setState(() => _loading = true);
    final result = await _sellerApi.listNearbySellers(
      latitude: origin.latitude,
      longitude: origin.longitude,
      radiusKm: radius,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold((failure) => _snack(failure.message, error: true), (items) {
      setState(() => _nearbySellers = items);
      if (items.isEmpty) _snack('No nearby sellers found.', error: true);
    });
  }

  void _scheduleMapPointsLoad({bool immediate = false}) {
    _mapPointDebounce?.cancel();
    _mapPointDebounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 450),
      () {
        if (mounted && _mode == BuyerMapMode.explore) {
          _loadMapPoints(silent: true);
        }
      },
    );
  }

  Future<void> _loadMapPoints({bool silent = false}) async {
    final map = _map;
    if (map == null) return;

    if (!silent) setState(() => _loading = true);
    try {
      final bounds = await map.getVisibleRegion();
      final zoom = _camera.zoom.round();
      final result = await _sellerApi.listSellerMapPoints(
        south: bounds.southwest.latitude,
        north: bounds.northeast.latitude,
        west: bounds.southwest.longitude,
        east: bounds.northeast.longitude,
        zoom: zoom,
      );
      if (!mounted) return;
      if (!silent) setState(() => _loading = false);
      await result.fold(
        (failure) {
          if (!silent) _snack(failure.message, error: true);
        },
        (items) async {
          setState(() => _mapPoints = items);
          await _drawMapPoints(items);
        },
      );
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() => _loading = false);
        _snack(e.toString(), error: true);
      }
    }
  }

  Future<void> _drawMapPoints(List<SellerMapPoint> items) async {
    final map = _map;
    if (map == null) return;

    await map.clearSymbols();
    await map.clearCircles();

    if (!mounted) return;
    final pinColor = _hexColor(context.appColors.primary);

    for (final item in items) {
      final position = LatLng(item.latitude, item.longitude);
      if (item is SellerClusterPoint) {
        await map.addCircle(
          CircleOptions(
            geometry: position,
            circleRadius: 20,
            circleColor: pinColor,
            circleOpacity: 0.92,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 3,
          ),
        );
        await map.addSymbol(
          SymbolOptions(
            geometry: position,
            textField: item.count.toString(),
            textSize: 13,
            textColor: '#FFFFFF',
            textHaloColor: pinColor,
            textHaloWidth: 0.8,
          ),
        );
      } else if (item is SellerPinPoint) {
        await map.addCircle(
          CircleOptions(
            geometry: position,
            circleRadius: 12,
            circleColor: pinColor,
            circleOpacity: 0.95,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 3,
          ),
        );
        await map.addSymbol(
          SymbolOptions(
            geometry: position,
            textField: 'S',
            textSize: 11,
            textColor: '#FFFFFF',
            textHaloColor: pinColor,
            textHaloWidth: 0.6,
          ),
        );
      }
    }
  }

  Future<void> _loadStorefrontLocation() async {
    final seller = _sellerController.text.trim();
    if (seller.isEmpty) {
      _snack('Enter a seller ID first.', error: true);
      return;
    }

    _stopNavigation(keepRoute: false);
    setState(() => _loading = true);
    final result = await _sellerApi.getSellerLocation(seller: seller);
    if (!mounted) return;
    setState(() => _loading = false);

    result.fold((failure) => _snack(failure.message, error: true), (
      response,
    ) async {
      final loc = response.location;
      if (loc == null || !loc.hasLocation) {
        _snack('Seller has no saved map location.', error: true);
        return;
      }
      final pin = SellerPinPoint(
        latitude: loc.latitude,
        longitude: loc.longitude,
        seller: response.seller ?? seller,
        user: response.user,
        displayName: loc.name.isNotEmpty ? loc.name : response.seller ?? seller,
        locationName: loc.name,
        locality: loc.locality,
        region: loc.region,
        countryCode: loc.countryCode,
      );
      setState(() {
        _storefrontLocation = response;
        _selectedPin = pin;
        _mode = BuyerMapMode.storefront;
        _route = null;
        _routeUiState = RouteUiState.idle;
      });
      await _map?.clearSymbols();
      await _map?.clearCircles();
      final target = LatLng(loc.latitude, loc.longitude);
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
      if (!mounted) return;
      final pinColor = _hexColor(context.appColors.primary);
      await _map?.addCircle(
        CircleOptions(
          geometry: target,
          circleRadius: 13,
          circleColor: pinColor,
          circleOpacity: 0.96,
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
        ),
      );
    });
  }

  Future<void> _routeToSelectedSeller({
    bool refresh = false,
    bool silent = false,
  }) async {
    final seller =
        _selectedPin?.seller ??
        _storefrontLocation?.seller ??
        _sellerController.text.trim();
    if (seller.isEmpty) {
      if (!silent) _snack('Select or enter a seller first.', error: true);
      return;
    }

    final origin = await _currentOriginForRouting(
      preferGps: refresh || _routeUiState == RouteUiState.navigating,
    );
    if (!silent) setState(() => _loading = true);

    final result = refresh
        ? await _mapsApi.refreshRouteToSeller(
            currentLatitude: origin.latitude,
            currentLongitude: origin.longitude,
            destinationSeller: seller,
            costing: 'auto',
          )
        : await _mapsApi.getRouteToSeller(
            originLatitude: origin.latitude,
            originLongitude: origin.longitude,
            destinationSeller: seller,
            costing: 'auto',
          );

    if (!mounted) return;
    if (!silent) setState(() => _loading = false);

    await result.fold(
      (failure) {
        if (!silent) _snack(failure.message, error: true);
      },
      (route) async {
        setState(() {
          _route = route;
          if (_routeUiState == RouteUiState.idle) {
            _routeUiState = RouteUiState.preview;
          }
        });
        await _drawRoute(route);
        if (_routeUiState == RouteUiState.navigating &&
            _liveUserLocation != null) {
          await _updateNavigationProgress(
            _liveUserLocation!,
            forceSpeak: refresh,
          );
        }
        if (!silent) _snack(refresh ? 'Route refreshed.' : 'Route ready.');
      },
    );
  }

  Future<void> _drawRoute(AOSRoute route) async {
    final map = _map;
    final shape = route.firstShape;
    if (map == null || shape == null || shape.isEmpty) return;

    final points = Polyline6Decoder.decode(shape);
    _routePoints = points;
    await map.clearLines();
    if (points.isEmpty) return;

    if (!mounted) return;
    await map.addLine(
      LineOptions(
        geometry: points,
        lineColor: _hexColor(context.appColors.primary),
        lineWidth: _routeUiState == RouteUiState.navigating ? 7 : 5,
        lineOpacity: 0.92,
      ),
    );
    if (_routeUiState == RouteUiState.navigating && _liveUserLocation != null) {
      await map.animateCamera(
        CameraUpdate.newLatLngZoom(_liveUserLocation!, 17),
      );
    } else {
      await map.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFor(points),
          left: 44,
          top: 120,
          right: 44,
          bottom: 190,
        ),
      );
    }
  }

  LatLngBounds _boundsFor(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _startNavigation() async {
    if (_route == null) {
      await _routeToSelectedSeller();
      if (_route == null) return;
    }

    Position startPosition;
    try {
      startPosition = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      _snack(e.toString(), error: true);
      return;
    }

    final start = LatLng(startPosition.latitude, startPosition.longitude);
    setState(() {
      _routeUiState = RouteUiState.navigating;
      _liveUserLocation = start;
      _buyerLocation = start;
      _navInstructionIndex = 0;
      _offRouteMeters = null;
      _distanceToNextManeuverMeters = null;
      _spokenManeuverIndexes.clear();
      _spokenAlertIndexes.clear();
    });

    await _drawRoute(_route!);
    await _updateNavigationProgress(start, forceSpeak: true);
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(start, 17));

    await _positionSubscription?.cancel();
    _navigationRefreshTimer?.cancel();

    _positionSubscription = LocationService.getNavigationPositionStream()
        .listen(
          (position) async {
            final current = LatLng(position.latitude, position.longitude);
            if (!mounted || _routeUiState != RouteUiState.navigating) return;
            setState(() {
              _liveUserLocation = current;
              _buyerLocation = current;
            });
            await _map?.animateCamera(CameraUpdate.newLatLng(current));
            await _updateNavigationProgress(current);
          },
          onError: (error) {
            if (mounted) _snack(error.toString(), error: true);
          },
        );

    _navigationRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _routeToSelectedSeller(refresh: true, silent: true),
    );
  }

  void _stopNavigation({bool keepRoute = true}) {
    _positionSubscription?.cancel();
    _navigationRefreshTimer?.cancel();
    _positionSubscription = null;
    _navigationRefreshTimer = null;
    _tts.stop();
    if (!mounted) return;
    setState(() {
      _routeUiState = keepRoute && _route != null
          ? RouteUiState.preview
          : RouteUiState.idle;
      _navInstructionIndex = 0;
      _offRouteMeters = null;
      _distanceToNextManeuverMeters = null;
      _spokenManeuverIndexes.clear();
      _spokenAlertIndexes.clear();
      if (!keepRoute) {
        _route = null;
        _routePoints = const [];
      }
    });
  }

  Future<void> _updateNavigationProgress(
    LatLng user, {
    bool forceSpeak = false,
  }) async {
    final route = _route;
    final routePoints = _routePoints;
    if (route == null || routePoints.isEmpty) return;

    final nearest = _nearestRoutePoint(user, routePoints);
    final nextManeuverIndex = _maneuverIndexForShapeIndex(
      route.maneuvers,
      nearest.index,
    );
    final maneuvers = route.maneuvers;
    final distanceToNext = _distanceToManeuverEndMeters(
      user: user,
      routePoints: routePoints,
      maneuver: maneuvers.isEmpty ? null : maneuvers[nextManeuverIndex],
    );

    if (!mounted) return;
    setState(() {
      _navInstructionIndex = nextManeuverIndex;
      _offRouteMeters = nearest.distanceMeters;
      _distanceToNextManeuverMeters = distanceToNext;
    });

    await _speakForPosition(
      maneuverIndex: nextManeuverIndex,
      distanceToManeuverMeters: distanceToNext,
      forceSpeak: forceSpeak,
    );

    if (nearest.distanceMeters >= 50) {
      await _rerouteIfAllowed(user);
    }
  }

  int _maneuverIndexForShapeIndex(
    List<AOSRouteManeuver> maneuvers,
    int shapeIndex,
  ) {
    if (maneuvers.isEmpty) return 0;
    for (final maneuver in maneuvers) {
      final begin = maneuver.beginShapeIndex;
      final end = maneuver.endShapeIndex;
      if (begin != null &&
          end != null &&
          shapeIndex >= begin &&
          shapeIndex <= end) {
        return maneuver.index.clamp(0, maneuvers.length - 1);
      }
      if (end != null && shapeIndex <= end) {
        return maneuver.index.clamp(0, maneuvers.length - 1);
      }
    }
    return maneuvers.length - 1;
  }

  double? _distanceToManeuverEndMeters({
    required LatLng user,
    required List<LatLng> routePoints,
    required AOSRouteManeuver? maneuver,
  }) {
    final endIndex = maneuver?.endShapeIndex;
    if (endIndex == null || endIndex < 0 || endIndex >= routePoints.length) {
      return null;
    }
    final end = routePoints[endIndex];
    return Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      end.latitude,
      end.longitude,
    );
  }

  Future<void> _speakForPosition({
    required int maneuverIndex,
    required double? distanceToManeuverMeters,
    bool forceSpeak = false,
  }) async {
    if (!_voiceEnabled || _routeUiState != RouteUiState.navigating) return;
    final maneuvers = _route?.maneuvers ?? const <AOSRouteManeuver>[];
    if (maneuvers.isEmpty) return;
    final index = maneuverIndex.clamp(0, maneuvers.length - 1);
    final maneuver = maneuvers[index];

    if (forceSpeak || !_spokenManeuverIndexes.contains(index)) {
      _spokenManeuverIndexes.add(index);
      await _speak(maneuver.bestVoiceText);
      return;
    }

    if (distanceToManeuverMeters != null &&
        distanceToManeuverMeters <= 90 &&
        !_spokenAlertIndexes.contains(index)) {
      _spokenAlertIndexes.add(index);
      await _speak(maneuver.alertVoiceText);
    }
  }

  Future<void> _speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  Future<void> _rerouteIfAllowed(LatLng user) async {
    if (_rerouting) return;
    final now = DateTime.now();
    final last = _lastRerouteAt;
    if (last != null && now.difference(last) < const Duration(seconds: 20)) {
      return;
    }

    setState(() {
      _rerouting = true;
      _lastRerouteAt = now;
    });

    if (_voiceEnabled) await _speak('Rerouting');

    final seller =
        _selectedPin?.seller ??
        _storefrontLocation?.seller ??
        _sellerController.text.trim();
    if (seller.isEmpty) {
      if (mounted) setState(() => _rerouting = false);
      return;
    }

    final result = await _mapsApi.refreshRouteToSeller(
      currentLatitude: user.latitude,
      currentLongitude: user.longitude,
      destinationSeller: seller,
      costing: 'auto',
    );

    if (!mounted) return;
    setState(() => _rerouting = false);

    result.fold((failure) => _snack(failure.message, error: true), (
      route,
    ) async {
      setState(() {
        _route = route;
        _navInstructionIndex = 0;
        _spokenManeuverIndexes.clear();
        _spokenAlertIndexes.clear();
      });
      await _drawRoute(route);
      await _updateNavigationProgress(user, forceSpeak: true);
    });
  }

  _NearestRoutePoint _nearestRoutePoint(LatLng user, List<LatLng> routePoints) {
    var bestIndex = 0;
    var bestDistance = double.infinity;

    for (var i = 0; i < routePoints.length; i++) {
      final point = routePoints[i];
      final distance = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    return _NearestRoutePoint(index: bestIndex, distanceMeters: bestDistance);
  }

  void _toggleVoice() {
    setState(() => _voiceEnabled = !_voiceEnabled);
    if (!_voiceEnabled) {
      _tts.stop();
    } else if (_routeUiState == RouteUiState.navigating) {
      _speakForPosition(
        maneuverIndex: _navInstructionIndex,
        distanceToManeuverMeters: _distanceToNextManeuverMeters,
        forceSpeak: true,
      );
    }
  }

  Widget _modeSelector() {
    final colors = context.appColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(30),
          color: colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: SegmentedButton<BuyerMapMode>(
              segments: const [
                ButtonSegment(
                  value: BuyerMapMode.nearby,
                  label: Text('Nearby'),
                  icon: Icon(Icons.near_me_rounded),
                ),
                ButtonSegment(
                  value: BuyerMapMode.explore,
                  label: Text('Explore'),
                  icon: Icon(Icons.map_outlined),
                ),
                ButtonSegment(
                  value: BuyerMapMode.storefront,
                  label: Text('Route'),
                  icon: Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) => _setMode(value.first),
              showSelectedIcon: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomSheet() {
    if (_routeUiState == RouteUiState.navigating) {
      return const SizedBox.shrink();
    }
    switch (_mode) {
      case BuyerMapMode.nearby:
        return _nearbySheet();
      case BuyerMapMode.explore:
        return _exploreSheet();
      case BuyerMapMode.storefront:
        return _storefrontSheet();
    }
  }

  Widget _nearbySheet() {
    final origin = _buyerLocation ?? _camera.target;
    return StatusBottomSheet(
      title: 'Nearby sellers',
      maxHeightFactor: 0.36,
      actions: [
        OutlinedButton.icon(
          onPressed: _useCurrentLocation,
          icon: const Icon(Icons.my_location_rounded),
          label: const Text('GPS'),
        ),
        OutlinedButton.icon(
          onPressed: _useMapCenterAsBuyer,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Use center'),
        ),
        FilledButton.icon(
          onPressed: _loading ? null : _loadNearbySellers,
          icon: const Icon(Icons.search_rounded),
          label: const Text('Find nearby'),
        ),
      ],
      children: [
        Text(
          'Origin: ${origin.latitude.toStringAsFixed(6)}, ${origin.longitude.toStringAsFixed(6)}',
          style: context.smallMuted,
        ),
        TextField(
          controller: _radiusController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Radius KM',
            isDense: true,
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        if (_nearbySellers.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 132,
            child: ListView.separated(
              itemCount: _nearbySellers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final seller = _nearbySellers[index];
                final initial = seller.displayName.trim().isEmpty
                    ? 'S'
                    : seller.displayName.trim()[0].toUpperCase();
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(initial)),
                  title: Text(
                    seller.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong,
                  ),
                  subtitle: Text(
                    '${seller.businessCategory ?? 'Seller'} · ${seller.distanceDisplay ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _sellerController.text = seller.seller;
                    _setMode(BuyerMapMode.storefront);
                    _loadStorefrontLocation();
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _exploreSheet() {
    final clusterCount = _mapPoints.whereType<SellerClusterPoint>().length;
    final pinCount = _mapPoints.whereType<SellerPinPoint>().length;

    return StatusBottomSheet(
      title: 'Seller map explore',
      maxHeightFactor: 0.30,
      actions: [
        FilledButton.icon(
          onPressed: _loading ? null : () => _loadMapPoints(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
        ),
      ],
      children: [
        Text(
          'Zoom ${_camera.zoom.toStringAsFixed(1)} · clusters: $clusterCount · pins: $pinCount',
          style: context.p,
        ),
        Text(
          'Pan or zoom the map. Seller points refresh after movement.',
          style: context.smallMuted,
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        if (_selectedPin != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storefront_rounded),
            title: Text(_selectedPin!.displayName ?? _selectedPin!.seller),
            subtitle: Text(
              '${_selectedPin!.locationName ?? ''} ${_selectedPin!.locality ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: FilledButton(
              onPressed: () {
                _sellerController.text = _selectedPin!.seller;
                _setMode(BuyerMapMode.storefront);
                _loadStorefrontLocation();
              },
              child: const Text('Open'),
            ),
          ),
      ],
    );
  }

  Widget _storefrontSheet() {
    final loc = _storefrontLocation?.location;
    final route = _route;

    return StatusBottomSheet(
      title: route == null ? 'Route to seller' : 'Route preview',
      maxHeightFactor: route == null ? 0.36 : 0.32,
      actions: [
        if (route == null) ...[
          OutlinedButton.icon(
            onPressed: _useCurrentLocation,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('GPS'),
          ),
          OutlinedButton.icon(
            onPressed: _useMapCenterAsBuyer,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Use center'),
          ),
          FilledButton.icon(
            onPressed: _loading ? null : _loadStorefrontLocation,
            icon: const Icon(Icons.storefront_rounded),
            label: const Text('Load seller'),
          ),
        ],
        if (loc?.hasLocation == true && route == null)
          FilledButton.icon(
            onPressed: () => _routeToSelectedSeller(),
            icon: const Icon(Icons.directions_rounded),
            label: const Text('Directions'),
          ),
        if (route != null) ...[
          FilledButton.icon(
            onPressed: _startNavigation,
            icon: const Icon(Icons.navigation_rounded),
            label: const Text('Start'),
          ),
          OutlinedButton.icon(
            onPressed: () => _routeToSelectedSeller(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              _stopNavigation(keepRoute: false);
              await _map?.clearLines();
            },
            icon: const Icon(Icons.close_rounded),
            label: const Text('Clear'),
          ),
        ],
      ],
      children: [
        if (route == null)
          TextField(
            controller: _sellerController,
            decoration: const InputDecoration(
              labelText: 'Seller ID',
              hintText: 'Example: seller email or seller id',
              isDense: true,
            ),
          ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        if (loc?.hasLocation == true) ...[
          const SizedBox(height: 6),
          Text(
            loc!.shortLabel.isNotEmpty
                ? loc.shortLabel
                : _storefrontLocation?.seller ?? 'Seller',
            style: context.pStrong,
          ),
          Text(
            loc.displayAddress.isNotEmpty ? loc.displayAddress : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.smallMuted,
          ),
          if (loc.instructions != null)
            Text(
              'Instructions: ${loc.instructions}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.smallMuted,
            ),
          TextButton.icon(
            onPressed: () {
              final seller = _storefrontLocation?.seller;
              if (seller?.isNotEmpty == true) {
                SellerNavigation.toSellerStore(context, seller!);
              }
            },
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('View storefront'),
          ),
        ],
        if (route != null) ...[
          Row(
            children: [
              const Icon(Icons.directions_car_rounded, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${route.durationLabel} · ${route.distanceLabel}',
                  style: context.h5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Driving route preview', style: context.smallMuted),
          if (route.maneuvers.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              route.maneuvers.first.bestVoiceText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.p,
            ),
          ],
        ],
      ],
    );
  }

  Widget _navigationBanner() {
    if (_routeUiState != RouteUiState.navigating || _route == null) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;
    final maneuvers = _route!.maneuvers;
    final current = maneuvers.isEmpty
        ? null
        : maneuvers[_navInstructionIndex.clamp(0, maneuvers.length - 1)];
    final next =
        maneuvers.isEmpty || _navInstructionIndex + 1 >= maneuvers.length
        ? null
        : maneuvers[_navInstructionIndex + 1];

    return Positioned(
      left: 12,
      right: 12,
      top: MediaQuery.paddingOf(context).top + 12,
      child: Material(
        elevation: 10,
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
          child: Row(
            children: [
              const Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      current?.bestVoiceText ?? 'Continue',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _navigationStatusText(next),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _voiceEnabled ? 'Mute voice' : 'Unmute voice',
                onPressed: _toggleVoice,
                icon: Icon(
                  _voiceEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Stop navigation',
                onPressed: () => _stopNavigation(keepRoute: true),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _navigationStatusText(AOSRouteManeuver? next) {
    final offRoute = _offRouteMeters;
    if (_rerouting) return 'Rerouting…';
    if (offRoute != null && offRoute >= 50) {
      return 'Off route by ${offRoute.round()} m';
    }
    final d = _distanceToNextManeuverMeters;
    if (d != null) return 'Next maneuver in ${_formatMeters(d)}';
    if (next != null) return 'Then: ${next.bestVoiceText}';
    return 'Following your live location';
  }

  String _formatMeters(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }

  Widget _navigationBottomPill() {
    if (_routeUiState != RouteUiState.navigating || _route == null) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;

    return Positioned(
      left: 12,
      right: 12,
      bottom: MediaQuery.paddingOf(context).bottom + 12,
      child: Material(
        elevation: 10,
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_route!.durationLabel} · ${_route!.distanceLabel}${_liveUserLocation == null ? '' : ' · GPS live'}',
                  style: context.pStrong,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _routeToSelectedSeller(refresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reroute'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMapPointTap(LatLng geometry) async {
    SellerClusterPoint? cluster;
    SellerPinPoint? pin;
    double bestPin = double.infinity;
    double bestCluster = double.infinity;

    for (final point in _mapPoints) {
      final d =
          (point.latitude - geometry.latitude).abs() +
          (point.longitude - geometry.longitude).abs();
      if (point is SellerClusterPoint && d < bestCluster) {
        bestCluster = d;
        cluster = point;
      }
      if (point is SellerPinPoint && d < bestPin) {
        bestPin = d;
        pin = point;
      }
    }

    if (pin != null && (_camera.zoom >= 14 || bestPin <= bestCluster)) {
      setState(() => _selectedPin = pin);
      return;
    }

    if (cluster != null) {
      await _map?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(cluster.latitude, cluster.longitude),
          (_camera.zoom + 2).clamp(5, 18).toDouble(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _routeUiState == RouteUiState.navigating
          ? null
          : AppBar(
              title: Text('Sellers map', style: context.h5),
              actions: [
                TextButton.icon(
                  onPressed: () => context.pushNamed(AppRoutes.nSellerLocation),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('My store'),
                ),
              ],
            ),
      body: Stack(
        children: [
          AOSMap(
            onMapCreated: (controller) {
              _map = controller;
              controller.onSymbolTapped.add((symbol) async {
                final geometry = symbol.options.geometry;
                if (geometry != null) await _handleMapPointTap(geometry);
              });
              controller.onCircleTapped.add((circle) async {
                final geometry = circle.options.geometry;
                if (geometry != null) await _handleMapPointTap(geometry);
              });
            },
            onCameraMove: (position) => _camera = position,
            onCameraIdle: () {
              if (_mode == BuyerMapMode.explore) _scheduleMapPointsLoad();
            },
          ),
          if (_routeUiState != RouteUiState.navigating) _modeSelector(),
          Positioned(
            right: 14,
            bottom: _routeUiState == RouteUiState.navigating ? 92 : 250,
            child: Column(
              children: [
                FloatingMapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Use GPS',
                  onTap: _useCurrentLocation,
                ),
                const SizedBox(height: 10),
                FloatingMapButton(
                  icon: Icons.add_location_alt_outlined,
                  tooltip: 'Use center as start',
                  onTap: _useMapCenterAsBuyer,
                ),
              ],
            ),
          ),
          _navigationBanner(),
          _navigationBottomPill(),
          _bottomSheet(),
        ],
      ),
    );
  }
}

String _hexColor(Color color) {
  final rgb = color.value & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class _NearestRoutePoint {
  const _NearestRoutePoint({required this.index, required this.distanceMeters});

  final int index;
  final double distanceMeters;
}
