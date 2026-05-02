import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_grid_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';

class ShortsFeedApi {
  final ApiClient _client;

  ShortsFeedApi(this._client);

  Future<Either<Failure, ShortFeedPage>> fetchForYou({
    int? limit,
    String? cursor,
  }) async {
    try {
      final query = <String, dynamic>{
        if (limit != null) 'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedForYou,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        try {
          final data = json['data'] is Map<String, dynamic>
              ? json['data'] as Map<String, dynamic>
              : json['message']?['data'] as Map<String, dynamic>? ?? {};

          final items = (data['items'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(ShortModel.fromJson)
              .toList();

          final nextCursor = data['next_cursor'] as String?;

          return Either.right(
            ShortFeedPage(
              items: items,
              nextCursor: nextCursor,
              hasMore:
                  data['has_more'] as bool? ??
                  (nextCursor != null && nextCursor.isNotEmpty),
            ),
          );
        } catch (e) {
          return Either.left(Failure('Parse error: $e'));
        }
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(Failure('Unexpected error fetching feed: $e'));
    }
  }

  Future<Either<Failure, ShortGridPage>> fetchFollowingGrid({
    String? query,
    int? limit,
    String? cursor,
  }) async {
    try {
      final params = <String, dynamic>{
        if (limit != null) 'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedFollowing,
        queryParameters: params,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json['message']?['data'] as Map<String, dynamic>? ?? {};

        final items = (data['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ShortModel.fromJson)
            .toList();

        final nextCursor = data['next_cursor'] as String?;

        return Either.right(
          ShortGridPage(
            items: items,
            nextCursor: nextCursor,
            hasMore:
                data['has_more'] as bool? ??
                (nextCursor != null && nextCursor.isNotEmpty),
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

  Future<Either<Failure, ShortFeedPage>> fetchByAd({
    required String adId,
    String? cursor,
  }) async {
    try {
      final query = <String, dynamic>{
        'ad_id': adId,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedByAd,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json['message']?['data'] as Map<String, dynamic>? ?? json;

        final items = (data['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ShortModel.fromJson)
            .toList();

        final nextCursor = data['next_cursor'] as String?;

        return Either.right(
          ShortFeedPage(
            items: items,
            nextCursor: nextCursor,
            hasMore:
                data['has_more'] as bool? ??
                (nextCursor != null && nextCursor.isNotEmpty),
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(Failure('Unexpected error fetching ad feed: $e'));
    }
  }
}
