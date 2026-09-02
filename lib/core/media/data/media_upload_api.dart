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

  static const String _multipartStatusPath =
      '/api/method/aos.api.v1.media.multipart_status';
  static const String _multipartPartUrlsPath =
      '/api/method/aos.api.v1.media.multipart_part_urls';
  static const String _completeMultipartPath =
      '/api/method/aos.api.v1.media.complete_multipart_upload';
  static const String _abortMultipartPath =
      '/api/method/aos.api.v1.media.abort_multipart_upload';

  final ApiClient _client;
  final Dio _uploadDio;

  Future<Either<Failure, MediaUploadResult>> uploadMedia({
    required File file,
    required String purpose,
    String? contentType,
    double? durationSeconds,
    String? uploadMode,
    String? idempotencyKey,
    CancelToken? cancelToken,
    void Function(MediaUploadStage stage)? onStage,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    MediaUploadInitResponse? initialized;
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
        durationSeconds: durationSeconds,
        uploadMode: uploadMode,
        idempotencyKey: idempotencyKey,
      );

      switch (init) {
        case Left<Failure, MediaUploadInitResponse>(value: final failure):
          return Either.left(failure);
        case Right<Failure, MediaUploadInitResponse>(value: final value):
          initialized = value;
      }

      onStage?.call(MediaUploadStage.uploading);
      if (initialized.isMultipart) {
        final uploaded = await _uploadMultipart(
          file: file,
          init: initialized,
          sizeBytes: prepared.sizeBytes,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
        );
        if (uploaded.isLeft) return Either.left(uploaded.leftOrNull!);
        onStage?.call(MediaUploadStage.confirming);
        return uploaded;
      }

      final putResult = await putToMinio(
        file: file,
        init: initialized,
        contentType: prepared.contentType,
        sizeBytes: prepared.sizeBytes,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      if (putResult.isLeft) {
        if (cancelToken?.isCancelled ?? false) {
          await deleteMedia(mediaId: initialized.mediaId);
        }
        return Either.left(putResult.leftOrNull!);
      }

      onStage?.call(MediaUploadStage.confirming);
      return confirmUpload(mediaId: initialized.mediaId);
    } on DioException catch (e) {
      if (cancelToken?.isCancelled ?? false) {
        final current = initialized;
        if (current != null && current.isMultipart) {
          await _abortMultipartUpload(current.mediaId);
        }
      }
      return Either.left(mapDioException(e));
    } on FileSystemException {
      return Either.left(const Failure('Could not read selected file.'));
    } catch (_) {
      if (cancelToken?.isCancelled ?? false) {
        final current = initialized;
        if (current != null && current.isMultipart) {
          await _abortMultipartUpload(current.mediaId);
        }
      }
      return Either.left(const Failure('Failed to upload media.'));
    }
  }

  Future<Either<Failure, MediaUploadInitResponse>> initUpload({
    required String purpose,
    required String filename,
    required String contentType,
    required int sizeBytes,
    double? durationSeconds,
    String? uploadMode,
    String? idempotencyKey,
  }) async {
    try {
      final duration = durationSeconds;
      final mode = uploadMode?.trim().toLowerCase();
      final res = await _client.post(
        ApiEndpoints.initMediaUploadEndpoint,
        data: {
          'purpose': purpose,
          'filename': filename,
          'content_type': contentType,
          'size_bytes': sizeBytes,
          'filesize': sizeBytes,
          if (duration != null && duration > 0) 'duration_seconds': duration,
          if (mode != null && mode.isNotEmpty) 'upload_mode': mode,
          if (idempotencyKey?.trim().isNotEmpty ?? false)
            'idempotency_key': idempotencyKey!.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final parsed = MediaUploadInitResponse.fromJson(data);
        if (parsed.mediaId.isEmpty) {
          return Either.left(
            const Failure('Invalid upload initialization response.'),
          );
        }
        if (parsed.isMultipart) {
          if (parsed.multipart?.isValid != true) {
            return Either.left(
              const Failure('Invalid multipart upload contract.'),
            );
          }
        } else if (!parsed.isDirect || parsed.uploadUrl.isEmpty) {
          return Either.left(const Failure('Invalid direct upload contract.'));
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

  Future<Either<Failure, MediaUploadResult>> _uploadMultipart({
    required File file,
    required MediaUploadInitResponse init,
    required int sizeBytes,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final descriptor = init.multipart;
    if (descriptor == null || !descriptor.isValid) {
      return Either.left(const Failure('Invalid multipart upload contract.'));
    }

    for (var reconciliation = 0; reconciliation < 8; reconciliation += 1) {
      if (cancelToken?.isCancelled ?? false) {
        await _abortMultipartUpload(init.mediaId);
        return Either.left(const Failure('Upload cancelled.'));
      }

      final statusResult = await _multipartStatus(init.mediaId);
      if (statusResult.isLeft) return Either.left(statusResult.leftOrNull!);
      final status = statusResult.rightOrNull!;
      final reconciledBytes = status.uploadedBytes.clamp(0, sizeBytes).toInt();
      onSendProgress?.call(reconciledBytes, sizeBytes);
      if (status.state == 'failed') {
        return Either.left(
          Failure(
            status.failureCode.isEmpty
                ? 'Multipart upload failed.'
                : 'Multipart upload failed (${status.failureCode}).',
          ),
        );
      }
      if (status.state == 'completed' ||
          status.state == 'storage_completed' ||
          status.completeReady) {
        return _completeMultipartUpload(init.mediaId);
      }
      if (status.retryParts.isEmpty) {
        return Either.left(
          const Failure(
            'Multipart upload could not determine remaining parts.',
          ),
        );
      }

      final partUrls = await _multipartPartUrlsForRetry(
        mediaId: init.mediaId,
        retryParts: status.retryParts,
        descriptor: descriptor,
      );
      if (partUrls.isLeft) return Either.left(partUrls.leftOrNull!);
      final parts = partUrls.rightOrNull!;
      if (parts.isEmpty) {
        return Either.left(const Failure('No upload part URLs were returned.'));
      }

      final uploadParts = await _uploadMultipartParts(
        file: file,
        parts: parts,
        sizeBytes: sizeBytes,
        uploadedBytes: status.uploadedBytes,
        maxParallel: descriptor.maxParallelParts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      if (uploadParts.isLeft) {
        if (cancelToken?.isCancelled ?? false) {
          await _abortMultipartUpload(init.mediaId);
          return Either.left(uploadParts.leftOrNull!);
        }
        final failure = uploadParts.leftOrNull!;
        if (_shouldRefreshMultipartPartUrls(failure)) {
          // Signed UploadPart URLs are intentionally short-lived. Reconcile
          // storage truth and request fresh URLs instead of treating an
          // expired signature as a terminal upload failure.
          continue;
        }
        if (reconciliation < 2 && _shouldReconcileMultipartFailure(failure)) {
          // A transient part failure may happen after storage accepted other
          // in-flight parts. Re-read backend/storage truth before failing the
          // whole user-visible upload. The bounded reconciliation count avoids
          // turning a persistent outage into an unbounded retry loop.
          continue;
        }
        return Either.left(failure);
      }
    }

    return Either.left(
      const Failure('Multipart upload did not converge after reconciliation.'),
    );
  }

  Future<Either<Failure, _MultipartStatus>> _multipartStatus(
    String mediaId,
  ) async {
    final result = await _postMediaControl(
      _multipartStatusPath,
      <String, dynamic>{'media_id': mediaId},
    );
    return result.fold(Either.left, (data) {
      final retryParts = _intList(data['retry_parts']);
      return Either.right(
        _MultipartStatus(
          state: asString(data['state']).trim().toLowerCase(),
          retryParts: retryParts,
          uploadedBytes: asInt(data['uploaded_bytes']),
          completeReady: asBool(data['complete_ready']),
          failureCode: asString(data['failure_code']),
        ),
      );
    });
  }

  Future<Either<Failure, List<_MultipartPartUrl>>> _multipartPartUrlsForRetry({
    required String mediaId,
    required List<int> retryParts,
    required MultipartUploadDescriptor descriptor,
  }) async {
    final sorted = retryParts.toSet().toList()..sort();
    final urls = <_MultipartPartUrl>[];
    var cursor = 0;
    while (cursor < sorted.length) {
      final first = sorted[cursor];
      var count = 1;
      while (cursor + count < sorted.length &&
          count < descriptor.partUrlBatchSize &&
          sorted[cursor + count] == first + count) {
        count += 1;
      }
      final result = await _postMediaControl(
        _multipartPartUrlsPath,
        <String, dynamic>{
          'media_id': mediaId,
          'start_part': first,
          'count': count,
        },
      );
      if (result.isLeft) return Either.left(result.leftOrNull!);
      final data = result.rightOrNull!;
      for (final row in asJsonMapList(data['parts'])) {
        final parsed = _MultipartPartUrl.fromJson(row);
        final part = parsed.copyWith(
          offsetBytes: (parsed.partNumber - 1) * descriptor.partSizeBytes,
        );
        if (part.isValid && sorted.contains(part.partNumber)) urls.add(part);
      }
      cursor += count;
    }
    return Either.right(urls);
  }

  Future<Either<Failure, void>> _uploadMultipartParts({
    required File file,
    required List<_MultipartPartUrl> parts,
    required int sizeBytes,
    required int uploadedBytes,
    required int maxParallel,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    var committedBytes = uploadedBytes.clamp(0, sizeBytes).toInt();
    final inFlight = <int, int>{};
    final parallel = maxParallel.clamp(1, 4).toInt();

    for (var start = 0; start < parts.length; start += parallel) {
      final end = (start + parallel).clamp(0, parts.length).toInt();
      final batch = parts.sublist(start, end);
      final results = await Future.wait<Either<Failure, void>>(
        batch.map((part) async {
          final result = await _putMultipartPartWithRetry(
            file: file,
            part: part,
            cancelToken: cancelToken,
            onSendProgress: (sent, _) {
              inFlight[part.partNumber] = sent;
              final current =
                  (committedBytes +
                          inFlight.values.fold<int>(
                            0,
                            (sum, value) => sum + value,
                          ))
                      .clamp(0, sizeBytes)
                      .toInt();
              onSendProgress?.call(current, sizeBytes);
            },
          );
          if (result.isRight) {
            committedBytes = (committedBytes + part.expectedSizeBytes)
                .clamp(0, sizeBytes)
                .toInt();
            inFlight.remove(part.partNumber);
            onSendProgress?.call(committedBytes, sizeBytes);
          }
          return result;
        }),
      );
      for (final result in results) {
        if (result.isLeft) return Either.left(result.leftOrNull!);
      }
    }
    return Either.right(null);
  }

  Future<Either<Failure, void>> _putMultipartPartWithRetry({
    required File file,
    required _MultipartPartUrl part,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final offset = part.offsetBytes;
    final end = offset + part.expectedSizeBytes;
    for (var attempt = 0; attempt < 3; attempt += 1) {
      if (cancelToken?.isCancelled ?? false) {
        return Either.left(const Failure('Upload cancelled.'));
      }
      try {
        await _uploadDio.putUri<Object?>(
          part.uri,
          data: file.openRead(offset, end),
          options: Options(
            headers: <String, Object?>{
              Headers.contentLengthHeader: part.expectedSizeBytes,
            },
            responseType: ResponseType.plain,
          ),
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
        );
        return Either.right(null);
      } on DioException catch (error) {
        if (CancelToken.isCancel(error)) {
          return Either.left(const Failure('Upload cancelled.'));
        }
        if (!_isTransientUploadError(error) || attempt == 2) {
          return Either.left(mapDioException(error));
        }
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (1 << attempt)),
        );
      } on FileSystemException {
        return Either.left(const Failure('Could not read selected file.'));
      }
    }
    return Either.left(const Failure('Failed to upload video part.'));
  }

  bool _shouldRefreshMultipartPartUrls(Failure failure) {
    return failure.statusCode == 401 || failure.statusCode == 403;
  }

  bool _shouldReconcileMultipartFailure(Failure failure) {
    final status = failure.statusCode;
    return failure.type == FailureType.network ||
        failure.type == FailureType.timeout ||
        failure.type == FailureType.rateLimited ||
        failure.type == FailureType.server ||
        status == 408 ||
        status == 429 ||
        (status != null && status >= 500);
  }

  bool _isTransientUploadError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 408 || status == 429 || (status != null && status >= 500)) {
      return true;
    }
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown;
  }

  Future<Either<Failure, MediaUploadResult>> _completeMultipartUpload(
    String mediaId,
  ) async {
    final result = await _postMediaControl(
      _completeMultipartPath,
      <String, dynamic>{'media_id': mediaId},
    );
    return result.fold(Either.left, (data) {
      final parsed = MediaUploadResult.fromJson(data);
      if (parsed.mediaId.isEmpty) {
        return Either.left(
          const Failure('Invalid multipart completion response.'),
        );
      }
      return Either.right(parsed);
    });
  }

  Future<void> _abortMultipartUpload(String mediaId) async {
    try {
      await _client.post(
        _abortMultipartPath,
        data: <String, dynamic>{'media_id': mediaId},
      );
    } on Object {
      // Best effort: backend cleanup independently expires abandoned sessions.
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _postMediaControl(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(path, data: data);
      final unwrapped = unwrapFrappe(response);
      return unwrapped.fold(
        Either.left,
        (payload) => Either.right(asJsonMap(payload['data'])),
      );
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } catch (_) {
      return Either.left(const Failure('Media upload request failed.'));
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
    int limit = 20,
  }) async {
    try {
      if (!file.existsSync()) {
        return Either.left(const Failure('File does not exist.'));
      }

      final filename = _filenameFromPath(file.path);
      final formData = FormData.fromMap(<String, Object?>{
        'image': await MultipartFile.fromFile(file.path, filename: filename),
        'limit': limit,
      });

      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.searchAdByImageEndpoint,
        data: formData,
      );

      return unwrapFrappe(response);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } on FileSystemException {
      return Either.left(const Failure('Could not read selected image.'));
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

class _MultipartStatus {
  const _MultipartStatus({
    required this.state,
    required this.retryParts,
    required this.uploadedBytes,
    required this.completeReady,
    required this.failureCode,
  });

  final String state;
  final List<int> retryParts;
  final int uploadedBytes;
  final bool completeReady;
  final String failureCode;
}

class _MultipartPartUrl {
  const _MultipartPartUrl({
    required this.partNumber,
    required this.expectedSizeBytes,
    required this.uri,
    required this.offsetBytes,
  });

  final int partNumber;
  final int expectedSizeBytes;
  final Uri uri;
  final int offsetBytes;

  bool get isValid =>
      partNumber > 0 &&
      expectedSizeBytes > 0 &&
      uri.hasScheme &&
      uri.host.isNotEmpty &&
      offsetBytes >= 0;

  _MultipartPartUrl copyWith({int? offsetBytes}) {
    return _MultipartPartUrl(
      partNumber: partNumber,
      expectedSizeBytes: expectedSizeBytes,
      uri: uri,
      offsetBytes: offsetBytes ?? this.offsetBytes,
    );
  }

  factory _MultipartPartUrl.fromJson(Map<String, dynamic> json) {
    final partNumber = asInt(json['part_number']);
    final expected = asInt(json['expected_size_bytes']);
    final rawUrl = asString(json['upload_url']);
    final uri = Uri.tryParse(rawUrl) ?? Uri();
    final offset = asInt(json['offset_bytes']);
    return _MultipartPartUrl(
      partNumber: partNumber,
      expectedSizeBytes: expected,
      uri: uri,
      offsetBytes: offset,
    );
  }
}

List<int> _intList(Object? value) {
  if (value is! List) return const <int>[];
  return value
      .map((item) {
        if (item is int) return item;
        if (item is num) return item.toInt();
        if (item is Map<Object?, Object?>) {
          return asInt(asJsonMap(item)['part_number']);
        }
        return int.tryParse(item?.toString() ?? '') ?? 0;
      })
      .where((item) => item > 0)
      .toList(growable: false);
}
