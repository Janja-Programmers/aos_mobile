import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:dio/dio.dart';

class NotificationApi {
  final ApiClient _apiClient;

  const NotificationApi(this._apiClient);

  // =====================================================
  // LIST NOTIFICATIONS
  // =====================================================
  Future<Either<Failure, List<NotificationItem>>> listNotifications() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.listNotifications);

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final data = asJsonMap(result.rightOrNull);
      final payload = asJsonMap(data['data']);
      final raw = payload['items'];

      final items = asJsonMapList(
        raw,
      ).map(NotificationItem.fromJson).toList(growable: false);

      return Either.right(items);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
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

      return Either.right(true);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
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

      return Either.right(true);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(
        const Failure('Failed to mark all notifications as read'),
      );
    }
  }

  // =====================================================
  // DELETE NOTIFICATION
  // =====================================================
  Future<Either<Failure, bool>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.deleteNotification,
        data: {'notification_id': notificationId},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      return Either.right(true);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(const Failure('Failed to delete notification'));
    }
  }
}
