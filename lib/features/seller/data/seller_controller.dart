import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/seller/data/seller_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellerControllerProvider = Provider<SellerController>((ref) {
  return SellerController(ref.read(sellerApiProvider));
});

class SellerController {
  SellerController(this._api);

  final SellerApi _api;

  /// GET SELLER PROFILE
  Future<Either<Failure, Map<String, dynamic>>> getSeller({
    required String sellerId,
  }) {
    return _api.getSellerProfile(sellerId: sellerId);
  }

  /// FOLLOW / UNFOLLOW SELLER
  Future<Either<Failure, Map<String, dynamic>>> toggleFollow({
    required String sellerId,
  }) {
    return _api.toggleFollow(sellerId: sellerId);
  }
}
