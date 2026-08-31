import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/domain/profile_update_request.dart';
import 'package:dio/dio.dart';

/// Accounts/Profile APIs.
class AccountsApi {
  AccountsApi(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getProfile({
    String? targetUser,
  }) async {
    try {
      final String cleanTarget = targetUser?.trim() ?? '';
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.getProfileEndpoint,
        queryParameters: <String, dynamic>{
          if (cleanTarget.isNotEmpty) 'target_user': cleanTarget,
        },
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateProfile({
    String? fullName,
    String? userImage,
    String? userImageMedia,
    String? bio,
  }) async {
    try {
      final ProfileUpdateRequest request = ProfileUpdateRequest(
        fullName: fullName,
        userImage: userImage,
        userImageMedia: userImageMedia,
        bio: bio,
      );
      final String? validationMessage =
          request.fullNameValidationMessage ??
          request.bioValidationMessage ??
          request.avatarValidationMessage;
      if (validationMessage != null) {
        return Either.left(
          Failure(validationMessage, type: FailureType.validation),
        );
      }
      final Map<String, dynamic> data = request.toJson();
      if (data.isEmpty) {
        return Either.left(
          const Failure(
            'At least one profile field is required.',
            type: FailureType.validation,
          ),
        );
      }

      final String endpoint = _asFrappeV2Method(
        ApiEndpoints.updateProfileEndpoint,
      );
      final res = await _client.dio.post<Map<String, dynamic>>(
        endpoint,
        data: data,
      );

      final Either<Failure, Map<String, dynamic>> unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final Map<String, dynamic> response =
          unwrapped.rightOrNull ?? const <String, dynamic>{};
      final Map<String, dynamic> nested = asJsonMap(response['data']);
      final Map<String, dynamic> payload =
          nested.containsKey('ok') || nested.containsKey('error')
          ? nested
          : response;

      if (payload['ok'] == false || _hasServerError(payload)) {
        return Either.left(
          Failure.fromServerPayload(
            payload,
            statusCode: res.statusCode,
            fallbackMessage: 'Failed to update profile.',
          ),
        );
      }

      return Either.right(payload);
    } on DioException catch (e) {
      return Either.left(_mapProfileUpdateDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  static Failure _mapProfileUpdateDioException(DioException error) {
    final Response<dynamic>? response = error.response;
    final Map<String, dynamic> root = asJsonMap(response?.data);
    final Map<String, dynamic> nested = asJsonMap(root['data']);
    if (nested.containsKey('ok') || nested.containsKey('error')) {
      return Failure.fromServerPayload(
        nested,
        statusCode: response?.statusCode,
        fallbackMessage: 'Failed to update profile.',
      );
    }
    return mapDioException(error);
  }

  static String _asFrappeV2Method(String endpoint) {
    const String v1Prefix = '/api/method/';
    const String v2Prefix = '/api/v2/method/';
    if (endpoint.startsWith(v2Prefix)) return endpoint;
    if (endpoint.startsWith(v1Prefix)) {
      return '$v2Prefix${endpoint.substring(v1Prefix.length)}';
    }
    return endpoint;
  }

  static bool _hasServerError(Map<String, dynamic> payload) {
    final String error = payload['error']?.toString().trim() ?? '';
    return error.isNotEmpty && error.toLowerCase() != 'null';
  }
}
