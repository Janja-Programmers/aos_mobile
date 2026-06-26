import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

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

class InitSoundUploadResult {
  final String fileKey;
  final String uploadUrl;
  final String? publicUrl;
  final Map<String, dynamic> uploadHeaders;

  const InitSoundUploadResult({
    required this.fileKey,
    required this.uploadUrl,
    this.publicUrl,
    this.uploadHeaders = const {},
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

  Future<Either<Failure, InitSoundUploadResult>> initSoundUpload({
    required String filename,
    int? sizeBytes,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.initShortSoundUpload,
        data: {'filename': filename, 'size_bytes': ?sizeBytes},
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = _data(json);
        final headers = data['upload_headers'] is Map
            ? Map<String, dynamic>.from(data['upload_headers'] as Map)
            : const <String, dynamic>{};
        return Either.right(
          InitSoundUploadResult(
            fileKey: data['file_key']?.toString() ?? '',
            uploadUrl: data['upload_url']?.toString() ?? '',
            publicUrl: data['public_url']?.toString(),
            uploadHeaders: headers,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error initializing sound upload'),
      );
    }
  }

  Future<Either<Failure, ShortSound>> confirmSoundUpload({
    required String fileKey,
    required String title,
    String artist = '',
    String sourceType = 'uploaded',
    double durationSeconds = 0,
    bool isCommercialSafe = false,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.confirmShortSoundUpload,
        data: {
          'file_key': fileKey,
          'title': title,
          'artist': artist,
          'source_type': sourceType,
          'duration_seconds': durationSeconds,
          'is_commercial_safe': isCommercialSafe,
        },
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final soundJson = _data(json)['sound'];
        if (soundJson is! Map) {
          return Either.left(const Failure('Unexpected sound response'));
        }
        return Either.right(
          ShortSound.fromJson(Map<String, dynamic>.from(soundJson)),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error confirming sound upload'),
      );
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
          'cursor': ?cursor,
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
      return unwrapped.fold((failure) => Either.left(failure), (json) {
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
      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final soundJson = _data(json)['sound'];
        if (soundJson is! Map) {
          return Either.left(const Failure('Unexpected sound response'));
        }
        return Either.right(
          ShortSound.fromJson(Map<String, dynamic>.from(soundJson)),
        );
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
      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = _data(json);
        final metrics = data['metrics'] is Map
            ? Map<String, dynamic>.from(data['metrics'] as Map)
            : const <String, dynamic>{};
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
        queryParameters: {'limit': limit, 'cursor': ?cursor},
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
          'cursor': ?cursor,
        },
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = _data(json);
        final items = data['items'] is List
            ? (data['items'] as List)
                  .whereType<Map>()
                  .map(
                    (item) =>
                        ShortModel.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList(growable: false)
            : const <ShortModel>[];
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
      (failure) => Either.left(failure),
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

  Either<Failure, SoundPage> _parseSoundPage(Response res) {
    final unwrapped = unwrapFrappe(res);
    return unwrapped.fold((failure) => Either.left(failure), (json) {
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
    Response res,
    String fallbackShortId,
  ) {
    final unwrapped = unwrapFrappe(res);
    return unwrapped.fold((failure) => Either.left(failure), (json) {
      final data = _data(json);
      final soundJson = data['sound'];
      return Either.right(
        ChangeShortSoundResult(
          shortId: data['short_id']?.toString() ?? fallbackShortId,
          sound: soundJson is Map
              ? ShortSound.fromJson(Map<String, dynamic>.from(soundJson))
              : null,
          audioMixStatus: data['audio_mix_status']?.toString(),
        ),
      );
    });
  }

  static Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return json;
  }

  static List<ShortSound> _parseSounds(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => ShortSound.fromJson(Map<String, dynamic>.from(item)))
        .where((sound) => sound.id.trim().isNotEmpty)
        .toList(growable: false);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == 'true' || raw == '1' || raw == 'yes' || raw == 'on';
  }
}
