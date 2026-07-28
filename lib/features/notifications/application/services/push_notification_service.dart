import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/device/device_id.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/incoming_call_bootstrapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final NotificationController _controller;
  final NotificationNavigationHandler _navigationHandler;
  final PushTokenRepository _pushRepo;
  final InAppNotificationService _bannerService;
  final IncomingCallBootstrapper _incomingCallBootstrapper;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;
  StreamSubscription<String>? _tokenRefreshSub;

  Timer? _tokenRetryTimer;

  bool _initialized = false;
  bool _isSettingUpToken = false;

  int _tokenRetryAttempt = 0;

  static const int _maxTokenRetryAttempts = 8;
  static const Duration _apnsWaitTimeout = Duration(seconds: 10);
  static const Duration _apnsPollInterval = Duration(milliseconds: 500);

  PushNotificationService({
    required FirebaseMessaging messaging,
    required NotificationController controller,
    required NotificationNavigationHandler navigationHandler,
    required PushTokenRepository pushRepo,
    required InAppNotificationService bannerService,
    required IncomingCallBootstrapper incomingCallBootstrapper,
  }) : _messaging = messaging,
       _controller = controller,
       _navigationHandler = navigationHandler,
       _pushRepo = pushRepo,
       _bannerService = bannerService,
       _incomingCallBootstrapper = incomingCallBootstrapper;

  // =====================================================
  // INIT
  // =====================================================
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    appLogger.i('🔔 PushNotificationService init');

    try {
      final permissionGranted = await _requestPermission();
      await _configureForegroundPresentation();

      _listenTokenRefresh();
      _listenForeground();
      _listenNotificationTap();

      await _handleTerminatedLaunch();
      await _handlePendingCallkitPayload();

      if (permissionGranted) {
        await _setupToken();
      } else {
        appLogger.w(
          '🔕 Notifications permission not granted. Token setup skipped.',
        );
      }
    } catch (e, s) {
      appLogger.w(
        '⚠️ PushNotificationService init completed with non-fatal issue',
        error: e,
        stackTrace: s,
      );

      _scheduleTokenRetry();
    }
  }

  // =====================================================
  // PERMISSION
  // =====================================================
  Future<bool> _requestPermission() async {
    final currentSettings = await _messaging.getNotificationSettings();
    final currentStatus = currentSettings.authorizationStatus;

    if (currentStatus == AuthorizationStatus.authorized ||
        currentStatus == AuthorizationStatus.provisional) {
      return true;
    }

    // A denied decision must not trigger another launch-time request. The user
    // can change it later from Android/iOS application settings.
    if (currentStatus == AuthorizationStatus.denied) {
      return false;
    }

    final requestedSettings = await _messaging.requestPermission();
    final requestedStatus = requestedSettings.authorizationStatus;

    return requestedStatus == AuthorizationStatus.authorized ||
        requestedStatus == AuthorizationStatus.provisional;
  }

  Future<void> _configureForegroundPresentation() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e, s) {
      appLogger.w(
        '⚠️ Failed to configure foreground notification presentation',
        error: e,
        stackTrace: s,
      );
    }
  }

  // =====================================================
  // DEVICE
  // =====================================================
  PushDeviceType get _deviceType {
    if (Platform.isIOS) return PushDeviceType.ios;
    return PushDeviceType.android;
  }

  // =====================================================
  // TOKEN
  // =====================================================
  Future<void> _setupToken() async {
    if (_isSettingUpToken) {
      return;
    }

    _isSettingUpToken = true;

    try {
      if (Platform.isIOS) {
        final apnsToken = await _waitForApnsToken();

        if (apnsToken == null || apnsToken.isEmpty) {
          appLogger.w(
            '🔔 APNS token not ready yet. Push token registration will retry.',
          );

          _scheduleTokenRetry();
          return;
        }

        appLogger.i('🔔 APNS token ready');
      }

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        appLogger.w(
          '🔔 FCM token not ready yet. Push token registration will retry.',
        );

        _scheduleTokenRetry();
        return;
      }

      await _registerToken(token);

      _tokenRetryAttempt = 0;
      _tokenRetryTimer?.cancel();
      _tokenRetryTimer = null;

      appLogger.i('🔔 Push token registered');
    } on FirebaseException catch (e, s) {
      if (e.code == 'apns-token-not-set') {
        appLogger.w(
          '🔔 APNS token not set yet. Push token registration will retry.',
          error: e,
          stackTrace: s,
        );

        _scheduleTokenRetry();
        return;
      }

      appLogger.w(
        '⚠️ Push token setup failed. Will retry.',
        error: e,
        stackTrace: s,
      );

      _scheduleTokenRetry();
    } catch (e, s) {
      appLogger.w(
        '⚠️ Push token setup failed. Will retry.',
        error: e,
        stackTrace: s,
      );

      _scheduleTokenRetry();
    } finally {
      _isSettingUpToken = false;
    }
  }

  Future<String?> _waitForApnsToken() async {
    final deadline = DateTime.now().add(_apnsWaitTimeout);

    while (DateTime.now().isBefore(deadline)) {
      try {
        final token = await _messaging.getAPNSToken();

        if (token != null && token.isNotEmpty) {
          return token;
        }
      } catch (e, s) {
        appLogger.w(
          '🔔 APNS token check failed. Waiting briefly.',
          error: e,
          stackTrace: s,
        );
      }

      await Future<void>.delayed(_apnsPollInterval);
    }

    return null;
  }

  void _scheduleTokenRetry() {
    if (_tokenRetryAttempt >= _maxTokenRetryAttempts) {
      appLogger.w(
        '🔔 Push token registration retry limit reached. Will wait for next app start/token refresh.',
      );
      return;
    }

    _tokenRetryTimer?.cancel();

    _tokenRetryAttempt += 1;

    final delaySeconds = _tokenRetryAttempt <= 3
        ? 3
        : _tokenRetryAttempt <= 5
        ? 10
        : 30;

    appLogger.i(
      '🔔 Scheduling push token retry attempt $_tokenRetryAttempt in ${delaySeconds}s',
    );

    _tokenRetryTimer = Timer(Duration(seconds: delaySeconds), _setupToken);
  }

  Future<void> _registerToken(String token) async {
    final deviceId = await DeviceId.get();

    await _pushRepo.registerPushToken(
      PushTokenDevice(
        token: token,
        deviceType: _deviceType,
        deviceId: deviceId,
      ),
    );
  }

  void _listenTokenRefresh() {
    unawaited(_tokenRefreshSub?.cancel());

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      if (newToken.trim().isEmpty) {
        return;
      }

      try {
        await _registerToken(newToken);

        _tokenRetryAttempt = 0;
        _tokenRetryTimer?.cancel();
        _tokenRetryTimer = null;

        appLogger.i('🔔 Refreshed FCM token registered');
      } catch (e, s) {
        appLogger.w(
          '⚠️ FCM token refresh registration failed. Will retry.',
          error: e,
          stackTrace: s,
        );

        _scheduleTokenRetry();
      }
    });
  }

  // =====================================================
  // FOREGROUND
  // =====================================================
  void _listenForeground() {
    unawaited(_foregroundSub?.cancel());

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) async {
      try {
        final notification = _mapMessageToNotification(message);
        if (notification == null) return;

        _controller.upsertNotification(notification);

        if (notification.type == NotificationType.incomingCall) {
          await _incomingCallBootstrapper.handlePushPayload(
            notification.payload.extra,
          );
          return;
        }

        _bannerService.show(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          onTap: () {
            _navigationHandler.handleNotificationTap(notification);
          },
        );
      } catch (e, s) {
        appLogger.e('Foreground push handling failed', error: e, stackTrace: s);
      }
    });
  }

  // =====================================================
  // TAP (BACKGROUND)
  // =====================================================
  void _listenNotificationTap() {
    unawaited(_tapSub?.cancel());

    _tapSub = FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      try {
        appLogger.i('📲 Notification tapped (background): ${message.data}');

        final notification = _mapMessageToNotification(message);

        if (notification == null) return;

        if (notification.type == NotificationType.incomingCall) {
          final handled = await _incomingCallBootstrapper.handlePushPayload(
            notification.payload.extra,
          );

          if (!handled) {
            appLogger.i(
              '📞 Incoming call tap ignored because the call is no longer actionable',
            );
          }
          return;
        }

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

      if (notification.type == NotificationType.incomingCall) {
        final handled = await _incomingCallBootstrapper.handlePushPayload(
          notification.payload.extra,
        );

        if (!handled) {
          appLogger.i(
            '📞 Terminated incoming call launch ignored because the call is no longer actionable',
          );
        }
        return;
      }

      _navigationHandler.handleNotificationTap(notification);
    } catch (e, s) {
      appLogger.e('Terminated push handling failed', error: e, stackTrace: s);
    }
  }

  Future<void> _handlePendingCallkitPayload() async {
    try {
      const store = CallKitPendingPayloadStore();
      final payload = await store.read();

      if (payload == null || payload.isEmpty) {
        return;
      }

      final handled = await _incomingCallBootstrapper.handlePushPayload(
        payload,
      );

      if (!handled) {
        await store.clear();
      }
    } catch (e, s) {
      appLogger.w(
        '⚠️ Pending CallKit payload recovery failed',
        error: e,
        stackTrace: s,
      );
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

      final event =
          data['event']?.toString() ??
          data['notification_type']?.toString() ??
          data['type']?.toString();

      if (event == null || event.trim().isEmpty) {
        appLogger.w('⚠️ Missing notification type/event: $data');
        return null;
      }

      final notification = NotificationItem.fromPushData(
        data: data,
        messageId: message.messageId,
        title: message.notification?.title,
        body: message.notification?.body,
        sentTime: message.sentTime,
      );

      if (notification.type == NotificationType.unknown) {
        appLogger.w('⚠️ Unknown notification event: $event');
      }

      return notification;
    } catch (e, s) {
      appLogger.e('_mapMessageToNotification failed', error: e, stackTrace: s);
      return null;
    }
  }

  // =====================================================
  // RESET
  // =====================================================
  void reset() {
    _initialized = false;
    _isSettingUpToken = false;
    _tokenRetryAttempt = 0;

    _tokenRetryTimer?.cancel();
    unawaited(_foregroundSub?.cancel());
    unawaited(_tapSub?.cancel());
    unawaited(_tokenRefreshSub?.cancel());

    _tokenRetryTimer = null;
    _foregroundSub = null;
    _tapSub = null;
    _tokenRefreshSub = null;
  }

  // =====================================================
  // DISPOSE
  // =====================================================
  void dispose() {
    _tokenRetryTimer?.cancel();
    unawaited(_foregroundSub?.cancel());
    unawaited(_tapSub?.cancel());
    unawaited(_tokenRefreshSub?.cancel());

    _tokenRetryTimer = null;
    _foregroundSub = null;
    _tapSub = null;
    _tokenRefreshSub = null;
  }
}
