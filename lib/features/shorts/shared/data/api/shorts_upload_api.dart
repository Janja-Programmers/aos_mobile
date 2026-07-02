import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/init_short_upload_result.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:dio/dio.dart';

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

      appLogger.w('ShortsUploadApi | res: ${res.statusMessage}');

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
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

      return unwrapped.fold(Either.left, (_) {
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
    required String shortId,
    required String contentMode,
    String? adId,
    String? caption,
    List<String>? hashtags,
    String audience = 'everyone',
    bool allowComments = true,
    bool allowDownloads = false,
    String? soundId,
    int soundStartMs = 0,
    int soundDurationMs = 0,
    double soundVolume = 1,
  }) async {
    try {
      final data = <String, dynamic>{
        'short_id': shortId,
        'content_mode': contentMode,
        if (adId != null && adId.trim().isNotEmpty) 'ad_id': adId,
        if (caption != null && caption.trim().isNotEmpty) 'caption': caption,
        if (hashtags != null && hashtags.isNotEmpty) 'hashtags': hashtags,
        'audience': audience,
        'allow_comments': allowComments,
        'allow_downloads': allowDownloads,
        if (soundId != null && soundId.trim().isNotEmpty) 'sound_id': soundId,
        if (soundId != null && soundId.trim().isNotEmpty)
          'sound_start_ms': soundStartMs,
        if (soundId != null && soundId.trim().isNotEmpty)
          'sound_duration_ms': soundDurationMs,
        if (soundId != null && soundId.trim().isNotEmpty)
          'sound_volume': soundVolume,
      };

      final res = await _client.post(
        ApiEndpoints.updateShortMetadata,
        data: data,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error updating metadata'));
    }
  }
}
