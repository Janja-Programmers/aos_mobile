import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/seller/data/seller_api.dart';

class SellerController {
  SellerController(this._api);

  final SellerApi _api;

  Future<Either<Failure, Map<String, dynamic>>> getSeller({
    required String sellerId,
  }) {
    return _api.getSellerProfile(sellerId: sellerId);
  }

  Future<Either<Failure, Map<String, dynamic>>> toggleFollow({
    required String sellerId,
  }) {
    return _api.toggleFollow(sellerId: sellerId);
  }

  Future<Either<Failure, Map<String?, dynamic>>> updateSellerProfile({
    String? shopName,
    String? aboutShop,
    String? avatar,
    String? banner,
  }) async {
    return _api.updateSeller(
      shopName: shopName,
      aboutShop: aboutShop,
      avatar: avatar,
      banner: banner,
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> listSellers({
    String? search,
    String? category,
    int? isVerified,
    String? sellerType,
    int limit = 20,
    int offset = 0,
  }) {
    return _api.listSellers(
      search: search,
      category: category,
      isVerified: isVerified,
      sellerType: sellerType,
      limit: limit,
      offset: offset,
    );
  }
}
