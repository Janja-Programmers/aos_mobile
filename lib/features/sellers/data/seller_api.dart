import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellerApiProvider = Provider<SellerApi>((ref) {
  return SellerApi(ref.read(apiClientProvider));
});

class SellerApi {
  SellerApi(this._client);
  final ApiClient _client;

  Dio get _dio => _client.dio;

  /// GET SELLER PROFILE
  Future<Either<Failure, Map<String, dynamic>>> getSellerProfile({
    required String sellerId,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.getSellerEndpoint,
        queryParameters: {'seller': sellerId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch seller profile.'));
    }
  }

  /// FOLLOW / UNFOLLOW SELLER
  Future<Either<Failure, Map<String, dynamic>>> toggleFollow({
    required String sellerId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.toggleFollowEndpoint,
        data: {'target_user': sellerId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to toggle follow.'));
    }
  }

  /// UPDATE SELLER PROFILE
  Future<Either<Failure, Map<String, dynamic>>> updateSeller({
    String? businessCategory,
    String? aboutBusiness,
    String? businessAddress,
    String? shopBanner,
    List<Map<String, dynamic>>? operatingHours,
  }) async {
    try {
      final data = <String, dynamic>{
        if (businessCategory != null && businessCategory.trim().isNotEmpty)
          'business_category': businessCategory.trim(),

        if (aboutBusiness != null && aboutBusiness.trim().isNotEmpty)
          'about_business': aboutBusiness.trim(),

        if (businessAddress != null && businessAddress.trim().isNotEmpty)
          'business_address': businessAddress.trim(),

        if (shopBanner != null && shopBanner.trim().isNotEmpty)
          'shop_banner_media': shopBanner.trim(),

        'operating_hours': ?operatingHours,
      };

      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.updateMySellerEndpoint,
        data: data,
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final payload = unwrapped.rightOrNull ?? const <String, dynamic>{};
      if (payload['ok'] == false || payload['error'] != null) {
        return Either.left(Failure.fromServerPayload(payload));
      }

      return Either.right(payload);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update seller profile.'));
    }
  }

  /// LIST SELLERS
  Future<Either<Failure, Map<String, dynamic>>> listSellers({
    String? search,
    String? category,
    int? isVerified,
    String? sellerType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        'is_verified': ?isVerified,
        if (sellerType != null && sellerType.trim().isNotEmpty)
          'seller_type': sellerType.trim(),
      };

      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.listSellersEndpoint,
        data: data,
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch sellers.'));
    }
  }
}
