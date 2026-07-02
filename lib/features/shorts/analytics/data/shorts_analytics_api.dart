import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/analytics/data/shorts_analytics_models.dart';
import 'package:dio/dio.dart';

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
          if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
          'limit': limit,
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
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
    final data = asJsonMap(json['data']);
    if (data.isNotEmpty) return data;

    final message = asJsonMap(json['message']);
    final nestedData = asJsonMap(message['data']);
    if (nestedData.isNotEmpty) return nestedData;

    return json;
  }
}
