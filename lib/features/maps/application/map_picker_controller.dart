import 'package:africaonlinestores/core/location/location_service.dart';
import 'package:africaonlinestores/features/maps/data/maps_api.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:flutter_riverpod/legacy.dart';

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
    bool clearSelected = false,
  }) {
    return MapPickerState(
      loading: loading ?? this.loading,
      resolving: resolving ?? this.resolving,
      error: clearError ? null : (error ?? this.error),
      results: results ?? this.results,
      selected: clearSelected ? null : (selected ?? this.selected),
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
  MapPickerController(this.api) : super(MapPickerState.initial());

  final MapsApi api;
  String? _lastSearchQuery;
  int _searchSerial = 0;

  Future<void> search(String query) async {
    final clean = query.trim();
    if (clean.length < 2) {
      _lastSearchQuery = null;
      state = state.copyWith(
        loading: false,
        results: const [],
        clearError: true,
      );
      return;
    }

    if (clean == _lastSearchQuery && state.results.isNotEmpty) return;

    _lastSearchQuery = clean;
    final serial = ++_searchSerial;
    state = state.copyWith(loading: true, clearError: true);
    final res = await api.searchPlaces(query: clean);
    if (serial != _searchSerial) return;

    res.fold(
      (failure) =>
          state = state.copyWith(loading: false, error: failure.message),
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
      (failure) =>
          state = state.copyWith(resolving: false, error: failure.message),
      (place) => state = state.copyWith(resolving: false, selected: place),
    );
  }

  void selectPlace(AOSPlace place) {
    state = state.copyWith(selected: place, clearError: true);
  }

  void clearSelection() {
    state = state.copyWith(
      results: const [],
      clearSelected: true,
      clearError: true,
    );
  }

  Future<void> useCurrentLocation() async {
    state = state.copyWith(resolving: true, clearError: true);
    try {
      final position = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 12),
      );
      await selectCoordinates(position.latitude, position.longitude);
    } on LocationServiceException catch (error) {
      state = state.copyWith(resolving: false, error: error.message);
    } catch (_) {
      state = state.copyWith(
        resolving: false,
        error: 'Failed to get current location.',
      );
    }
  }
}
