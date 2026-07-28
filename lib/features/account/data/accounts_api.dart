import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
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

      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.updateProfileEndpoint,
        data: data,
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }
}
