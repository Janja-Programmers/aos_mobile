import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_state.dart';
import 'package:africaonlinestores/features/wishlist/domain/wishlist_storage.dart';
import 'package:africaonlinestores/features/wishlist/wishlist_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, WishlistState>(
      WishlistController.new,
    );

class WishlistController extends AsyncNotifier<WishlistState> {
  late final WishlistStorage _storage;
  late final AdsApi _api;

  @override
  Future<WishlistState> build() async {
    _storage = ref.read(wishlistStorageProvider);
    _api = ref.read(adsApiProvider);

    final auth = ref.watch(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      final localIds = await _storage.readIds();

      if (localIds.isNotEmpty) {
        await _storage.clear();
      }

      return WishlistState.initial();
    }

    final localIds = await _storage.readIds();

    state = AsyncData(
      WishlistState.initial().copyWith(ids: localIds, isReady: true),
    );

    final res = await _api.listWishlist(limit: 100);

    return res.fold(
      (_) => WishlistState.initial().copyWith(ids: localIds, isReady: true),
      (payload) {
        final data = asJsonMap(payload['data']);
        final raw = data['items'];
        final ids = <String>{};

        for (final item in asJsonMapList(raw)) {
          final id = asNullableString(
            item['ad_id'] ?? item['ad'] ?? item['name'],
          )?.trim();
          if (id != null && id.isNotEmpty) {
            ids.add(id);
          }
        }

        unawaited(_storage.writeIds(ids));

        return WishlistState.initial().copyWith(ids: ids, isReady: true);
      },
    );
  }

  bool isWishlisted(String adId) {
    final ids = state.value?.ids ?? {};
    return ids.contains(adId.trim());
  }

  Future<bool> toggle(String adId) async {
    final auth = ref.read(authControllerProvider);

    if (auth is! AuthAuthenticated) return false;

    final id = adId.trim();
    if (id.isEmpty) return false;

    final current = state.value ?? WishlistState.initial();
    if (current.pending.contains(id)) return false;

    final wasWishlisted = current.ids.contains(id);

    final optimisticIds = Set<String>.from(current.ids);
    if (wasWishlisted) {
      optimisticIds.remove(id);
    } else {
      optimisticIds.add(id);
    }

    final pendingIds = Set<String>.from(current.pending)..add(id);

    state = AsyncData(
      current.copyWith(ids: optimisticIds, pending: pendingIds),
    );

    try {
      await _storage.writeIds(optimisticIds);

      final res = await _api.toggleWishlist(adId: id);

      return res.fold(
        (_) async {
          await _finishToggle(id: id, shouldBeWishlisted: wasWishlisted);
          return false;
        },
        (_) async {
          await _finishToggle(id: id, shouldBeWishlisted: !wasWishlisted);
          return true;
        },
      );
    } catch (_) {
      await _finishToggle(id: id, shouldBeWishlisted: wasWishlisted);
      return false;
    }
  }

  Future<void> _finishToggle({
    required String id,
    required bool shouldBeWishlisted,
  }) async {
    final latest = state.value ?? WishlistState.initial();
    final ids = Set<String>.from(latest.ids);
    final pending = Set<String>.from(latest.pending)..remove(id);

    if (shouldBeWishlisted) {
      ids.add(id);
    } else {
      ids.remove(id);
    }

    state = AsyncData(latest.copyWith(ids: ids, pending: pending));

    try {
      await _storage.writeIds(ids);
    } catch (_) {
      // The server response remains authoritative; storage can resync later.
    }
  }
}
