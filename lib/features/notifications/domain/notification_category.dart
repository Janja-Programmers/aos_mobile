import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

enum NotificationCategory {
  all('all'),
  communication('communication'),
  activity('activity'),
  marketplace('marketplace'),
  account('account');

  const NotificationCategory(this.backendValue);

  final String backendValue;

  static NotificationCategory fromBackendValue(Object? value) {
    return tryFromBackendValue(value) ?? NotificationCategory.all;
  }

  static NotificationCategory? tryFromBackendValue(Object? value) {
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    for (final NotificationCategory category in NotificationCategory.values) {
      if (category.backendValue == normalized) return category;
    }
    return null;
  }

  static NotificationCategory? forType(NotificationType type) {
    return switch (type) {
      NotificationType.message ||
      NotificationType.missedCall => NotificationCategory.communication,
      NotificationType.follow ||
      NotificationType.newShort ||
      NotificationType.shortLike ||
      NotificationType.shortComment ||
      NotificationType.shortMention ||
      NotificationType.commentReply ||
      NotificationType.liveStarted => NotificationCategory.activity,
      NotificationType.adApproved ||
      NotificationType.adRejected ||
      NotificationType.adExpired ||
      NotificationType.reviewReceived ||
      NotificationType.reviewApproved ||
      NotificationType.reviewRejected => NotificationCategory.marketplace,
      NotificationType.verificationApproved ||
      NotificationType.verificationRejected => NotificationCategory.account,
      NotificationType.incomingCall ||
      NotificationType.callRejected ||
      NotificationType.callEnded ||
      NotificationType.unknown => null,
    };
  }
}
