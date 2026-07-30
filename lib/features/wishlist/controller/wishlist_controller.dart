import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistControllerProvider =
    NotifierProvider<WishlistController, WishlistState>(WishlistController.new);

class WishlistController extends Notifier<WishlistState> {
  int _generation = 0;

  AdsApi get _api => ref.read(adsApiProvider);

  @override
  WishlistState build() {
    // Reset account-scoped overrides only when the authenticated session changes.
    ref.watch(
      authControllerProvider.select(
        (auth) => auth is AuthAuthenticated ? auth.sid : null,
      ),
    );
    _generation += 1;

    return WishlistState.initial();
  }

  Future<bool> toggle(
    String adId, {
    required bool currentValue,
  }) async {
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated) return false;

    final id = adId.trim();
    if (id.isEmpty || state.pending.contains(id)) return false;

    final requestGeneration = _generation;
    final requestSid = auth.sid;
    final before = state;
    final wasWishlisted = before.resolve(id, fallback: currentValue);
    final shouldBeWishlisted = !wasWishlisted;
    final hadOverride = before.overrides.containsKey(id);
    final previousOverride = before.overrides[id];

    final optimisticOverrides = Map<String, bool>.from(before.overrides)
      ..[id] = shouldBeWishlisted;
    final pending = Set<String>.from(before.pending)..add(id);

    state = before.copyWith(
      overrides: optimisticOverrides,
      pending: pending,
    );

    try {
      final result = await _api.toggleWishlist(
        adId: id,
        wishlisted: shouldBeWishlisted,
      );

      if (result.isLeft) {
        _restoreAfterFailure(
          id: id,
          generation: requestGeneration,
          sid: requestSid,
          hadOverride: hadOverride,
          previousOverride: previousOverride,
        );
        return false;
      }

      if (!_isCurrentRequest(requestGeneration, requestSid)) {
        return true;
      }

      final payload = result.rightOrNull ?? const <String, dynamic>{};
      final data = asJsonMap(payload['data']);
      final backendValue = data.containsKey('wishlisted')
          ? asBool(data['wishlisted'], fallback: shouldBeWishlisted)
          : shouldBeWishlisted;

      final latest = state;
      final overrides = Map<String, bool>.from(latest.overrides)
        ..[id] = backendValue;
      final latestPending = Set<String>.from(latest.pending)..remove(id);

      state = latest.copyWith(
        overrides: overrides,
        pending: latestPending,
      );
      return true;
    } catch (error, stackTrace) {
      appLogger.e(
        'WishlistController -> toggle failed unexpectedly',
        error: error,
        stackTrace: stackTrace,
      );
      _restoreAfterFailure(
        id: id,
        generation: requestGeneration,
        sid: requestSid,
        hadOverride: hadOverride,
        previousOverride: previousOverride,
      );
      return false;
    }
  }

  bool _isCurrentRequest(int generation, String sid) {
    if (generation != _generation) return false;
    final auth = ref.read(authControllerProvider);
    return auth is AuthAuthenticated && auth.sid == sid;
  }

  void _restoreAfterFailure({
    required String id,
    required int generation,
    required String sid,
    required bool hadOverride,
    required bool? previousOverride,
  }) {
    if (!_isCurrentRequest(generation, sid)) return;

    final latest = state;
    final overrides = Map<String, bool>.from(latest.overrides);
    if (hadOverride) {
      overrides[id] = previousOverride!;
    } else {
      overrides.remove(id);
    }

    final pending = Set<String>.from(latest.pending)..remove(id);
    state = latest.copyWith(overrides: overrides, pending: pending);
  }
}
