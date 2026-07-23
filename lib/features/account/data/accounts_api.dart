import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/account/domain/profile_update_request.dart';
import 'package:dio/dio.dart';

/// Accounts/Profile APIs.
///
/// Backend:
///  - aos.api.v1.accounts.get_profile
///  - aos.api.v1.accounts.update_profile
class AccountsApi {
  AccountsApi(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getProfile({
    String? targetUser,
  }) async {
    try {
      final String cleanTarget = targetUser?.trim() ?? '';
      final Response<Map<String, dynamic>> res = await _client.dio
          .get<Map<String, dynamic>>(
            ApiEndpoints.getProfileEndpoint,
            queryParameters: cleanTarget.isEmpty
                ? null
                : <String, dynamic>{'target_user': cleanTarget},
          );
      return unwrapFrappe(res);
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Exception {
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

      final Response<Map<String, dynamic>> res = await _client.dio
          .post<Map<String, dynamic>>(
            ApiEndpoints.updateProfileEndpoint,
            data: request.toJson(),
          );
      return unwrapFrappe(res);
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Exception {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }
}
