import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter/material.dart';

// =====================================================
// GROUPING (Today / Yesterday / Earlier)
// =====================================================

Map<String, List<NotificationItem>> groupByDate(List<NotificationItem> items) {
  final Map<String, List<NotificationItem>> grouped = {};
  final now = DateTime.now();

  for (final item in items) {
    final diff = now.difference(item.createdAt);

    String key;
    if (diff.inDays == 0) {
      key = 'Today';
    } else if (diff.inDays == 1) {
      key = 'Yesterday';
    } else {
      key = 'Earlier';
    }

    grouped.putIfAbsent(key, () => []).add(item);
  }

  return grouped;
}

// =====================================================
// FILTERING
// =====================================================
List<NotificationItem> filterNotifications(
  List<NotificationItem> items,
  String selectedTab,
) {
  switch (selectedTab) {
    case 'Messages':
      return items.where((n) => n.type == NotificationType.message).toList();

    case 'Activity':
      return items.where((n) {
        return n.type == NotificationType.follow ||
            n.type == NotificationType.missedCall ||
            n.type == NotificationType.liveStarted ||
            n.type == NotificationType.adApproved ||
            n.type == NotificationType.adRejected;
      }).toList();

    case 'All':
    default:
      return items;
  }
}

IconData iconForType(NotificationType type) {
  switch (type) {
    case NotificationType.message:
      return Icons.chat_bubble;

    case NotificationType.follow:
      return Icons.person_add;

    case NotificationType.missedCall:
      return Icons.phone_missed;

    case NotificationType.liveStarted:
      return Icons.wifi_tethering;

    case NotificationType.adApproved:
      return Icons.check_circle;

    case NotificationType.adRejected:
      return Icons.cancel;

    default:
      return Icons.notifications;
  }
}

Color colorForType(NotificationType type, dynamic colors) {
  switch (type) {
    case NotificationType.liveStarted:
      return colors.primary;

    case NotificationType.follow:
      return colors.blue;

    case NotificationType.adApproved:
      return colors.success;

    case NotificationType.adRejected:
      return colors.primary;

    default:
      return colors.primary;
  }
}
