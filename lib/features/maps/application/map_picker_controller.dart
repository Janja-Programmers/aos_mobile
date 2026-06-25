import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';

import 'package:africaonlinestores/features/maps/data/maps_api.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';

class MapPickerState {
  final bool loading;
  final bool resolving;
  final String? error;
  final List<AOSPlace> results;
  final AOSPlace? selected;

  const MapPickerState({
    required this.loading,
    required this.resolving,
    required this.error,
    required this.results,
    required this.selected,
  });

  factory MapPickerState.initial() {
    return const MapPickerState(
      loading: false,
      resolving: false,
      error: null,
      results: [],
      selected: null,
    );
  }

  MapPickerState copyWith({
    bool? loading,
    bool? resolving,
    String? error,
    bool clearError = false,
    List<AOSPlace>? results,
    AOSPlace? selected,
  }) {
    return MapPickerState(
      loading: loading ?? this.loading,
      resolving: resolving ?? this.resolving,
      error: clearError ? null : (error ?? this.error),
      results: results ?? this.results,
      selected: selected ?? this.selected,
    );
  }
}

final mapPickerControllerProvider =
    StateNotifierProvider.autoDispose<MapPickerController, MapPickerState>((
      ref,
    ) {
      return MapPickerController(ref.read(mapsApiProvider));
    });

class MapPickerController extends StateNotifier<MapPickerState> {
  final MapsApi api;

  MapPickerController(this.api) : super(MapPickerState.initial());

  Future<void> search(String query) async {
    final clean = query.trim();
    if (clean.length < 2) {
      state = state.copyWith(results: const [], clearError: true);
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    final res = await api.searchPlaces(query: clean);
    res.fold(
      (f) => state = state.copyWith(loading: false, error: f.message),
      (items) => state = state.copyWith(loading: false, results: items),
    );
  }

  Future<void> selectCoordinates(double latitude, double longitude) async {
    state = state.copyWith(resolving: true, clearError: true);
    final res = await api.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );
    res.fold(
      (f) => state = state.copyWith(resolving: false, error: f.message),
      (place) => state = state.copyWith(resolving: false, selected: place),
    );
  }

  void selectPlace(AOSPlace place) {
    state = state.copyWith(selected: place, clearError: true);
  }

  Future<void> useCurrentLocation() async {
    state = state.copyWith(resolving: true, clearError: true);

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          resolving: false,
          error: 'Location permission is required to use current location.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await selectCoordinates(position.latitude, position.longitude);
    } catch (_) {
      state = state.copyWith(
        resolving: false,
        error: 'Failed to get current location.',
      );
    }
  }
}
