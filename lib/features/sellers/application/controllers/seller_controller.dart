import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/sellers/data/seller_api.dart';

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

  Future<Either<Failure, Map<String, dynamic>>> updateSellerProfile({
    String? businessCategory,
    String? aboutBusiness,
    String? businessAddress,
    String? shopBanner,
    List<Map<String, dynamic>>? operatingHours,
  }) async {
    return _api.updateSeller(
      businessCategory: businessCategory,
      aboutBusiness: aboutBusiness,
      businessAddress: businessAddress,
      shopBanner: shopBanner,
      operatingHours: operatingHours,
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
