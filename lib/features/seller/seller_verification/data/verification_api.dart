import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

final verificationApiProvider = Provider<VerificationApi>((ref) {
  return VerificationApi(ref.read(apiClientProvider));
});

class VerificationApi {
  VerificationApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  /// SUBMIT VERIFICATION
  Future<Either<Failure, Map<String, dynamic>>> submitVerification({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.submitVerificationEndpoint,
        data: payload,
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure("Failed to submit verification."));
    }
  }

  /// UPDATE SELLER
  Future<Either<Failure, Map<String, dynamic>>> updateMySeller({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.put(
        ApiEndpoints.updateMySellerEndpoint,
        data: payload,
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure("Failed to update seller profile."));
    }
  }

  /// GET SELLER STATUS
  Future<Either<Failure, Map<String, dynamic>>> getMySellerStatus() async {
    try {
      final res = await _dio.get(ApiEndpoints.getMySellerStatusEndpoint);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure("Failed to fetch seller status."));
    }
  }

  /// GET MY VERIFICATION
  Future<Either<Failure, Map<String, dynamic>>> getMyVerification() async {
    try {
      final res = await _dio.get(ApiEndpoints.getMyVerificationEndpoint);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure("Failed to fetch verification status."));
    }
  }
}
