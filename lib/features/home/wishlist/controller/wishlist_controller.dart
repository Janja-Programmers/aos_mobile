import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/home/wishlist/controller/wishlist_state.dart';
import 'package:africaonlinestores/features/home/wishlist/provider.dart';

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, WishlistState>(
      WishlistController.new,
    );

class WishlistController extends AsyncNotifier<WishlistState> {
  @override
  Future<WishlistState> build() async {
    // React to login/logout automatically
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (prev?.isLoggedIn != next.isLoggedIn) {
        ref.invalidateSelf();
      }
    });

    final initial = WishlistState.initial();
    state = AsyncData(initial);

    // 1️⃣ Load local wishlist first (guest + logged-in)
    final auth = ref.read(authControllerProvider);
    final localIds = auth.isLoggedIn
        ? <String>{}
        : await ref.read(wishlistStorageProvider).readIds();

    final current = initial.copyWith(ids: localIds, isReady: true);

    state = AsyncData(current);

    // 2️⃣ If logged in → sync with server
    if (auth.isLoggedIn) {
      await _syncWithRemote(current);
    }

    return state.value ?? current;
  }

  bool isWishlisted(String adId) =>
      state.value?.ids.contains(adId.trim()) ?? false;

  bool isPending(String adId) =>
      state.value?.pending.contains(adId.trim()) ?? false;

  /// 🔥 Core Toggle (Guest + Logged-In Safe)
  Future<bool> toggle(String adId) async {
    adId = adId.trim();
    if (adId.isEmpty) return false;

    final current = state.value ?? WishlistState.initial();

    if (current.pending.contains(adId)) return false;

    final wasWishlisted = current.ids.contains(adId);

    final nextIds = {...current.ids};
    if (wasWishlisted) {
      nextIds.remove(adId);
    } else {
      nextIds.add(adId);
    }

    final nextPending = {...current.pending, adId};

    // Optimistic update
    state = AsyncData(current.copyWith(ids: nextIds, pending: nextPending));

    // Persist locally immediately
    await ref.read(wishlistStorageProvider).writeIds(nextIds);

    final auth = ref.read(authControllerProvider);

    // 👤 Guest → local only
    if (!auth.isLoggedIn) {
      final pendingAfter = {...nextPending}..remove(adId);
      state = AsyncData(
        (state.value ?? current).copyWith(pending: pendingAfter),
      );
      return true;
    }

    // 🔐 Logged-in → sync remote
    final res = await ref.read(adsApiProvider).toggleWishlist(adId: adId);

    return res.fold(
      (_) async {
        // ❌ Rollback on failure
        final rollbackIds = {...nextIds};
        if (wasWishlisted) {
          rollbackIds.add(adId);
        } else {
          rollbackIds.remove(adId);
        }

        await ref.read(wishlistStorageProvider).writeIds(rollbackIds);

        final pendingAfter = {...nextPending}..remove(adId);

        state = AsyncData(
          (state.value ?? current).copyWith(
            ids: rollbackIds,
            pending: pendingAfter,
          ),
        );

        return false;
      },
      (_) async {
        final pendingAfter = {...nextPending}..remove(adId);

        state = AsyncData(
          (state.value ?? current).copyWith(pending: pendingAfter),
        );

        return true;
      },
    );
  }

  /// 🔄 Merge local + remote on login or returning session
  Future<void> _syncWithRemote(WishlistState current) async {
    final res = await ref
        .read(adsApiProvider)
        .listWishlist(limit: 500, offset: 0);

    await res.fold((_) async {}, (payload) async {
      final raw = payload['data']?['items'];
      final remoteIds = <String>{};

      if (raw is List) {
        for (final it in raw) {
          if (it is Map) {
            final id = (it['ad_id'] ?? it['ad'] ?? it['name'])?.toString();
            if (id != null && id.isNotEmpty) {
              remoteIds.add(id.trim());
            }
          }
        }
      }

      // Items that exist locally but not remotely
      final missingOnServer = current.ids.difference(remoteIds);

      if (missingOnServer.isNotEmpty) {
        final results = await Future.wait(
          missingOnServer.map(
            (id) => ref.read(adsApiProvider).toggleWishlist(adId: id),
          ),
        );

        // Check if all pushes succeeded
        final allSucceeded = results.every((result) => result.isRight);
        if (!allSucceeded) return;
      }

      await ref.read(wishlistStorageProvider).clear();
      await ref.read(wishlistStorageProvider).writeIds(remoteIds);

      // Update in-memory state to reflect remote truth only
      state = AsyncData(current.copyWith(ids: remoteIds));
    });
  }
}
