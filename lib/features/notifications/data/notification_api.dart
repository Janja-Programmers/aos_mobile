import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_page.dart';
import 'package:dio/dio.dart';

class NotificationApi {
  const NotificationApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Either<Failure, NotificationPage>> listNotifications({
    required NotificationCategory category,
    int limit = 20,
    String? before,
  }) async {
    try {
      final Response<Map<String, dynamic>> res = await _apiClient.get(
        ApiEndpoints.listNotifications,
        queryParameters: <String, dynamic>{
          'category': category.backendValue,
          'limit': limit,
          if (before?.trim().isNotEmpty ?? false) 'before': before!.trim(),
        },
      );
      final Either<Failure, Map<String, dynamic>> result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final Map<String, dynamic> envelope = asJsonMap(result.rightOrNull);
      final Map<String, dynamic> data = asJsonMap(envelope['data']);
      final List<NotificationItem> items = asJsonMapList(data['items'])
          .map(NotificationItem.fromJson)
          .where((NotificationItem item) => item.id.isNotEmpty)
          .toList(growable: false);

      final String? nextCursor = _clean(data['next_cursor']);
      return Either.right(
        NotificationPage(
          category: NotificationCategory.fromBackendValue(
            data['category'] ?? category.backendValue,
          ),
          items: items,
          unreadCount: asInt(data['unread_count']),
          nextCursor: nextCursor,
        ),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load notifications'));
    }
  }

  Future<Either<Failure, NotificationMutationResult>> markNotificationRead({
    required String notificationId,
  }) async {
    return _postMutation(
      endpoint: ApiEndpoints.markNotificationRead,
      data: <String, dynamic>{'notification_id': notificationId},
    );
  }

  Future<Either<Failure, NotificationMutationResult>> markAllAsRead() async {
    return _postMutation(endpoint: ApiEndpoints.markAllNotificationsRead);
  }

  Future<Either<Failure, NotificationMutationResult>> deleteNotification({
    required String notificationId,
  }) async {
    return _postMutation(
      endpoint: ApiEndpoints.deleteNotification,
      data: <String, dynamic>{'notification_id': notificationId},
    );
  }

  Future<Either<Failure, NotificationMutationResult>> clearNotifications({
    required NotificationCategory category,
  }) async {
    return _postMutation(
      endpoint: ApiEndpoints.clearNotifications,
      data: <String, dynamic>{'category': category.backendValue},
    );
  }

  Future<Either<Failure, NotificationMutationResult>> _postMutation({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      final Response<Map<String, dynamic>> res = await _apiClient.post(
        endpoint,
        data: data,
      );
      final Either<Failure, Map<String, dynamic>> result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final Map<String, dynamic> envelope = asJsonMap(result.rightOrNull);
      final Map<String, dynamic> payload = asJsonMap(envelope['data']);
      final String? categoryValue = _clean(payload['category']);
      return Either.right(
        NotificationMutationResult(
          unreadCount: asInt(payload['unread_count']),
          notificationId: _clean(payload['notification_id']),
          category: categoryValue == null
              ? null
              : NotificationCategory.fromBackendValue(categoryValue),
          deletedCount: asNullableInt(payload['deleted_count']),
        ),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update notifications'));
    }
  }
}

String? _clean(Object? value) {
  final String? text = value?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
