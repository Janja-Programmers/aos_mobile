import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

class NotificationRealtimeListener {
  final Stream<RealtimeEvent> _eventStream;
  final NotificationController _controller;

  StreamSubscription<RealtimeEvent>? _sub;

  NotificationRealtimeListener({
    required Stream<RealtimeEvent> eventStream,
    required NotificationController controller,
  }) : _eventStream = eventStream,
       _controller = controller;

  // =====================================================
  // ATTACH
  // =====================================================
  void attach() {
    _sub = _eventStream.listen(
      _onEvent,
      onError: (e, s) {
        appLogger.e(
          'NotificationRealtimeListener stream error',
          error: e,
          stackTrace: s,
        );
      },
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================
  void dispose() {
    _sub?.cancel();
  }

  // =====================================================
  // EVENT HANDLER
  // =====================================================
  void _onEvent(RealtimeEvent event) {
    try {
      if (!_isNotificationEvent(event.type)) return;

      _handleNotificationEvent(event.type, event.data);
    } catch (e, s) {
      appLogger.e(
        'NotificationRealtimeListener event handling failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  // =====================================================
  // DETECT NOTIFICATION EVENTS
  // =====================================================
  bool _isNotificationEvent(RealtimeEventType type) {
    switch (type) {
      case RealtimeEventType.aosFollow:
      case RealtimeEventType.aosMissedCall:
      case RealtimeEventType.aosAdApproved:
      case RealtimeEventType.aosAdRejected:
      case RealtimeEventType.aosAdExpired:
      case RealtimeEventType.aosVerificationApproved:
      case RealtimeEventType.aosVerificationRejected:
      case RealtimeEventType.aosNewShort:
      case RealtimeEventType.aosShortLike:
      case RealtimeEventType.aosShortComment:
      case RealtimeEventType.aosCommentReply:
        return true;

      default:
        return false;
    }
  }

  // =====================================================
  // HANDLE NOTIFICATION EVENT
  // =====================================================
  void _handleNotificationEvent(
    RealtimeEventType type,
    Map<String, dynamic> data,
  ) {
    try {
      final notification = _mapToNotification(type, data);

      if (notification == null) {
        appLogger.w('⚠️ Failed to map notification: $data');
        return;
      }

      _controller.upsertNotification(notification);
    } catch (e, s) {
      appLogger.e('handleNotificationEvent failed', error: e, stackTrace: s);
    }
  }

  // =====================================================
  // MAP EVENT → NotificationItem
  // =====================================================
  NotificationItem? _mapToNotification(
    RealtimeEventType type,
    Map<String, dynamic> data,
  ) {
    try {
      final now = DateTime.now();

      switch (type) {
        case RealtimeEventType.aosFollow:
          final follower = data['follower']?.toString();
          if (follower == null) return null;

          return NotificationItem(
            id: 'follow_${follower}_$now',
            type: NotificationType.follow,
            title: 'New Follower',
            body: '$follower started following you',
            actorId: follower,
            actorName: follower,
            isRead: false,
            createdAt: now,
            payload: NotificationPayload.fromJson(data),
          );

        case RealtimeEventType.aosMissedCall:
          final caller = data['caller']?.toString();
          final callId = data['call_id']?.toString();
          if (caller == null || callId == null) return null;

          return NotificationItem(
            id: 'missed_call_$callId',
            type: NotificationType.missedCall,
            title: 'Missed Call',
            body: 'You missed a call from $caller',
            actorId: caller,
            actorName: caller,
            isRead: false,
            createdAt: now,
            payload: NotificationPayload.fromJson(data),
          );

        case RealtimeEventType.aosAdApproved:
          return NotificationItem(
            id: 'ad_approved_${data['ad_id']}_$now',
            type: NotificationType.adApproved,
            title: 'Ad Approved',
            body: 'Your ad has been approved',
            isRead: false,
            createdAt: now,
            payload: NotificationPayload.fromJson(data),
          );

        case RealtimeEventType.aosAdRejected:
          return NotificationItem(
            id: 'ad_rejected_${data['ad_id']}_$now',
            type: NotificationType.adRejected,
            title: 'Ad Rejected',
            body: 'Your ad was rejected',
            isRead: false,
            createdAt: now,
            payload: NotificationPayload.fromJson(data),
          );

        case RealtimeEventType.aosNewShort:
          final actor = data['actor']?.toString();
          return NotificationItem(
            id: 'short_${data['short_id']}_$now',
            type: NotificationType.liveStarted,
            title: 'New Short 🎬',
            body: '$actor posted a new short',
            actorId: actor,
            actorName: actor,
            isRead: false,
            createdAt: now,
            payload: NotificationPayload.fromJson(data),
          );

        default:
          return null;
      }
    } catch (e, s) {
      appLogger.e('_mapToNotification failed', error: e, stackTrace: s);
      return null;
    }
  }
}
