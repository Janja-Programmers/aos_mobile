import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class ShortsUploadApi {
  final ApiClient _client;

  ShortsUploadApi(this._client);

  Future<Either<Failure, Map<String, dynamic>>> initUpload({
    required String filename,
    required String contentType,
  }) async {
    try {
      appLogger.i(
        'ShortsUploadApi.initUpload request | filename=$filename | contentType=$contentType',
      );

      final res = await _client.dio.post(
        ApiEndpoints.initShortUpload,
        data: {'filename': filename},
      );

      appLogger.i('ShortsUploadApi.initUpload success');
      return unwrapFrappe(res);
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

  Future<Either<Failure, Map<String, dynamic>>> confirmUpload({
    required String shortId,
  }) async {
    try {
      appLogger.i('ShortsUploadApi.confirmUpload request | shortId=$shortId');

      final res = await _client.post(
        ApiEndpoints.confirmShortUpload,
        data: {'short_id': shortId},
      );

      appLogger.i('ShortsUploadApi.confirmUpload success | shortId=$shortId');
      return unwrapFrappe(res);
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

  Future<Either<Failure, Map<String, dynamic>>> updateMetadata({
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

      appLogger.i('ShortsUploadApi.updateMetadata success | shortId=$shortId');
      return unwrapFrappe(res);
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
