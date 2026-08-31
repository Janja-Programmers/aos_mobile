import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps every canonical persistent backend type to its category', () {
    final Map<String, NotificationCategory> expected =
        <String, NotificationCategory>{
          'message': NotificationCategory.communication,
          'missed_call': NotificationCategory.communication,
          'follow': NotificationCategory.activity,
          'new_short': NotificationCategory.activity,
          'short_like': NotificationCategory.activity,
          'short_comment': NotificationCategory.activity,
          'short_mention': NotificationCategory.activity,
          'comment_reply': NotificationCategory.activity,
          'live_started': NotificationCategory.activity,
          'ad_approved': NotificationCategory.marketplace,
          'ad_rejected': NotificationCategory.marketplace,
          'ad_expired': NotificationCategory.marketplace,
          'review_received': NotificationCategory.marketplace,
          'review_approved': NotificationCategory.marketplace,
          'review_rejected': NotificationCategory.marketplace,
          'verification_approved': NotificationCategory.account,
          'verification_rejected': NotificationCategory.account,
        };

    for (final MapEntry<String, NotificationCategory> entry
        in expected.entries) {
      final NotificationType type = NotificationTypeX.fromBackendValue(
        entry.key,
      );
      expect(
        NotificationCategory.forType(type),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('transient call events are not persistent Notification categories', () {
    expect(NotificationCategory.forType(NotificationType.incomingCall), isNull);
    expect(NotificationCategory.forType(NotificationType.callRejected), isNull);
    expect(NotificationCategory.forType(NotificationType.callEnded), isNull);
  });

  test('persistent REST rows require a canonical notification ID', () {
    final NotificationItem item = NotificationItem.fromJson(<String, dynamic>{
      'type': 'follow',
      'title': 'Follower',
      'body': 'Someone followed you',
      'is_read': false,
      'created_at': '2026-08-31T10:00:00Z',
      'payload': <String, dynamic>{'follower': 'ACC-1'},
    });

    expect(item.id, isEmpty);
    expect(item.hasCanonicalPersistentId, isFalse);
  });

  test('uses backend actor_display_name with canonical actor ID', () {
    final NotificationItem item = NotificationItem.fromJson(<String, dynamic>{
      'id': 'NOTIF-1',
      'type': 'follow',
      'title': 'Follower',
      'body': 'Someone followed you',
      'actor': 'ACC-1',
      'actor_display_name': 'Jane Doe',
      'is_read': false,
      'created_at': '2026-08-31T10:00:00Z',
      'payload': <String, dynamic>{'follower': 'ACC-1'},
    });

    expect(item.id, 'NOTIF-1');
    expect(item.actorId, 'ACC-1');
    expect(item.actorName, 'Jane Doe');
    expect(item.hasCanonicalPersistentId, isTrue);
  });

  test('payload parses canonical message, review and account identifiers', () {
    final NotificationPayload payload =
        NotificationPayload.fromJson(<String, dynamic>{
          'conversation_id': 'CONV-1',
          'message_id': 'MSG-1',
          'sender_account_id': 'ACC-SENDER',
          'review_id': 'REV-1',
          'ad_id': 'AD-1',
          'account_id': 'ACC-TARGET',
        });

    expect(payload.conversationId, 'CONV-1');
    expect(payload.messageId, 'MSG-1');
    expect(payload.otherUser, 'ACC-SENDER');
    expect(payload.reviewId, 'REV-1');
    expect(payload.adId, 'AD-1');
  });

  test(
    'push item is persistent only when backend notification_id is present',
    () {
      final NotificationItem canonical = NotificationItem.fromPushData(
        data: <String, dynamic>{
          'notification_id': 'NOTIF-PUSH-1',
          'type': 'follow',
          'follower': 'ACC-1',
        },
        messageId: 'FCM-1',
      );
      final NotificationItem transient = NotificationItem.fromPushData(
        data: <String, dynamic>{'type': 'follow', 'follower': 'ACC-1'},
        messageId: 'FCM-2',
      );

      expect(canonical.hasCanonicalPersistentId, isTrue);
      expect(transient.hasCanonicalPersistentId, isFalse);
    },
  );
}
