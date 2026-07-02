import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_state_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/following/folllowing_section_state.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
    state = state.copyWith(isLoading: true);

    final res = await ref
        .read(sellerControllerProvider)
        .listSellers(isVerified: 1);

    res.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (json) {
        final data = asJsonMap(json['data']);

        state = state.copyWith(
          isLoading: false,
          sellers: asJsonMapList(data['items'])
              .map(SellerSuggestion.fromJson)
              .where((seller) => seller.canBeSuggested)
              .toList(),
        );
      },
    );
  }

  Future<void> toggleFollow(SellerSuggestion seller) async {
    if (seller.isFollowing) {
      dismissSeller(seller.sellerId);
      return;
    }

    final previousSellers = [...state.sellers];

    final index = previousSellers.indexWhere(
      (e) => e.sellerId == seller.sellerId,
    );

    if (index == -1) return;

    state = state.copyWith(
      sellers: previousSellers
          .where((e) => e.sellerId != seller.sellerId)
          .toList(),
    );

    final res = await ref
        .read(sellerControllerProvider)
        .toggleFollow(sellerId: seller.sellerId);

    res.fold(
      // Rollback if follow failed.
      (failure) {
        final rollback = [...state.sellers];

        final alreadyExists = rollback.any(
          (e) => e.sellerId == seller.sellerId,
        );

        if (!alreadyExists) {
          final safeIndex = index > rollback.length ? rollback.length : index;
          rollback.insert(safeIndex, seller);
        }

        state = state.copyWith(sellers: rollback, error: failure.message);
      },

      // Success: refresh following feed.
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
