import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/sellers/location/data/seller_location_api.dart';
import 'package:flutter_riverpod/legacy.dart';

class SellerLocationState {
  final bool loading;
  final bool saving;
  final AOSPlace? location;
  final String? error;

  const SellerLocationState({
    required this.loading,
    required this.saving,
    required this.location,
    required this.error,
  });

  factory SellerLocationState.initial() {
    return const SellerLocationState(
      loading: false,
      saving: false,
      location: null,
      error: null,
    );
  }

  SellerLocationState copyWith({
    bool? loading,
    bool? saving,
    AOSPlace? location,
    bool clearLocation = false,
    String? error,
    bool clearError = false,
  }) {
    return SellerLocationState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      location: clearLocation ? null : (location ?? this.location),
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
  final SellerLocationApi api;

  SellerLocationController(this.api) : super(SellerLocationState.initial());

  Future<void> load({String? seller}) async {
    state = state.copyWith(loading: true, clearError: true);
    final res = await api.getSellerLocation(seller: seller);
    res.fold(
      (f) => state = state.copyWith(loading: false, error: f.message),
      (location) => state = state.copyWith(
        loading: false,
        location: location,
        clearLocation: location == null,
      ),
    );
  }

  Future<bool> save({
    required AOSPlace place,
    String? locationName,
    String? instructions,
  }) async {
    state = state.copyWith(saving: true, clearError: true);
    final res = await api.setMySellerLocation(
      latitude: place.latitude,
      longitude: place.longitude,
      locationName: locationName?.trim().isNotEmpty ?? false
          ? locationName!.trim()
          : place.shortLabel,
      locationInstructions: instructions,
    );

    return res.fold(
      (f) {
        state = state.copyWith(saving: false, error: f.message);
        return false;
      },
      (location) {
        state = state.copyWith(saving: false, location: location);
        return true;
      },
    );
  }

  Future<bool> remove() async {
    state = state.copyWith(saving: true, clearError: true);
    final res = await api.removeMySellerLocation();
    return res.fold(
      (f) {
        state = state.copyWith(saving: false, error: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(saving: false, clearLocation: true);
        return true;
      },
    );
  }
}
