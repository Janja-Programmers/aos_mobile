import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_report/models/report_reason.dart';
import 'package:dio/dio.dart';

class ReportAdApi {
  ReportAdApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, List<ReportReason>>> listReportReasons() async {
    try {
      final res = await _client.get(ApiEndpoints.listReportReasonsEndpoint);

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Left.new, (data) {
        final payload = asJsonMap(data['data']);

        final reasons = asJsonMapList(
          payload['reasons'],
        ).map(ReportReason.fromJson).toList(growable: false);

        return Right(reasons);
      });
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(Failure('Failed to load report reasons.'));
    }
  }

  Future<Either<Failure, void>> reportAd({
    required String adId,
    required String reason,
    required String details,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.reportAdEndpoint,
        data: {'ad': adId, 'reason': reason, 'details': details},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Left.new, (_) => const Right(null));
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(Failure('Failed to submit report.'));
    }
  }
}
