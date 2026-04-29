import 'dart:async';

import 'package:africaonlinestores/core/device/device_id.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final NotificationController _controller;
  final NotificationNavigationHandler _navigationHandler;
  final PushTokenRepository _pushRepo;
  final InAppNotificationService _bannerService;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;
  StreamSubscription<String>? _tokenRefreshSub;

  bool _initialized = false;

  PushNotificationService({
    required FirebaseMessaging messaging,
    required NotificationController controller,
    required NotificationNavigationHandler navigationHandler,
    required PushTokenRepository pushRepo,
    required InAppNotificationService bannerService,
  }) : _messaging = messaging,
       _controller = controller,
       _navigationHandler = navigationHandler,
       _pushRepo = pushRepo,
       _bannerService = bannerService;

  // =====================================================
  // INIT
  // =====================================================
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    try {
      appLogger.i('🔔 PushNotificationService init');

      await _requestPermission();
      await _setupToken();

      _listenForeground();
      _listenNotificationTap();

      await _handleTerminatedLaunch();
    } catch (e, s) {
      appLogger.e(
        'PushNotificationService init failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  // =====================================================
  // PERMISSION
  // =====================================================
  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  // =====================================================
  // TOKEN
  // =====================================================
  Future<void> _setupToken() async {
    final token = await _messaging.getToken();

    if (token == null) {
      appLogger.w('⚠️ FCM token is null');
      return;
    }

    final deviceId = await DeviceId.get();

    await _pushRepo.registerPushToken(
      PushTokenDevice(
        token: token,
        deviceType: PushDeviceType.android,
        deviceId: deviceId,
      ),
    );

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      await _pushRepo.registerPushToken(
        PushTokenDevice(
          token: newToken,
          deviceType: PushDeviceType.android,
          deviceId: deviceId,
        ),
      );
    });
  }

  // =====================================================
  // FOREGROUND
  // =====================================================

  void _listenForeground() {
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      try {
        appLogger.i('📩 Foreground push received: ${message.data}');

        final notification = _mapMessageToNotification(message);
        if (notification == null) return;

        _controller.upsertNotification(notification);

        _bannerService.show(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          onTap: () {
            appLogger.i('📲 Foreground banner tapped: ${notification.id}');
            _navigationHandler.handleNotificationTap(notification);
          },
        );
      } catch (e, s) {
        appLogger.e('Foreground push handling failed', error: e, stackTrace: s);
      }
    });

    // CUSTOMBANNER Already Handles this

    // flutterLocalNotificationsPlugin.show(
    //   notification.hashCode,
    //   notification.title,
    //   notification.body,
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       AndroidNotificationConfig.channel.id,
    //       AndroidNotificationConfig.channel.name,
    //       channelDescription: AndroidNotificationConfig.channel.description,
    //       importance: Importance.high,
    //       priority: Priority.high,
    //     ),
    //   ),
    // );
  }

  // =====================================================
  // TAP (BACKGROUND)
  // =====================================================
  void _listenNotificationTap() {
    _tapSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      try {
        appLogger.i('📲 Notification tapped (background): ${message.data}');

        final notification = _mapMessageToNotification(message);

        if (notification == null) return;

        _navigationHandler.handleNotificationTap(notification);
      } catch (e, s) {
        appLogger.e(
          'Notification tap handling failed',
          error: e,
          stackTrace: s,
        );
      }
    });
  }

  // =====================================================
  // TERMINATED
  // =====================================================
  Future<void> _handleTerminatedLaunch() async {
    final message = await _messaging.getInitialMessage();

    if (message == null) return;

    try {
      appLogger.i('🚀 App opened from terminated push');

      final notification = _mapMessageToNotification(message);

      if (notification == null) return;

      _navigationHandler.handleNotificationTap(notification);
    } catch (e, s) {
      appLogger.e('Terminated push handling failed', error: e, stackTrace: s);
    }
  }

  // =====================================================
  // MAP MESSAGE → NotificationItem
  // =====================================================
  NotificationItem? _mapMessageToNotification(RemoteMessage message) {
    try {
      final data = message.data;

      if (data.isEmpty) {
        appLogger.w('⚠️ Empty push payload');
        return null;
      }

      final typeString = data['type']?.toString();

      if (typeString == null) {
        appLogger.w('⚠️ Missing notification type');
        return null;
      }

      final type = NotificationTypeX.fromString(typeString);

      final now = DateTime.now();

      return NotificationItem(
        id: data['notification_id']?.toString() ?? 'push_$now',
        type: type,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        isRead: false,
        createdAt: now,
        payload: NotificationPayload.fromJson(data),
      );
    } catch (e, s) {
      appLogger.e('_mapMessageToNotification failed', error: e, stackTrace: s);
      return null;
    }
  }

  void reset() {
    _initialized = false;

    _foregroundSub?.cancel();
    _tapSub?.cancel();
  }

  // =====================================================
  // DISPOSE
  // =====================================================
  void dispose() {
    _foregroundSub?.cancel();
    _tapSub?.cancel();
    _tokenRefreshSub?.cancel();
  }
}
