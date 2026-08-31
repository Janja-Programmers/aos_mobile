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
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                style: context.h4.copyWith(fontWeight: FontWeight.w700),
              ),
              if (notification.body.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Text(notification.body, style: context.p),
              ],
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
        ),
      ),
    );
  }
}

String _actionText(NotificationItem notification) {
  return switch (notification.type) {
    NotificationType.message => 'Open Chat',
    NotificationType.liveStarted => 'Watch Now',
    NotificationType.incomingCall => 'Answer Call',
    NotificationType.missedCall => 'Call Back',
    NotificationType.adApproved => 'View Ad',
    NotificationType.adRejected => 'Review Ad',
    NotificationType.adExpired => 'View Listings',
    NotificationType.reviewReceived ||
    NotificationType.reviewApproved ||
    NotificationType.reviewRejected => 'View Ad',
    NotificationType.follow => 'View Profile',
    NotificationType.newShort ||
    NotificationType.shortLike ||
    NotificationType.shortComment ||
    NotificationType.shortMention ||
    NotificationType.commentReply => 'View Short',
    NotificationType.verificationApproved ||
    NotificationType.verificationRejected => 'Open Account',
    NotificationType.callRejected || NotificationType.callEnded => 'View Calls',
    NotificationType.unknown => 'Open',
  };
}
