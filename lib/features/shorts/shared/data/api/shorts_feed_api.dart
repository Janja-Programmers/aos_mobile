import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_grid_page.dart';

class ShortsFeedApi {
  final ApiClient _client;

  ShortsFeedApi(this._client);

  // ───────────── FOR YOU ─────────────

  Future<Either<Failure, ShortFeedPage>> fetchForYou({String? cursor}) async {
    try {
      final query = <String, dynamic>{'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.shortsFeedForYou,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) {
          return Either.left(failure);
        },
        (json) {
          try {
            /// SAFE unwrap — supports both formats
            final data = json['data'] is Map<String, dynamic>
                ? json['data']
                : (json['message'] is Map<String, dynamic>
                      ? json['message']['data']
                      : <String, dynamic>{});

            final items = (data['items'] as List? ?? [])
                .map((e) {
                  try {
                    return ShortMapper.toDomain(ShortModel.fromJson(e));
                  } catch (err) {
                    return null;
                  }
                })
                .whereType<Short>()
                .toList();

            final nextCursor = data['next_cursor'] as String?;

            return Either.right(
              ShortFeedPage(
                items: items,
                nextCursor: data['next_cursor'] as String?,
                hasMore: nextCursor != null && nextCursor.isNotEmpty,
              ),
            );
          } catch (e, _) {
            return Either.left(Failure('Parse error: $e'));
          }
        },
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(Failure('Unexpected error fetching feed: $e'));
    }
  }

  // ───────────── FOLLOWING ─────────────

  Future<Either<Failure, ShortGridPage>> fetchFollowingGrid({
    String? query,
    String? cursor,
  }) async {
    try {
      final params = <String, dynamic>{
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedFollowing,
        queryParameters: params,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};

        final items = (data['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ShortModel.fromJson)
            .toList();

        final nextCursor = data['next_cursor'] as String?;

        return Either.right(
          ShortGridPage(
            items: items,
            nextCursor: nextCursor,
            hasMore: nextCursor != null && nextCursor.isNotEmpty,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(
        Failure('Unexpected error fetching following grid: $e'),
      );
    }
  }

  // ───────────── BY AD ─────────────

  Future<Either<Failure, ShortFeedPage>> fetchByAd({
    required String adId,
    String? cursor,
  }) async {
    try {
      final query = {'ad_id': adId, 'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.shortsFeedByAd,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final items = (json['items'] as List? ?? [])
            .map((e) => ShortMapper.toDomain(ShortModel.fromJson(e)))
            .toList();

        return Either.right(
          ShortFeedPage(
            items: items,
            nextCursor: json['next_cursor'],
            hasMore: json['has_more'] ?? false,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching ad feed'));
    }
  }
}
