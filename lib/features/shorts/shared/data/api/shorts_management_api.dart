import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';

class ShortsManagementApi {
  final ApiClient _client;

  ShortsManagementApi(this._client);

  // ───────────── GET SINGLE SHORT ─────────────

  Future<Either<Failure, Short>> getShort({required String shortId}) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getShort,
        queryParameters: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final item = data['item'] as Map<String, dynamic>?;

        if (item == null) {
          return Either.left(const Failure('Invalid short response'));
        }

        final model = ShortModel.fromJson(item);
        final short = ShortMapper.toDomain(model);

        return Either.right(short);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching short'));
    }
  }

  // ───────────── MY SHORTS ─────────────

  Future<Either<Failure, ShortFeedPage>> myShorts({String? cursor}) async {
    try {
      final query = {'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.myShorts,
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
      return Either.left(const Failure('Unexpected error fetching my shorts'));
    }
  }

  // ───────────── DELETE SHORT ─────────────

  Future<Either<Failure, void>> deleteShort({required String shortId}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteShort,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error deleting short'));
    }
  }

  // ───────────── RETRY PROCESSING ─────────────

  Future<Either<Failure, void>> retryProcessing({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.retryProcessing,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error retrying processing'));
    }
  }
}
