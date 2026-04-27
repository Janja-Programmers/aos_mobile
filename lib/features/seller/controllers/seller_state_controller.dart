import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/seller/controllers/seller_controller.dart';
import 'package:africaonlinestores/features/seller/controllers/seller_state.dart';
import 'package:africaonlinestores/features/seller/data/seller_api.dart';
import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';

/// API provider
final sellerApiProvider = Provider<SellerApi>((ref) {
  return SellerApi(ref.read(apiClientProvider));
});

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

  /// UPDATE SELLERPROFILE
  Future<String?> updateSellerProfile({
    String? shopName,
    String? aboutShop,
    String? avatar,
    String? banner,
  }) async {
    final controller = ref.read(sellerControllerProvider);

    state = state.copyWith(loading: true);

    final res = await controller.updateSellerProfile(
      shopName: shopName,
      aboutShop: aboutShop,
      avatar: avatar,
      banner: banner,
    );

    return res.fold(
      (failure) {
        state = state.copyWith(loading: false);
        return failure.message;
      },
      (data) {
        final updatedSeller = state.seller?.copyWith(
          shopName: data['shop_name'],
          aboutShop: data['about_shop'],
          avatar: data['avatar'],
          shopBanner: data['shop_banner'],
        );

        state = state.copyWith(loading: false, seller: updatedSeller);

        return null;
      },
    );
  }
}
