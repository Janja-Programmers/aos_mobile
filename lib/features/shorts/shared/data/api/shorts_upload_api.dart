import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';

class ShortsUploadApi {
  ShortsUploadApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, String>> createShort({
    required String rawVideoMedia,
    String audience = 'everyone',
    bool allowComments = true,
    bool allowDownloads = false,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.createShort,
        data: {
          'raw_video_media': rawVideoMedia,
          'media_id': rawVideoMedia,
          'audience': audience,
          'allow_comments': allowComments,
          'allow_downloads': allowDownloads,
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);
        final shortId = asNullableString(data['short_id']);

        if (shortId == null || shortId.trim().isEmpty) {
          return Either.left(
            const Failure(
              'Invalid create short response',
              type: FailureType.parse,
            ),
          );
        }

        return Either.right(shortId);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error creating short'));
    }
  }

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
