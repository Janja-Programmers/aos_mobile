import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/sellers/application/controllers/seller_state_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/following/folllowing_section_state.dart';

final followingSectionControllerProvider =
    StateNotifierProvider<FollowingSectionController, FollowingSectionState>((
      ref,
    ) {
      return FollowingSectionController(ref);
    });

class FollowingSectionController extends StateNotifier<FollowingSectionState> {
  FollowingSectionController(this.ref) : super(FollowingSectionState.initial());

  final Ref ref;

  Future<void> loadSellers() async {
    state = state.copyWith(isLoading: true, error: null);

    final res = await ref
        .read(sellerControllerProvider)
        .listSellers(isVerified: 1, limit: 20, offset: 0);

    res.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final rawItems = data['items'] as List? ?? [];

        state = state.copyWith(
          isLoading: false,
          sellers: rawItems
              .whereType<Map<String, dynamic>>()
              .map(SellerSuggestion.fromJson)
              .toList(),
        );
      },
    );
  }

  Future<void> toggleFollow(SellerSuggestion seller) async {
    final sellers = [...state.sellers];
    final index = sellers.indexWhere((e) => e.sellerId == seller.sellerId);
    if (index == -1) return;

    final oldValue = sellers[index].isFollowing;

    /// 🔥 OPTIMISTIC UPDATE
    sellers[index] = sellers[index].copyWith(
      isFollowing: !oldValue,
      totalFollowers: oldValue
          ? (sellers[index].totalFollowers - 1).clamp(0, 999999999)
          : sellers[index].totalFollowers + 1,
    );

    state = state.copyWith(sellers: sellers);

    final res = await ref
        .read(sellerControllerProvider)
        .toggleFollow(sellerId: seller.sellerId);

    res.fold(
      /// ❌ ROLLBACK
      (_) {
        final rollback = [...state.sellers];
        final rollbackIndex = rollback.indexWhere(
          (e) => e.sellerId == seller.sellerId,
        );

        if (rollbackIndex == -1) return;

        rollback[rollbackIndex] = rollback[rollbackIndex].copyWith(
          isFollowing: oldValue,
          totalFollowers: oldValue
              ? rollback[rollbackIndex].totalFollowers + 1
              : (rollback[rollbackIndex].totalFollowers - 1).clamp(
                  0,
                  999999999,
                ),
        );

        state = state.copyWith(sellers: rollback);
      },

      /// ✅ SUCCESS → REFRESH FOLLOWING FEED
      (_) {
        ref.read(shortGridControllerProvider.notifier).refresh();
      },
    );
  }

  void dismissSeller(String sellerId) {
    state = state.copyWith(
      sellers: state.sellers.where((e) => e.sellerId != sellerId).toList(),
    );
  }
}
