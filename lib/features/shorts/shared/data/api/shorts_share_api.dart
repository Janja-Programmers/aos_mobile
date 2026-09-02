import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_share_result.dart';
import 'package:dio/dio.dart';

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

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);
        final shareUrl = data['share_url']?.toString() ?? '';

        if (shareUrl.trim().isEmpty) {
          return Either.left(const Failure('Invalid share link response'));
        }

        final metrics = data['metrics'];
        final shareCount = metrics is Map
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

  Future<Either<Failure, int?>> shareToChat({
    required String shortId,
    required String conversationId,
    String? message,
    String? eventId,
  }) async {
    try {
      final normalizedMessage = message?.trim() ?? '';
      final normalizedEventId = eventId?.trim() ?? '';
      final res = await _client.post(
        ApiEndpoints.shareShortToChat,
        data: <String, dynamic>{
          'short_id': shortId,
          'conversation_id': conversationId,
          if (normalizedMessage.isNotEmpty) 'message': normalizedMessage,
          if (normalizedEventId.isNotEmpty) 'event_id': normalizedEventId,
        },
      );

      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);
        final metrics = asJsonMap(data['metrics']);
        return Either.right(_toNullableInt(metrics['share_count']));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error sharing Short to chat'),
      );
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

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
