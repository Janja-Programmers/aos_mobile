import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_report/models/report_reason.dart';
import 'package:dio/dio.dart';

class ShortsReportApi {
  final ApiClient _client;

  ShortsReportApi(this._client);

  Future<Either<Failure, List<ReportReason>>> listReportReasons() async {
    try {
      final res = await _client.get(ApiEndpoints.listReportReasonsEndpoint);
      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);
        final reasons = asJsonMapList(
          data['reasons'],
        ).map(ReportReason.fromJson).toList(growable: false);

        return Either.right(reasons);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load report reasons.'));
    }
  }

  Future<Either<Failure, void>> reportShort({
    required String shortId,
    required String reason,
    String details = '',
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.reportShortEndpoint,
        data: {
          'short_id': shortId,
          'reason': reason,
          if (details.trim().isNotEmpty) 'details': details.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to submit report.'));
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
