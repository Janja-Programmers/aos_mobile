import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';

/// Accounts/Profile APIs.
///
/// Backend:
///  - aos.api.accounts.get_profile
///  - aos.api.accounts.update_profile
class AccountsApi {
  AccountsApi(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.getProfileEndpoint,
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
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (userImage != null) data['user_image'] = userImage;
      if (userImageMedia != null) {
        data['profile_image_media'] = userImageMedia;
      }
      if (bio != null) data['bio'] = bio;

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
