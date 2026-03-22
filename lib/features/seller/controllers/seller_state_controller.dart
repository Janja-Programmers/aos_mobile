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
      final seller = AOSSellerProfile.fromJson(data['data']);
      state = state.copyWith(loading: false, seller: seller);
    });
  }

  /// TOGGLE FOLLOW
  Future<String?> toggleFollow() async {
    final controller = ref.read(sellerControllerProvider);

    state = state.copyWith(followingLoading: true);

    final res = await controller.toggleFollow(sellerId: sellerId);

    return res.fold(
      (f) {
        state = state.copyWith(followingLoading: false);
        return f.message;
      },
      (_) async {
        await load();
        state = state.copyWith(followingLoading: false);
        return null;
      },
    );
  }
}
