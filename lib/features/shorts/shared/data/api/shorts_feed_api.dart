import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_grid_page.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:dio/dio.dart';

class ShortsFeedApi {
  final ApiClient _client;

  ShortsFeedApi(this._client);

  Future<Either<Failure, ShortFeedPage>> fetchForYou({
    int? limit,
    String? cursor,
    String? contentMode,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': ?limit,
        if (cursor?.isNotEmpty ?? false) 'cursor': cursor,
        if (contentMode?.trim().isNotEmpty ?? false)
          'content_mode': contentMode!.trim(),
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedForYou,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        try {
          final data = _payload(json);

          final items = asJsonMapList(
            data['items'],
          ).map(ShortModel.fromJson).toList();

          final nextCursor = asNullableString(data['next_cursor']);

          return Either.right(
            ShortFeedPage(
              items: items,
              nextCursor: nextCursor,
              hasMore:
                  asNullableBool(data['has_more']) ??
                  (nextCursor?.isNotEmpty ?? false),
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
    String? contentMode,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': ?limit,
        if (cursor?.isNotEmpty ?? false) 'cursor': cursor,
        if (query?.trim().isNotEmpty ?? false) 'search': query!.trim(),
        if (contentMode?.trim().isNotEmpty ?? false)
          'content_mode': contentMode!.trim(),
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedFollowing,
        queryParameters: params,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);

        final items = asJsonMapList(
          data['items'],
        ).map(ShortModel.fromJson).toList();

        final nextCursor = asNullableString(data['next_cursor']);

        return Either.right(
          ShortGridPage(
            items: items,
            nextCursor: nextCursor,
            hasMore:
                asNullableBool(data['has_more']) ??
                (nextCursor?.isNotEmpty ?? false),
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
        if (cursor?.isNotEmpty ?? false) 'cursor': cursor,
      };

      final res = await _client.get(
        ApiEndpoints.shortsFeedByAd,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json, fallbackToRoot: true);

        final items = asJsonMapList(
          data['items'],
        ).map(ShortModel.fromJson).toList();

        final nextCursor = asNullableString(data['next_cursor']);

        return Either.right(
          ShortFeedPage(
            items: items,
            nextCursor: nextCursor,
            hasMore:
                asNullableBool(data['has_more']) ??
                (nextCursor?.isNotEmpty ?? false),
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(Failure('Unexpected error fetching ad feed: $e'));
    }
  }

  static Map<String, dynamic> _payload(
    Map<String, dynamic> json, {
    bool fallbackToRoot = false,
  }) {
    final data = asJsonMap(json['data']);
    if (data.isNotEmpty) return data;

    final message = asJsonMap(json['message']);
    final nestedData = asJsonMap(message['data']);
    if (nestedData.isNotEmpty) return nestedData;

    return fallbackToRoot ? json : <String, dynamic>{};
  }

  static bool? asNullableBool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return null;
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
