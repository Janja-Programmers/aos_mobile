import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/preferences/models/user_preference_field.dart';
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

  Future<Either<Failure, Map<String, dynamic>>> updateMyPreference({
    required UserPreferenceField field,
    required String canonicalId,
  }) async {
    final value = canonicalId.trim();
    if (value.isEmpty) {
      return Either.left(
        const Failure(
          'A preference value is required.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.updatePreferencesEndpoint,
        data: <String, dynamic>{field.wireName: value},
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final response = unwrapped.rightOrNull ?? const <String, dynamic>{};
      final nested = asJsonMap(response['data']);
      final payload = nested.containsKey('ok') || nested.containsKey('error')
          ? nested
          : response;

      if (payload['ok'] != true) {
        return Either.left(
          Failure.fromServerPayload(
            payload,
            statusCode: res.statusCode,
            fallbackMessage: 'Failed to update preferences.',
          ),
        );
      }

      final preferences = asJsonMap(payload['data']);
      if (preferences.isEmpty) {
        return Either.left(
          const Failure(
            'The updated preferences are missing from the response.',
            type: FailureType.parse,
          ),
        );
      }

      return Either.right(preferences);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update preferences.'));
    }
  }
}
