import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_download_result.dart';
import 'package:dio/dio.dart';

class ShortsLibraryApi {
  final ApiClient _client;

  ShortsLibraryApi(this._client);

  Future<Either<Failure, ShortDownloadResult>> downloadShort({
    required String shortId,
    String? sessionId,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.downloadShort,
        queryParameters: {
          'short_id': shortId,
          if (sessionId != null && sessionId.trim().isNotEmpty)
            'session_id': sessionId.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);
        final url = data['download_url']?.toString() ?? '';

        if (url.trim().isEmpty) {
          return Either.left(const Failure('Invalid download response'));
        }

        final metrics = data['metrics'];
        final count = metrics is Map
            ? _toNullableInt(metrics['download_count'])
            : null;

        return Either.right(
          ShortDownloadResult(
            shortId: data['short_id']?.toString() ?? shortId,
            downloadUrl: url,
            expiresInSeconds: _toInt(data['expires_in_seconds']),
            downloadCount: count,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error preparing download'));
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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
