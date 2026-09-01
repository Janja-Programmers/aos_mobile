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
    String? soundId,
    int soundStartMs = 0,
    int soundDurationMs = 0,
    double soundVolume = 1,
  }) async {
    try {
      final cleanSoundId = soundId?.trim();
      final res = await _client.post(
        ApiEndpoints.createShort,
        data: {
          'raw_video_media': rawVideoMedia,
          'media_id': rawVideoMedia,
          'audience': audience,
          'allow_comments': allowComments,
          'allow_downloads': allowDownloads,
          if (cleanSoundId != null && cleanSoundId.isNotEmpty)
            'sound_id': cleanSoundId,
          if (cleanSoundId != null && cleanSoundId.isNotEmpty)
            'sound_start_ms': soundStartMs,
          if (cleanSoundId != null && cleanSoundId.isNotEmpty)
            'sound_duration_ms': soundDurationMs,
          if (cleanSoundId != null && cleanSoundId.isNotEmpty)
            'sound_volume': soundVolume,
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
    String? adId,
    bool includeAdId = false,
    String caption = '',
    List<String> hashtags = const <String>[],
    String audience = 'everyone',
    bool allowComments = true,
    bool allowDownloads = false,
    String? soundId,
    int soundStartMs = 0,
    int soundDurationMs = 0,
    double soundVolume = 1,
  }) async {
    try {
      final cleanSoundId = soundId?.trim();
      final data = <String, dynamic>{
        'short_id': shortId,
        if (includeAdId) 'ad_id': adId?.trim() ?? '',
        'caption': caption,
        'hashtags': hashtags,
        'audience': audience,
        'allow_comments': allowComments,
        'allow_downloads': allowDownloads,
        if (cleanSoundId != null && cleanSoundId.isNotEmpty)
          'sound_id': cleanSoundId,
        if (cleanSoundId != null && cleanSoundId.isNotEmpty)
          'sound_start_ms': soundStartMs,
        if (cleanSoundId != null && cleanSoundId.isNotEmpty)
          'sound_duration_ms': soundDurationMs,
        if (cleanSoundId != null && cleanSoundId.isNotEmpty)
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
