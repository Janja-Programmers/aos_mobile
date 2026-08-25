import 'dart:io';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';

enum MediaUploadStage { initializing, uploading, confirming }

class MediaUploadApi {
  MediaUploadApi(this._client, {Dio? uploadDio})
    : _uploadDio =
          uploadDio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(minutes: 15),
            ),
          );

  final ApiClient _client;
  final Dio _uploadDio;

  Future<Either<Failure, MediaUploadResult>> uploadMedia({
    required File file,
    required String purpose,
    String? contentType,
    String? idempotencyKey,
    CancelToken? cancelToken,
    void Function(MediaUploadStage stage)? onStage,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final prepared = _prepareFile(file, contentType: contentType);
      if (prepared == null) {
        return Either.left(const Failure('File does not exist.'));
      }
      if (prepared.sizeBytes <= 0) {
        return Either.left(const Failure('File is empty.'));
      }

      onStage?.call(MediaUploadStage.initializing);
      final init = await initUpload(
        purpose: purpose,
        filename: prepared.filename,
        contentType: prepared.contentType,
        sizeBytes: prepared.sizeBytes,
        idempotencyKey: idempotencyKey,
      );

      if (init.isLeft) {
        return Either.left(init.leftOrNull!);
      }

      final initData = init.rightOrNull!;
      if (initData.mediaId.isEmpty || initData.uploadUrl.isEmpty) {
        return Either.left(const Failure('Upload could not be initialized.'));
      }

      onStage?.call(MediaUploadStage.uploading);
      final putResult = await putToMinio(
        file: file,
        init: initData,
        contentType: prepared.contentType,
        sizeBytes: prepared.sizeBytes,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      if (putResult.isLeft) {
        return Either.left(putResult.leftOrNull!);
      }

      onStage?.call(MediaUploadStage.confirming);
      return confirmUpload(mediaId: initData.mediaId);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } on FileSystemException {
      return Either.left(const Failure('Could not read selected file.'));
    } catch (_) {
      return Either.left(const Failure('Failed to upload media.'));
    }
  }

  Future<Either<Failure, MediaUploadInitResponse>> initUpload({
    required String purpose,
    required String filename,
    required String contentType,
    required int sizeBytes,
    String? idempotencyKey,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.initMediaUploadEndpoint,
        data: {
          'purpose': purpose,
          'filename': filename,
          'content_type': contentType,
          'size_bytes': sizeBytes,
          'filesize': sizeBytes,
          if (idempotencyKey?.trim().isNotEmpty ?? false)
            'idempotency_key': idempotencyKey!.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final parsed = MediaUploadInitResponse.fromJson(data);

        if (parsed.mediaId.isEmpty || parsed.uploadUrl.isEmpty) {
          return Either.left(
            const Failure('Invalid upload initialization response.'),
          );
        }

        return Either.right(parsed);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to initialize upload.'));
    }
  }

  Future<Either<Failure, void>> putToMinio({
    required File file,
    required MediaUploadInitResponse init,
    required String contentType,
    required int sizeBytes,
    CancelToken? cancelToken,
    void Function(MediaUploadStage stage)? onStage,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final uri = Uri.tryParse(init.uploadUrl);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        return Either.left(const Failure('Invalid upload URL.'));
      }

      final headers = <String, Object?>{
        ...init.uploadHeaders,
        Headers.contentLengthHeader: sizeBytes,
      };

      if (!headers.keys.any((key) => key.toLowerCase() == 'content-type')) {
        headers[Headers.contentTypeHeader] = contentType;
      }

      await _uploadDio.putUri<Object?>(
        uri,
        data: file.openRead(),
        options: Options(
          headers: headers,
          contentType: contentType,
          responseType: ResponseType.plain,
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } on FileSystemException {
      return Either.left(const Failure('Could not read selected file.'));
    } catch (_) {
      return Either.left(const Failure('Failed to upload media bytes.'));
    }
  }

  Future<Either<Failure, MediaUploadResult>> confirmUpload({
    required String mediaId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.confirmMediaUploadEndpoint,
        data: {'media_id': mediaId},
      );

      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final parsed = MediaUploadResult.fromJson(data);

        if (parsed.mediaId.isEmpty) {
          return Either.left(const Failure('Invalid upload confirmation.'));
        }

        return Either.right(parsed);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to confirm upload.'));
    }
  }

  Future<Either<Failure, bool>> deleteMedia({required String mediaId}) async {
    try {
      await _client.post(
        ApiEndpoints.deleteMediaEndpoint,
        data: {'media_id': mediaId},
      );
      return Either.right(true);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to delete media.'));
    }
  }

  Future<Either<Failure, MediaUploadResult>> removeBackground({
    required String mediaId,
    String? resultPurpose,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.removeBackgroundEndpoint,
        data: {
          'media_id': mediaId,
          if (resultPurpose != null && resultPurpose.trim().isNotEmpty)
            'result_purpose': resultPurpose.trim(),
        },
      );

      final result = unwrapFrappe(res);
      return result.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final parsed = MediaUploadResult.fromJson(data);

        if (parsed.mediaId.isEmpty) {
          return Either.left(const Failure('Invalid background result.'));
        }

        return Either.right(parsed);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to remove background.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> searchAdByImage({
    required File file,
  }) async {
    try {
      if (!file.existsSync()) {
        return Either.left(const Failure('File does not exist.'));
      }

      final filename = _filenameFromPath(file.path);
      final formData = FormData.fromMap(<String, Object?>{
        'image': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
      });

      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.searchAdByImageEndpoint,
        data: formData,
      );

      return unwrapFrappe(response);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to search by image.'));
    }
  }
}

_PreparedUploadFile? _prepareFile(File file, {String? contentType}) {
  if (!file.existsSync()) {
    return null;
  }

  final filename = _filenameFromPath(file.path);
  final sizeBytes = file.lengthSync();
  final requestedContentType = contentType?.trim() ?? '';
  final effectiveContentType = requestedContentType.isNotEmpty
      ? requestedContentType
      : _contentTypeForFilename(filename);

  return _PreparedUploadFile(
    filename: filename,
    sizeBytes: sizeBytes,
    contentType: effectiveContentType,
  );
}

String _filenameFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final parts = normalized.split('/');
  final filename = parts.isEmpty ? '' : parts.last.trim();
  return filename.isEmpty ? 'upload.bin' : filename;
}

String _contentTypeForFilename(String filename) {
  final clean = filename.toLowerCase().split('?').first;
  final dot = clean.lastIndexOf('.');
  final ext = dot == -1 ? '' : clean.substring(dot + 1);

  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'svg':
      return 'image/svg+xml';
    case 'mp4':
    case 'm4v':
      return 'video/mp4';
    case 'mov':
      return 'video/quicktime';
    case 'mp3':
      return 'audio/mpeg';
    case 'm4a':
      return 'audio/mp4';
    case 'aac':
      return 'audio/aac';
    case 'wav':
      return 'audio/wav';
    case 'ogg':
    case 'opus':
      return 'audio/ogg';
    case 'pdf':
      return 'application/pdf';
  }

  return 'application/octet-stream';
}

class _PreparedUploadFile {
  const _PreparedUploadFile({
    required this.filename,
    required this.sizeBytes,
    required this.contentType,
  });

  final String filename;
  final int sizeBytes;
  final String contentType;
}
