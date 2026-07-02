import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigationHandler {
  final GoRouter router;
  final LiveManager liveManager;

  String? _lastNavigationSignature;
  DateTime? _lastNavigationAt;

  NotificationNavigationHandler({
    required this.router,
    required this.liveManager,
  });

  // =====================================================
  // PUBLIC API
  // =====================================================

  void handleNotificationTap(NotificationItem notification) {
    _safeNavigate(
      source: 'notification:${notification.id}',
      type: notification.type,
      payload: notification.payload,
    );
  }

  void handlePayloadTap(Map<String, dynamic> payload) {
    final parsedPayload = NotificationPayload.fromJson(payload);
    final type = NotificationTypeX.fromBackendValue(
      _read(payload, 'event') ??
          _read(payload, 'notification_type') ??
          _read(payload, 'type') ??
          parsedPayload.event,
    );

    _safeNavigate(
      source: 'payload:${parsedPayload.event ?? type.value}',
      type: type,
      payload: parsedPayload,
    );
  }

  // =====================================================
  // SAFE WRAPPER
  // =====================================================

  void _safeNavigate({
    required String source,
    required NotificationType type,
    required NotificationPayload payload,
  }) {
    try {
      final signature = _navigationSignature(type: type, payload: payload);
      if (_isDuplicateNavigation(signature)) {
        return;
      }

      scheduleMicrotask(() {
        try {
          _navigateByType(type: type, payload: payload);
        } catch (e, s) {
          appLogger.e(
            'Notification navigation failed inside microtask',
            error: e,
            stackTrace: s,
          );
        }
      });
    } catch (e, s) {
      appLogger.e(
        'NotificationNavigationHandler failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  String _navigationSignature({
    required NotificationType type,
    required NotificationPayload payload,
  }) {
    return [
      type.value,
      payload.conversationId,
      payload.callId,
      payload.liveId,
      payload.adId,
      payload.shortId,
      payload.commentId,
      payload.userId,
      payload.route,
    ].whereType<String>().join('|');
  }

  bool _isDuplicateNavigation(String signature) {
    final now = DateTime.now();
    final lastAt = _lastNavigationAt;

    if (_lastNavigationSignature == signature &&
        lastAt != null &&
        now.difference(lastAt) < const Duration(milliseconds: 900)) {
      return true;
    }

    _lastNavigationSignature = signature;
    _lastNavigationAt = now;
    return false;
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
        _openMessage(payload);
        return;

      // =========================
      // CALLS
      // =========================
      case NotificationType.missedCall:
      case NotificationType.callRejected:
      case NotificationType.callEnded:
        _openCalls();
        return;

      case NotificationType.incomingCall:
        _openCalls();
        return;

      // =========================
      // FOLLOW / PROFILE
      // =========================
      case NotificationType.follow:
        _openProfile(payload);
        return;

      // =========================
      // ADS
      // =========================
      case NotificationType.adApproved:
      case NotificationType.adRejected:
      case NotificationType.adExpired:
        _openAd(payload);
        return;

      // =========================
      // VERIFICATION
      // =========================
      case NotificationType.verificationApproved:
        router.pushNamed(AppRoutes.nAccount);
        return;

      case NotificationType.verificationRejected:
        router.pushNamed(AppRoutes.nSellerVerification);
        return;

      // =========================
      // LIVE
      // =========================
      case NotificationType.liveStarted:
        _openLive(payload);
        return;

      // =========================
      // SHORTS
      // =========================
      case NotificationType.newShort:
      case NotificationType.shortLike:
      case NotificationType.shortComment:
      case NotificationType.commentReply:
        _openShorts(payload);
        return;

      case NotificationType.unknown:
        if (_tryDirectRoute(payload.route)) {
          return;
        }

        appLogger.w(
          '⚠️ Unknown notification type. Opening notifications list.',
        );
        router.pushNamed(AppRoutes.nNotification);
        return;
    }
  }

  // =====================================================
  // DESTINATIONS
  // =====================================================

  void _openMessage(NotificationPayload payload) {
    final conversationId = payload.conversationId;

    if (conversationId == null) {
      appLogger.w('⚠️ Missing conversationId. Opening messages tab.');
      router.pushNamed(
        AppRoutes.nConnect,
        queryParameters: {'tab': 'messages'},
      );
      return;
    }

    router.pushNamed(
      AppRoutes.nMessages,
      pathParameters: {'conversationId': conversationId},
      extra: {
        'otherUser': payload.otherUser ?? payload.userId ?? '',
        'displayName': payload.actorName ?? payload.otherUserName ?? '',
        'otherUserAvatar': payload.actorAvatar,
      },
    );
  }

  void _openCalls() {
    router.pushNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});
  }

  void _openProfile(NotificationPayload payload) {
    final user = payload.userId;

    if (user == null) {
      appLogger.w('⚠️ Missing userId. Opening notifications list.');
      router.pushNamed(AppRoutes.nNotification);
      return;
    }

    router.pushNamed(AppRoutes.nProfile, queryParameters: {'user': user});
  }

  void _openAd(NotificationPayload payload) {
    final adId = payload.adId;

    if (adId == null) {
      appLogger.w('⚠️ Missing adId. Opening My Ads.');
      router.pushNamed(AppRoutes.nMyAds);
      return;
    }

    router.pushNamed(AppRoutes.nAdDetails, pathParameters: {'id': adId});
  }

  void _openLive(NotificationPayload payload) {
    final liveId = payload.liveId;

    if (liveId == null) {
      appLogger.w('⚠️ Missing liveId. Opening feeds.');
      router.pushNamed(AppRoutes.nFeeds);
      return;
    }

    // Keep the state-driven live manager path for existing live flow.
    try {
      liveManager.joinLive(liveId: liveId);
      appLogger.i('✅ LiveManager.joinLive called');
      return;
    } catch (e, s) {
      appLogger.w(
        'LiveManager join failed. Falling back to live room route.',
        error: e,
        stackTrace: s,
      );
    }

    router.pushNamed(AppRoutes.nLiveRoom, queryParameters: {'live_id': liveId});
  }

  void _openShorts(NotificationPayload payload) {
    final shortId = payload.shortId ?? _readShortIdFromRoute(payload.route);

    if (shortId == null) {
      appLogger.w('⚠️ Missing shortId. Opening feeds.');
      router.pushNamed(AppRoutes.nFeeds);
      return;
    }

    router.pushNamed(
      AppRoutes.nShortDetail,
      queryParameters: {'short_id': shortId},
    );
  }

  bool _tryDirectRoute(String? route) {
    final cleanRoute = route?.trim();

    if (cleanRoute == null || cleanRoute.isEmpty) {
      return false;
    }

    // Only accept internal absolute app paths, not external URLs.
    if (!cleanRoute.startsWith('/') || cleanRoute.startsWith('//')) {
      appLogger.w('⚠️ Ignoring unsafe notification route: $cleanRoute');
      return false;
    }

    router.push(cleanRoute);
    return true;
  }
}

String? _readShortIdFromRoute(String? route) {
  final cleanRoute = route?.trim();
  if (cleanRoute == null || cleanRoute.isEmpty) return null;

  final uri = Uri.tryParse(cleanRoute);
  if (uri == null) return null;

  return _clean(
    uri.queryParameters['short_id'] ??
        uri.queryParameters['shortId'] ??
        uri.queryParameters['short'],
  );
}

String? _clean(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}

String? _read(Map<String, dynamic> json, String key) {
  final value = json[key];
  final text = value?.toString().trim();

  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }

  return text;
}
