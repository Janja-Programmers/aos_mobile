import 'dart:io';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/files/domain/upload_file.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';

class FilesApi {
  FilesApi(this._client);
  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Either<Failure, UploadedFile>> uploadMedia({
    required File file,
  }) async {
    try {
      final filename = file.path.split(Platform.pathSeparator).last;

      final form = FormData.fromMap(<String, Object?>{
        'file': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
      });

      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.uploadFileEndpoint,
        data: form,
      );

      final body = res.data ?? <String, dynamic>{};
      final message = body['message'];

      if (message is Map) {
        final msg = asJsonMap(message);

        final url = (msg['file_url'] ?? '').toString();
        final fileId = (msg['name'] ?? '').toString();

        if (url.isNotEmpty && fileId.isNotEmpty) {
          return Either.right(UploadedFile(fileId: fileId, url: url));
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
      await _dio.post<Map<String, dynamic>>(
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

  Future<Either<Failure, Map<String, dynamic>>> searchAdByImage({
    required File file,
  }) async {
    try {
      if (!file.existsSync()) {
        return Either.left(const Failure('File does not exist.'));
      }

      final filename = file.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap(<String, Object?>{
        'image': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
      });

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.searchAdByImageEndpoint,
        data: formData,
      );

      return unwrapFrappe(response);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(const Failure('Failed to upload file.'));
    }
  }

  Future<Either<Failure, UploadedFile>> removeBackground({
    required String fileId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.removeBackgroundEndpoint,
        queryParameters: {'file_id': fileId},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final data = result.rightOrNull!;
      final inner = asJsonMap(data['data']);

      final url = (inner['file_url'] ?? '').toString();
      final newFileId = (inner['file_id'] ?? '').toString();

      if (url.isEmpty || newFileId.isEmpty) {
        return Either.left(const Failure('Invalid response'));
      }

      return Either.right(UploadedFile(fileId: newFileId, url: url));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to remove background.'));
    }
  }
}
