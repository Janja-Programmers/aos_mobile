import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/data/models/init_short_upload_result.dart';

class ShortsUploadApi {
  final ApiClient _client;

  ShortsUploadApi(this._client);

  // ───────────── INIT UPLOAD ─────────────

  Future<Either<Failure, InitShortUploadResult>> initUpload({
    required String filename,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.initShortUpload,
        data: {'filename': filename},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};

        return Either.right(
          InitShortUploadResult(
            shortId: ShortId(data['short_id'] as String),
            uploadUrl: data['upload_url'] as String,
            fileKey: data['file_key'] as String?,
          ),
        );
      });
    } on DioException catch (e, st) {
      appLogger.i(
        'ShortsUploadApi.initUpload DioException | message=${e.message} | status=${e.response?.statusCode} | data=${e.response?.data}',
      );
      appLogger.e(
        'ShortsUploadApi.initUpload DioException stacktrace',
        error: e,
        stackTrace: st,
      );
      return Either.left(mapDioException(e));
    } catch (e, st) {
      appLogger.i('ShortsUploadApi.initUpload unexpected error | error=$e');
      appLogger.e(
        'ShortsUploadApi.initUpload unexpected stacktrace',
        error: e,
        stackTrace: st,
      );
      return Either.left(const Failure('Unexpected error initializing upload'));
    }
  }

  // ───────────── CONFIRM UPLOAD ─────────────

  Future<Either<Failure, void>> confirmUpload({required String shortId}) async {
    try {
      appLogger.i('ShortsUploadApi.confirmUpload request | shortId=$shortId');

      final res = await _client.post(
        ApiEndpoints.confirmShortUpload,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      appLogger.i('ShortsUploadApi.confirmUpload success | shortId=$shortId');

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'];
        appLogger.w("Confrim upload ${data.toString()}");
        return Either.right(null);
      });
    } on DioException catch (e, st) {
      appLogger.i(
        'ShortsUploadApi.confirmUpload DioException | shortId=$shortId | message=${e.message} | status=${e.response?.statusCode} | data=${e.response?.data}',
      );
      appLogger.e(
        'ShortsUploadApi.confirmUpload DioException stacktrace',
        error: e,
        stackTrace: st,
      );
      return Either.left(mapDioException(e));
    } catch (e, st) {
      appLogger.i(
        'ShortsUploadApi.confirmUpload unexpected error | shortId=$shortId | error=$e',
      );
      appLogger.e(
        'ShortsUploadApi.confirmUpload unexpected stacktrace',
        error: e,
        stackTrace: st,
      );
      return Either.left(const Failure('Unexpected error confirming upload'));
    }
  }

  // ───────────── UPDATE METADATA ─────────────

  Future<Either<Failure, void>> updateMetadata({
    required String adId,
    required String shortId,
    String? caption,
    List<String>? hashtags,
  }) async {
    try {
      final data = <String, dynamic>{
        'ad_id': adId,
        'short_id': shortId,
        if (caption != null && caption.trim().isNotEmpty) 'caption': caption,
        if (hashtags != null && hashtags.isNotEmpty) 'hashtags': hashtags,
      };

      appLogger.i(
        'ShortsUploadApi.updateMetadata request | shortId=$shortId | data=$data',
      );

      final res = await _client.post(
        ApiEndpoints.updateShortMetadata,
        data: data,
      );

      final unwrapped = unwrapFrappe(res);

      appLogger.i('ShortsUploadApi.updateMetadata success | shortId=$shortId');

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e, st) {
      appLogger.i(
        'ShortsUploadApi.updateMetadata DioException | shortId=$shortId | message=${e.message} | status=${e.response?.statusCode} | data=${e.response?.data}',
      );
      appLogger.e(
        'ShortsUploadApi.updateMetadata DioException stacktrace',
        error: e,
        stackTrace: st,
      );
      return Either.left(mapDioException(e));
    } catch (e, st) {
      appLogger.i(
        'ShortsUploadApi.updateMetadata unexpected error | shortId=$shortId | error=$e',
      );
      appLogger.e(
        'ShortsUploadApi.updateMetadata unexpected stacktrace',
        error: e,
        stackTrace: st,
      );
      return Either.left(const Failure('Unexpected error updating metadata'));
    }
  }
}
