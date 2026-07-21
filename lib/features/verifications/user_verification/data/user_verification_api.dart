import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userVerificationApiProvider = Provider<UserVerificationApi>((ref) {
  return UserVerificationApi(ref.read(apiClientProvider));
});

class UserVerificationApi {
  const UserVerificationApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Either<Failure, Map<String, dynamic>>> getMyUserVerification() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.getMyVerificationEndpoint,
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Failed to fetch identity verification status.'),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> submitUserVerification({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.submitVerificationEndpoint,
        data: payload,
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to submit verification.'));
    }
  }
}
