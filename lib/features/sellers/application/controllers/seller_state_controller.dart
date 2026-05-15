import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/sellers/application/controllers/seller_controller.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_state.dart';
import 'package:africaonlinestores/features/sellers/data/seller_api.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';

/// Controller provider (API wrapper)
final sellerControllerProvider = Provider<SellerController>((ref) {
  return SellerController(ref.read(sellerApiProvider));
});

/// STATE NOTIFIER
class SellerStateController extends StateNotifier<SellerState> {
  SellerStateController(this.ref, this.sellerId) : super(const SellerState()) {
    load();
  }

  final Ref ref;
  final String sellerId;

  /// LOAD SELLER
  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);

    final controller = ref.read(sellerControllerProvider);

    final res = await controller.getSeller(sellerId: sellerId);

    res.fold((f) => state = state.copyWith(loading: false, error: f.message), (
      data,
    ) {
      final sellerJson = data['data'] ?? data;

      final seller = AOSSellerProfile.fromJson(
        Map<String, dynamic>.from(sellerJson),
      );

      state = state.copyWith(
        loading: false,
        seller: seller,
        isFollowing: seller.isFollowing,
      );
    });
  }

  /// TOGGLE FOLLOW
  Future<String?> toggleFollow() async {
    if (state.followingLoading) return null;

    final current = state.isFollowing ?? state.seller?.isFollowing ?? false;
    final next = !current;

    final sellerBefore = state.seller;
    final controller = ref.read(sellerControllerProvider);

    state = state.copyWith(followingLoading: true, isFollowing: next);

    final res = await controller.toggleFollow(sellerId: sellerId);

    return res.fold(
      (f) {
        state = state.copyWith(
          followingLoading: false,
          isFollowing: current,
          seller: sellerBefore,
        );

        return f.message;
      },
      (s) async {
        state = state.copyWith(followingLoading: false, isFollowing: next);

        await load();

        return null;
      },
    );
  }

  /// UPDATE SELLER PROFILE
  Future<String?> updateSellerProfile({
    String? businessCategory,
    String? aboutBusiness,
    String? businessAddress,
    String? shopBanner,
    List<Map<String, dynamic>>? operatingHours,
  }) async {
    if (state.updating) return null;

    final controller = ref.read(sellerControllerProvider);
    final previousSeller = state.seller;

    final optimisticSeller = previousSeller?.copyWith(
      businessCategory: businessCategory,
      aboutBusiness: aboutBusiness,
      businessAddress: businessAddress,
      shopBanner: shopBanner,
      operatingHours: operatingHours,
    );

    state = state.copyWith(
      updating: true,
      error: null,
      seller: optimisticSeller,
    );

    final res = await controller.updateSellerProfile(
      businessCategory: businessCategory,
      aboutBusiness: aboutBusiness,
      businessAddress: businessAddress,
      shopBanner: shopBanner,
      operatingHours: operatingHours,
    );

    return res.fold(
      (failure) {
        state = state.copyWith(
          updating: false,
          error: failure.message,
          seller: previousSeller,
        );

        return failure.message;
      },
      (_) async {
        state = state.copyWith(updating: false, error: null);

        await load();

        return null;
      },
    );
  }
}
