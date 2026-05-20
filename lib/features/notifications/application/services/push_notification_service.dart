import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:africaonlinestores/core/device/device_id.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final NotificationController _controller;
  final NotificationNavigationHandler _navigationHandler;
  final PushTokenRepository _pushRepo;
  final InAppNotificationService _bannerService;

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

    appLogger.i('🔔 PushNotificationService init');

    try {
      await _requestPermission();

      _listenTokenRefresh();
      _listenForeground();
      _listenNotificationTap();

      await _handleTerminatedLaunch();

      await _setupToken();
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
  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
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

      await Future.delayed(_apnsPollInterval);
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

    _tokenRetryTimer = Timer(Duration(seconds: delaySeconds), () {
      _setupToken();
    });
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
    _tokenRefreshSub?.cancel();

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
    _foregroundSub?.cancel();

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
  }

  // =====================================================
  // TAP (BACKGROUND)
  // =====================================================
  void _listenNotificationTap() {
    _tapSub?.cancel();

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

      final notificationId =
          data['notification_id']?.toString().trim().isNotEmpty == true
          ? data['notification_id'].toString()
          : message.messageId?.trim().isNotEmpty == true
          ? message.messageId!
          : 'push_${now.microsecondsSinceEpoch}';

      return NotificationItem(
        id: notificationId,
        type: type,
        title:
            message.notification?.title ??
            data['title']?.toString() ??
            'Notification',
        body: message.notification?.body ?? data['body']?.toString() ?? '',
        isRead: false,
        createdAt: message.sentTime ?? now,
        payload: NotificationPayload.fromJson(data),
      );
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
    _foregroundSub?.cancel();
    _tapSub?.cancel();
    _tokenRefreshSub?.cancel();

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
    _foregroundSub?.cancel();
    _tapSub?.cancel();
    _tokenRefreshSub?.cancel();

    _tokenRetryTimer = null;
    _foregroundSub = null;
    _tapSub = null;
    _tokenRefreshSub = null;
  }
}
