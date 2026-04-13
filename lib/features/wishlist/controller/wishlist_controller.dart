import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

import 'package:africaonlinestores/features/wishlist/controller/wishlist_state.dart';
import 'package:africaonlinestores/features/wishlist/domain/wishlist_storage.dart';
import 'package:africaonlinestores/features/wishlist/wishlist_storage_provider.dart';

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, WishlistState>(
      WishlistController.new,
    );

class WishlistController extends AsyncNotifier<WishlistState> {
  late final WishlistStorage _storage;
  late final dynamic _api;

  @override
  Future<WishlistState> build() async {
    _storage = ref.read(wishlistStorageProvider);
    _api = ref.read(adsApiProvider);

    final auth = ref.read(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (prev, next) async {
      if (next is AuthAuthenticated) {
        ref.invalidateSelf();
      }

      if (next is AuthGuest) {
        await _storage.clear();
        state = AsyncData(WishlistState.initial());
      }
    });

    if (auth is! AuthAuthenticated) {
      await _storage.clear();
      return WishlistState.initial();
    }

    final localIds = await _storage.readIds();

    state = AsyncData(
      WishlistState.initial().copyWith(ids: localIds, isReady: true),
    );

    final res = await _api.listWishlist(limit: 100, offset: 0);

    return res.fold(
      (_) => WishlistState.initial().copyWith(ids: localIds, isReady: true),
      (payload) {
        final raw = payload['data']?['items'];
        final ids = <String>{};

        if (raw is List) {
          for (final it in raw) {
            if (it is Map) {
              final id = (it['ad_id'] ?? it['ad'] ?? it['name'])
                  ?.toString()
                  .trim();
              if (id != null && id.isNotEmpty) {
                ids.add(id);
              }
            }
          }
        }

        _storage.writeIds(ids);

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
    final current = state.value ?? WishlistState.initial();

    final currentIds = Set<String>.from(current.ids);

    final wasLiked = currentIds.contains(id);
    wasLiked ? currentIds.remove(id) : currentIds.add(id);

    state = AsyncData(current.copyWith(ids: currentIds));

    /// Persist immediately
    await _storage.writeIds(currentIds);

    final res = await _api.toggleWishlist(adId: id);

    return res.fold((_) async {
      wasLiked ? currentIds.add(id) : currentIds.remove(id);

      state = AsyncData(current.copyWith(ids: currentIds));
      await _storage.writeIds(currentIds);

      return false;
    }, (_) => true);
  }
}
