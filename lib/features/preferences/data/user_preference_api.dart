import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';

class UserPreferenceApi {
  UserPreferenceApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getMyPreferences() async {
    try {
      final res = await _client.get(ApiEndpoints.getMyPreferencesEndpoint);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load preferences.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateMyPreferences(
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.updatePreferencesEndpoint,
        data: data,
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final payload = unwrapped.rightOrNull ?? const <String, dynamic>{};
      if (payload['ok'] == false || payload['error'] != null) {
        return Either.left(Failure.fromServerPayload(payload));
      }

      return Either.right(asJsonMap(payload['data']));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update preferences.'));
    }
  }
}
