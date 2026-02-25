import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/home/wishlist/controller/wishlist_state.dart';

class WishlistController extends AsyncNotifier<WishlistState> {
  @override
  Future<WishlistState> build() async {
    final auth = ref.read(authControllerProvider);

    if (!auth.isLoggedIn) {
      return WishlistState.initial();
    }

    final res = await ref
        .read(adsApiProvider)
        .listWishlist(limit: 500, offset: 0);

    return res.fold((_) => WishlistState.initial(), (payload) {
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

      return WishlistState.initial().copyWith(ids: ids, isReady: true);
    });
  }

  bool isWishlisted(String adId) =>
      state.value?.ids.contains(adId.trim()) ?? false;

  Future<bool> toggle(String adId) async {
    final auth = ref.read(authControllerProvider);

    if (!auth.isLoggedIn) return false;

    final res = await ref
        .read(adsApiProvider)
        .toggleWishlist(adId: adId.trim());

    return res.fold((_) => false, (_) {
      ref.invalidateSelf();
      return true;
    });
  }
}
