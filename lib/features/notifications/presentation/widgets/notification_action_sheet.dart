import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter/material.dart';

class NotificationActionSheet extends StatelessWidget {
  const NotificationActionSheet({
    super.key,
    required this.notification,
    required this.onAction,
  });

  final NotificationItem notification;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            notification.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          Text(
            notification.body,
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAction,
              child: Text(
                _actionText(notification),
                style: AppTextStylesX(context).button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _actionText(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.message:
        return 'Open Chat';

      case NotificationType.liveStarted:
        return 'Watch Now';

      case NotificationType.incomingCall:
        return 'Answer Call';

      case NotificationType.missedCall:
        return 'Call Back';

      case NotificationType.adApproved:
        return 'View Ad';

      case NotificationType.adRejected:
        return 'Review Ad';

      case NotificationType.follow:
        return 'View Profile';

      default:
        return 'Open';
    }
  }
}
