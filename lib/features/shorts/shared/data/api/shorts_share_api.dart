import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_share_result.dart';

class ShortsShareApi {
  final ApiClient _client;

  ShortsShareApi(this._client);

  Future<Either<Failure, ShortShareResult>> createShareLink({
    required String shortId,
    String channel = 'system_share',
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.createShortShareLink,
        data: {
          'short_id': shortId,
          'channel': channel,
          if (sessionId != null && sessionId.trim().isNotEmpty)
            'session_id': sessionId.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = _payload(json);
        final shareUrl = data['share_url']?.toString() ?? '';

        if (shareUrl.trim().isEmpty) {
          return Either.left(const Failure('Invalid share link response'));
        }

        final metrics = data['metrics'];
        final shareCount = metrics is Map<String, dynamic>
            ? _toNullableInt(metrics['share_count'])
            : null;

        return Either.right(
          ShortShareResult(
            shortId: data['short_id']?.toString() ?? shortId,
            shareUrl: shareUrl,
            channel: data['channel']?.toString() ?? channel,
            shareCount: shareCount,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error creating share link'));
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

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
