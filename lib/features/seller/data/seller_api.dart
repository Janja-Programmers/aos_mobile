import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

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
      final res = await _dio.get(
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
      final res = await _dio.post(
        ApiEndpoints.toggleSellerEndpoint,
        data: {'seller': sellerId},
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
    String? shopName,
    String? aboutShop,
    String? avatar,
    String? banner,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.updateMySellerEndpoint,
      data: {
        'shop_name': ?shopName,
        'about_shop': ?aboutShop,
        'avatar': ?avatar,
        'shop_banner': ?banner,
      },
    );

    return Right(res.data['message']);
  }
}
