import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:dio/dio.dart';

class SoundPage {
  final List<ShortSound> items;
  final String? nextCursor;
  final bool hasMore;

  const SoundPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

class FavoriteSoundResult {
  final String soundId;
  final bool favorited;
  final int favoriteCount;
  final String favoriteCountDisplay;

  const FavoriteSoundResult({
    required this.soundId,
    required this.favorited,
    required this.favoriteCount,
    required this.favoriteCountDisplay,
  });
}

class ChangeShortSoundResult {
  final String shortId;
  final ShortSound? sound;
  final String? audioMixStatus;

  const ChangeShortSoundResult({
    required this.shortId,
    this.sound,
    this.audioMixStatus,
  });
}

class ShortsSoundsApi {
  final ApiClient _client;

  ShortsSoundsApi(this._client);

  Future<Either<Failure, ShortSound>> createSoundFromMedia({
    required String soundMedia,
    required String title,
    String artist = '',
    String sourceType = 'uploaded',
    double durationSeconds = 0,
    bool isCommercialSafe = false,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.createShortSound,
        data: {
          'sound_media': soundMedia,
          'media_id': soundMedia,
          'title': title,
          'artist': artist,
          'source_type': sourceType,
          'duration_seconds': durationSeconds,
          'is_commercial_safe': isCommercialSafe,
        },
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final soundJson = _data(json)['sound'];
        if (soundJson is! Map) {
          return Either.left(const Failure('Unexpected sound response'));
        }
        return Either.right(ShortSound.fromJson(asJsonMap(soundJson)));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error creating sound'));
    }
  }

  Future<Either<Failure, SoundPage>> listSounds({
    int limit = 20,
    String? cursor,
    String sourceType = 'all',
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listShortSounds,
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (sourceType.trim().isNotEmpty) 'source_type': sourceType,
        },
      );
      return _parseSoundPage(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching sounds'));
    }
  }

  Future<Either<Failure, List<ShortSound>>> searchSounds({
    required String query,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.searchShortSounds,
        queryParameters: {'q': query, 'limit': limit},
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final items = _parseSounds(_data(json)['items']);
        return Either.right(items);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error searching sounds'));
    }
  }

  Future<Either<Failure, ShortSound>> getSound({
    required String soundId,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getShortSound,
        queryParameters: {'sound_id': soundId},
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final soundJson = _data(json)['sound'];
        if (soundJson is! Map) {
          return Either.left(const Failure('Unexpected sound response'));
        }
        return Either.right(ShortSound.fromJson(asJsonMap(soundJson)));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching sound'));
    }
  }

  Future<Either<Failure, FavoriteSoundResult>> favoriteSound({
    required String soundId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.favoriteShortSound,
        data: {'sound_id': soundId},
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final data = _data(json);
        final metrics = asJsonMap(data['metrics']);
        return Either.right(
          FavoriteSoundResult(
            soundId: data['sound_id']?.toString() ?? soundId,
            favorited: _toBool(data['favorited']),
            favoriteCount: _toInt(metrics['favorite_count']),
            favoriteCountDisplay:
                metrics['favorite_count_display']?.toString() ??
                _toInt(metrics['favorite_count']).toString(),
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error favoriting sound'));
    }
  }

  Future<Either<Failure, SoundPage>> myFavoriteSounds({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.myFavoriteShortSounds,
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      return _parseSoundPage(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error fetching favorite sounds'),
      );
    }
  }

  Future<Either<Failure, ShortFeedPage>> soundShorts({
    required String soundId,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.soundShorts,
        queryParameters: {
          'sound_id': soundId,
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final data = _data(json);
        final items = asJsonMapList(
          data['items'],
        ).map(ShortModel.fromJson).toList(growable: false);
        return Either.right(
          ShortFeedPage(
            items: items,
            nextCursor: data['next_cursor']?.toString(),
            hasMore: _toBool(data['has_more']),
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error fetching sound shorts'),
      );
    }
  }

  Future<Either<Failure, List<Short>>> soundShortsDomain({
    required String soundId,
    int limit = 20,
    String? cursor,
  }) async {
    final res = await soundShorts(
      soundId: soundId,
      limit: limit,
      cursor: cursor,
    );
    return res.fold(
      Either.left,
      (page) => Either.right(
        page.items.map(ShortMapper.toDomain).toList(growable: false),
      ),
    );
  }

  Future<Either<Failure, ChangeShortSoundResult>> changeShortSound({
    required String shortId,
    required String soundId,
    int startMs = 0,
    int durationMs = 0,
    double volume = 1,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.changeShortSound,
        data: {
          'short_id': shortId,
          'sound_id': soundId,
          'sound_start_ms': startMs,
          'sound_duration_ms': durationMs,
          'sound_volume': volume,
        },
      );
      return _parseChangeShortSound(res, shortId);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error changing short sound'),
      );
    }
  }

  Future<Either<Failure, ChangeShortSoundResult>> removeShortSound({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.removeShortSound,
        data: {'short_id': shortId},
      );
      return _parseChangeShortSound(res, shortId);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error removing short sound'),
      );
    }
  }

  Either<Failure, SoundPage> _parseSoundPage(
    Response<Map<String, dynamic>> res,
  ) {
    final unwrapped = unwrapFrappe(res);
    return unwrapped.fold(Either.left, (json) {
      final data = _data(json);
      return Either.right(
        SoundPage(
          items: _parseSounds(data['items']),
          nextCursor: data['next_cursor']?.toString(),
          hasMore: _toBool(data['has_more']),
        ),
      );
    });
  }

  Either<Failure, ChangeShortSoundResult> _parseChangeShortSound(
    Response<Map<String, dynamic>> res,
    String fallbackShortId,
  ) {
    final unwrapped = unwrapFrappe(res);
    return unwrapped.fold(Either.left, (json) {
      final data = _data(json);
      final sound = asJsonMap(data['sound']);
      return Either.right(
        ChangeShortSoundResult(
          shortId: data['short_id']?.toString() ?? fallbackShortId,
          sound: sound.isEmpty ? null : ShortSound.fromJson(sound),
          audioMixStatus: data['audio_mix_status']?.toString(),
        ),
      );
    });
  }

  static Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = asJsonMap(json['data']);
    return data.isNotEmpty ? data : json;
  }

  static List<ShortSound> _parseSounds(Object? raw) {
    return asJsonMapList(raw)
        .map(ShortSound.fromJson)
        .where((sound) => sound.id.trim().isNotEmpty)
        .toList(growable: false);
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == 'true' || raw == '1' || raw == 'yes' || raw == 'on';
  }
}
