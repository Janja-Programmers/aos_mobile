import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';

class NotificationNavigationHandler {
  final GoRouter router;
  final LiveManager liveManager;

  NotificationNavigationHandler({
    required this.router,
    required this.liveManager,
  });

  // =====================================================
  // HANDLE TAP
  // =====================================================
  void handleNotificationTap(NotificationItem notification) {
    try {
      appLogger.i(
        '🔔 Navigation → handleNotificationTap: ${notification.id} (${notification.type})',
      );

      final payload = notification.payload;

      _navigateByType(type: notification.type, payload: payload);
    } catch (e, s) {
      appLogger.e(
        'NotificationNavigationHandler failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  // =====================================================
  // ROUTING LOGIC
  // =====================================================
  void _navigateByType({
    required NotificationType type,
    required NotificationPayload payload,
  }) {
    switch (type) {
      // =========================
      // CHAT
      // =========================
      case NotificationType.message:
        final conversationId = payload.conversationId;

        if (conversationId == null) {
          appLogger.w('⚠️ Missing conversationId');
          return;
        }

        router.pushNamed(
          AppRoutes.nConnect,
          queryParameters: {'conversationId': conversationId},
        );
        return;

      // =========================
      // CALLS
      // =========================
      case NotificationType.missedCall:
        router.goNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});
        return;

      // =========================
      // FOLLOW
      // =========================
      case NotificationType.follow:
        final userId = payload.userId;

        if (userId == null) {
          appLogger.w('⚠️ Missing userId for follow');
          return;
        }

        router.pushNamed(
          AppRoutes.nAccount,
          queryParameters: {'userId': userId},
        );
        return;

      // =========================
      // ADS
      // =========================
      case NotificationType.adApproved:
      case NotificationType.adRejected:
        final adId = payload.adId;

        if (adId == null) {
          appLogger.w('⚠️ Missing adId');
          return;
        }

        router.pushNamed(AppRoutes.nAdDetails, queryParameters: {'adId': adId});
        return;

      // =========================
      // LIVE (STATE-DRIVEN)
      // =========================
      case NotificationType.liveStarted:
        final liveId = payload.liveId;

        if (liveId == null) {
          appLogger.w('⚠️ Missing liveId');
          return;
        }

        appLogger.i('🎥 Triggering live join flow: $liveId');

        _handleLiveStart(liveId);
        return;

      // =========================
      // DEFAULT
      // =========================
      case NotificationType.unknown:
      default:
        appLogger.w('⚠️ No navigation defined for type: $type');
        return;
    }
  }

  // =====================================================
  // LIVE FLOW
  // =====================================================
  void _handleLiveStart(String liveId) {
    try {
      liveManager.joinLive(liveId: liveId);

      appLogger.i('✅ LiveManager.joinLive called');
    } catch (e, s) {
      appLogger.e('❌ Failed to trigger live join', error: e, stackTrace: s);
    }
  }
}
