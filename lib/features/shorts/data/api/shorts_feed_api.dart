import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/data/mappers/short_mapper.dart';

class ShortsFeedApi {
  final ApiClient _client;

  ShortsFeedApi(this._client);

  // ───────────── FOR YOU ─────────────

  Future<Either<Failure, ShortFeedPage>> fetchForYou({String? cursor}) async {
    try {
      final query = {'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.shortsFeedForYou,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};

        final items = (data['items'] as List? ?? [])
            .map((e) => ShortMapper.toDomain(ShortModel.fromJson(e)))
            .toList();

        return Either.right(
          ShortFeedPage(
            items: items,
            nextCursor: data['next_cursor'],
            hasMore: data['has_more'] ?? false,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching feed'));
    }
  }

  // ───────────── FOLLOWING ─────────────

  Future<Either<Failure, ShortFeedPage>> fetchFollowing({
    String? cursor,
  }) async {
    try {
      final query = {'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.shortsFeedFollowing,
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
      return Either.left(
        const Failure('Unexpected error fetching following feed'),
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
