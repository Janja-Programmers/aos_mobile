import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/create_short/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/init_short_upload_result.dart';

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

      appLogger.w("ShortsUploadApi | res: ${res.statusMessage}");

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
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error initializing upload'));
    }
  }

  // ───────────── CONFIRM UPLOAD ─────────────

  Future<Either<Failure, void>> confirmUpload({required String shortId}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.confirmShortUpload,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        return Either.right(null);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
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

      final res = await _client.post(
        ApiEndpoints.updateShortMetadata,
        data: data,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error updating metadata'));
    }
  }
}
