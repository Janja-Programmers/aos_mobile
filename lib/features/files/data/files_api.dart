import 'dart:io';

import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class FilesApi {
  FilesApi(this._client);
  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Either<Failure, Map<String, String>>> uploadMedia({
    required File file,
  }) async {
    try {
      final filename = file.path.split(Platform.pathSeparator).last;

      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
      });

      final res = await _dio.post(ApiEndpoints.uploadFileEndpoint, data: form);

      final body = res.data;

      if (body is Map && body['message'] is Map) {
        final msg = Map<String, dynamic>.from(body['message']);

        final url = (msg['file_url'] ?? '').toString();
        final fileId = (msg['name'] ?? '').toString();

        if (url.isNotEmpty && fileId.isNotEmpty) {
          return Either.right({'url': url, 'fileId': fileId});
        }
      }

      return Either.left(const Failure('Failed to upload file.'));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to upload file.'));
    }
  }

  Future<Either<Failure, bool>> deleteFile({required String fileId}) async {
    try {
      await _dio.post(
        ApiEndpoints.deleteFileEndpoint,
        queryParameters: {'file_id': fileId},
      );
      return Either.right(true);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ad details.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> removeBackground({
    required String fileId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.removeBackgroundEndpoint,
        queryParameters: {'file_id': fileId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to remove background.'));
    }
  }
}
