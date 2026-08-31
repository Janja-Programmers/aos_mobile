import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/notifications/data/notification_api.dart';
import 'package:africaonlinestores/features/notifications/data/push_token_api.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_page.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationPage>> getNotifications({
    required NotificationCategory category,
    required int limit,
    String? before,
  });

  Future<Either<Failure, NotificationMutationResult>> markNotificationRead(
    String notificationId,
  );

  Future<Either<Failure, NotificationMutationResult>> markAllAsRead();

  Future<Either<Failure, NotificationMutationResult>> deleteNotification(
    String notificationId,
  );

  Future<Either<Failure, NotificationMutationResult>> clearNotifications(
    NotificationCategory category,
  );
}

abstract class PushTokenRepository {
  Future<Either<Failure, bool>> registerPushToken(PushTokenDevice device);
  Future<Either<Failure, bool>> deactivatePushToken(String token);
}

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this.api);

  final NotificationApi api;

  @override
  Future<Either<Failure, NotificationPage>> getNotifications({
    required NotificationCategory category,
    required int limit,
    String? before,
  }) {
    return api.listNotifications(
      category: category,
      limit: limit,
      before: before,
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> markNotificationRead(
    String notificationId,
  ) {
    return api.markNotificationRead(notificationId: notificationId);
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> markAllAsRead() {
    return api.markAllAsRead();
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> deleteNotification(
    String notificationId,
  ) {
    return api.deleteNotification(notificationId: notificationId);
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> clearNotifications(
    NotificationCategory category,
  ) {
    return api.clearNotifications(category: category);
  }
}

class PushTokenRepositoryImpl implements PushTokenRepository {
  const PushTokenRepositoryImpl(this.api);

  final PushTokenApi api;

  @override
  Future<Either<Failure, bool>> registerPushToken(PushTokenDevice device) {
    return api.registerPushToken(device: device);
  }

  @override
  Future<Either<Failure, bool>> deactivatePushToken(String token) {
    return api.deactivatePushToken(token: token);
  }
}
