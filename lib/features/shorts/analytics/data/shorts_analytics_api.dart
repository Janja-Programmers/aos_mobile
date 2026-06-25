import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/shorts/analytics/data/shorts_analytics_models.dart';

class ShortsAnalyticsApi {
  final ApiClient _client;

  ShortsAnalyticsApi(this._client);

  Future<Either<Failure, ShortsAnalyticsResult>> myAnalytics({
    String? dateFrom,
    String? dateTo,
    int limit = 5,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.myShortsAnalytics,
        queryParameters: {
          'date_from': ?dateFrom,
          'date_to': ?dateTo,
          'limit': limit,
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = _payload(json);
        return Either.right(ShortsAnalyticsResult.fromJson(data));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load Shorts analytics.'));
    }
  }

  static Map<String, dynamic> _payload(Map<String, dynamic> json) {
    if (json['data'] is Map<String, dynamic>) {
      return json['data'] as Map<String, dynamic>;
    }
    if (json['message'] is Map<String, dynamic> &&
        json['message']['data'] is Map<String, dynamic>) {
      return json['message']['data'] as Map<String, dynamic>;
    }
    return json;
  }
}
