import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/sellers/location/data/seller_location_api.dart';
import 'package:flutter_riverpod/legacy.dart';

class SellerLocationState {
  const SellerLocationState({
    required this.loading,
    required this.saving,
    required this.location,
    required this.locationVersion,
    required this.error,
  });

  final bool loading;
  final bool saving;
  final AOSPlace? location;
  final int? locationVersion;
  final String? error;

  factory SellerLocationState.initial() {
    return const SellerLocationState(
      loading: false,
      saving: false,
      location: null,
      locationVersion: null,
      error: null,
    );
  }

  SellerLocationState copyWith({
    bool? loading,
    bool? saving,
    AOSPlace? location,
    bool clearLocation = false,
    int? locationVersion,
    String? error,
    bool clearError = false,
  }) {
    return SellerLocationState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      location: clearLocation ? null : (location ?? this.location),
      locationVersion: locationVersion ?? this.locationVersion,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final sellerLocationControllerProvider =
    StateNotifierProvider.autoDispose<
      SellerLocationController,
      SellerLocationState
    >((ref) {
      return SellerLocationController(ref.read(sellerLocationApiProvider));
    });

class SellerLocationController extends StateNotifier<SellerLocationState> {
  SellerLocationController(this.api) : super(SellerLocationState.initial());

  final SellerLocationApi api;

  Future<void> load({String? seller}) async {
    state = state.copyWith(loading: true, clearError: true);
    final res = await api.getSellerLocation(seller: seller);
    res.fold(
      (failure) =>
          state = state.copyWith(loading: false, error: failure.message),
      (snapshot) => state = state.copyWith(
        loading: false,
        location: snapshot.location,
        clearLocation: snapshot.location == null,
        locationVersion: snapshot.locationVersion,
      ),
    );
  }

  Future<bool> save({
    required AOSPlace place,
    String? locationName,
    String? instructions,
  }) async {
    if (state.saving) return false;
    state = state.copyWith(saving: true, clearError: true);
    final res = await api.setMySellerLocation(
      latitude: place.latitude,
      longitude: place.longitude,
      locationName: locationName?.trim().isNotEmpty ?? false
          ? locationName!.trim()
          : place.shortLabel,
      locationInstructions: instructions,
      expectedVersion: state.locationVersion,
    );

    return res.fold(
      (failure) {
        state = state.copyWith(saving: false, error: failure.message);
        return false;
      },
      (location) {
        state = state.copyWith(
          saving: false,
          location: location,
          locationVersion: location.locationVersion,
        );
        return true;
      },
    );
  }

  Future<bool> remove() async {
    if (state.saving) return false;
    state = state.copyWith(saving: true, clearError: true);
    final res = await api.removeMySellerLocation(
      expectedVersion: state.locationVersion,
    );
    return res.fold(
      (failure) {
        state = state.copyWith(saving: false, error: failure.message);
        return false;
      },
      (version) {
        state = state.copyWith(
          saving: false,
          clearLocation: true,
          locationVersion: version,
        );
        return true;
      },
    );
  }
}
