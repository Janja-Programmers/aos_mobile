import 'dart:io';

import 'package:dio/dio.dart';

import 'package:aos_mobile/core/api/api_client.dart';
import 'package:aos_mobile/core/api/api_endpoints.dart';
import 'package:aos_mobile/core/api/api_response.dart';
import 'package:aos_mobile/core/api/dio_failure_mapper.dart';
import 'package:aos_mobile/core/api/failure.dart';
import 'package:aos_mobile/core/utils/either.dart';

/// Accounts/Profile APIs.
///
/// Backend:
///  - aos.api.accounts.get_profile
///  - aos.api.accounts.update_profile
///  - upload_file (Frappe built-in)
class AccountsApi {
  AccountsApi(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.getProfileEndpoint);
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
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (userImage != null) data['user_image'] = userImage;

      final res = await _client.dio.post(
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

  /// Uploads a profile photo via Frappe built-in upload endpoint.
  ///
  /// Returns file_url on success.
  Future<Either<Failure, String>> uploadProfilePhoto({
    required File file,
    required String docname,
  }) async {
    try {
      final filename = file.path.split(Platform.pathSeparator).last;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
        'doctype': 'User',
        'docname': docname,
      });

      final res = await _client.dio.post(
        ApiEndpoints.uploadFileEndpoint,
        data: form,
        options: Options(
          // Let Dio set multipart boundaries.
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      // upload_file doesn't always follow our ok/data envelope, so parse directly.
      final body = res.data;
      if (body is Map && body['message'] is Map) {
        final msg = Map<String, dynamic>.from(body['message'] as Map);
        final url = (msg['file_url'] ?? '').toString();
        if (url.isNotEmpty) return Either.right(url);
      }
      return Either.left(const Failure('Failed to upload image.'));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }
}
