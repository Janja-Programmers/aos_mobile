import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';

class NotificationPage {
  const NotificationPage({
    required this.category,
    required this.items,
    required this.unreadCount,
    required this.nextCursor,
  });

  final NotificationCategory category;
  final List<NotificationItem> items;
  final int unreadCount;
  final String? nextCursor;
}

class NotificationMutationResult {
  const NotificationMutationResult({
    required this.unreadCount,
    this.notificationId,
    this.category,
    this.deletedCount,
  });

  final int unreadCount;
  final String? notificationId;
  final NotificationCategory? category;
  final int? deletedCount;
}
