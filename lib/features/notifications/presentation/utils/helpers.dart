import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter/material.dart';

Map<String, List<NotificationItem>> groupByDate(List<NotificationItem> items) {
  final Map<String, List<NotificationItem>> grouped =
      <String, List<NotificationItem>>{};
  final DateTime now = DateTime.now();

  for (final NotificationItem item in items) {
    final DateTime localCreated = item.createdAt.toLocal();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime itemDay = DateTime(
      localCreated.year,
      localCreated.month,
      localCreated.day,
    );
    final int days = today.difference(itemDay).inDays;
    final String key = days <= 0
        ? 'Today'
        : days == 1
        ? 'Yesterday'
        : 'Earlier';
    grouped.putIfAbsent(key, () => <NotificationItem>[]).add(item);
  }
  return grouped;
}

IconData iconForType(NotificationType type) {
  return switch (type) {
    NotificationType.message => Icons.chat_bubble_outline_rounded,
    NotificationType.follow => Icons.person_add_alt_1_rounded,
    NotificationType.missedCall => Icons.phone_missed_rounded,
    NotificationType.liveStarted => Icons.wifi_tethering_rounded,
    NotificationType.adApproved => Icons.check_circle_outline_rounded,
    NotificationType.adRejected => Icons.cancel_outlined,
    NotificationType.adExpired => Icons.schedule_rounded,
    NotificationType.reviewReceived => Icons.rate_review_outlined,
    NotificationType.reviewApproved => Icons.reviews_outlined,
    NotificationType.reviewRejected => Icons.rate_review_outlined,
    NotificationType.verificationApproved => Icons.verified_outlined,
    NotificationType.verificationRejected => Icons.gpp_bad_outlined,
    NotificationType.newShort => Icons.play_circle_outline_rounded,
    NotificationType.shortLike => Icons.favorite_border_rounded,
    NotificationType.shortComment => Icons.mode_comment_outlined,
    NotificationType.shortMention => Icons.alternate_email_rounded,
    NotificationType.commentReply => Icons.reply_rounded,
    NotificationType.incomingCall ||
    NotificationType.callRejected ||
    NotificationType.callEnded => Icons.phone_outlined,
    NotificationType.unknown => Icons.notifications_none_rounded,
  };
}

Color colorForType(NotificationType type, AppColorTokens colors) {
  return switch (type) {
    NotificationType.follow => colors.blue,
    NotificationType.adApproved ||
    NotificationType.reviewApproved ||
    NotificationType.verificationApproved => colors.success,
    NotificationType.adRejected ||
    NotificationType.reviewRejected ||
    NotificationType.verificationRejected => colors.primary,
    NotificationType.liveStarted ||
    NotificationType.message ||
    NotificationType.missedCall ||
    NotificationType.callRejected ||
    NotificationType.callEnded ||
    NotificationType.incomingCall ||
    NotificationType.adExpired ||
    NotificationType.reviewReceived ||
    NotificationType.newShort ||
    NotificationType.shortLike ||
    NotificationType.shortComment ||
    NotificationType.shortMention ||
    NotificationType.commentReply ||
    NotificationType.unknown => colors.primary,
  };
}
