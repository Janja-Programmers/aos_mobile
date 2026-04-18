import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';

class NotificationApi {
  final ApiClient _apiClient;

  const NotificationApi(this._apiClient);

  // =====================================================
  // LIST NOTIFICATIONS
  // =====================================================
  Future<Either<Failure, List<NotificationItem>>> listNotifications() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.listNotifications);

      appLogger.i('Res: ${res.toString()}');

      final result = unwrapFrappe(res);

      appLogger.i('Unwrapped: ${result.toString()}');

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final data = result.rightOrNull;

      // 🔥 FIX HERE
      final raw = data?['data']?['items'];

      if (raw is! List) {
        appLogger.w('Invalid notifications format: $data');
        return Either.left(
          const Failure(
            'Invalid notifications format',
            type: FailureType.parse,
          ),
        );
      }

      appLogger.i("Results List API raw count: ${raw.length}");

      final items = raw
          .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (items.isNotEmpty) {
        appLogger.i('1st Notification: ${items.first}');
      }

      return Either.right(items);
    } on DioException catch (e, s) {
      appLogger.e('listNotifications Dio error', error: e, stackTrace: s);
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('listNotifications unknown error', error: e, stackTrace: s);
      return Either.left(const Failure('Failed to load notifications'));
    }
  }

  // =====================================================
  // MARK ONE AS READ
  // =====================================================
  Future<Either<Failure, bool>> markNotificationRead({
    required String notificationId,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.markNotificationRead,
        data: {'notification_id': notificationId},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      appLogger.i('Notification marked read: $notificationId');
      return Either.right(true);
    } on DioException catch (e, s) {
      appLogger.e('markAsRead Dio error', error: e, stackTrace: s);
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('markAsRead unknown error', error: e, stackTrace: s);
      return Either.left(const Failure('Failed to mark notification as read'));
    }
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      final res = await _apiClient.post(ApiEndpoints.markAllNotificationsRead);

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      appLogger.i('All notifications marked as read');
      return Either.right(true);
    } on DioException catch (e, s) {
      appLogger.e('markAllAsRead Dio error', error: e, stackTrace: s);
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('markAllAsRead unknown error', error: e, stackTrace: s);
      return Either.left(
        const Failure('Failed to mark all notifications as read'),
      );
    }
  }
}
