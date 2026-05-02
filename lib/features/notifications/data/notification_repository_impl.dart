import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/notifications/data/notification_api.dart';
import 'package:africaonlinestores/features/notifications/data/push_token_api.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationItem>>> getNotifications();

  Future<Either<Failure, bool>> markNotificationRead(String notificationId);

  Future<Either<Failure, bool>> markAllAsRead();

  Future<Either<Failure, bool>> deleteNotification(String notificationId);
}

abstract class PushTokenRepository {
  Future<Either<Failure, bool>> registerPushToken(PushTokenDevice device);

  Future<Either<Failure, bool>> deactivatePushToken(String token);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApi api;

  const NotificationRepositoryImpl(this.api);

  @override
  Future<Either<Failure, List<NotificationItem>>> getNotifications() {
    return api.listNotifications();
  }

  @override
  Future<Either<Failure, bool>> markNotificationRead(String notificationId) {
    return api.markNotificationRead(notificationId: notificationId);
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() {
    return api.markAllAsRead();
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String notificationId) {
    return api.deleteNotification(notificationId: notificationId);
  }
}

class PushTokenRepositoryImpl implements PushTokenRepository {
  final PushTokenApi api;

  const PushTokenRepositoryImpl(this.api);

  @override
  Future<Either<Failure, bool>> registerPushToken(PushTokenDevice device) {
    return api.registerPushToken(device: device);
  }

  @override
  Future<Either<Failure, bool>> deactivatePushToken(String token) {
    return api.deactivatePushToken(token: token);
  }
}
