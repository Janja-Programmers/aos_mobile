import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class UserPreferenceApi {
  UserPreferenceApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getMyPreferences() async {
    try {
      final res = await _client.get(ApiEndpoints.getMyPreferencesEndpoint);
      return unwrapFrappe(res);
    } catch (_) {
      return Either.left(const Failure('Failed to load preferences.'));
    }
  }

  Future<Either<Failure, void>> updateMyPreferences(
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.updatePreferencesEndpoint,
        data: data,
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      return Either.right(null);
    } catch (_) {
      return Either.left(const Failure('Failed to update preferences.'));
    }
  }
}
