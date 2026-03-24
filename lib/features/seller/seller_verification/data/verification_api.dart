import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
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
    } catch (e) {
      return Either.left(const Failure("Failed to submit verification."));
    }
  }
}
