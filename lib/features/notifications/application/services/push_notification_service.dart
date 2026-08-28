import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/device/device_id.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/callkit_recovery_service.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/incoming_call_bootstrapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/call_runtime_log.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/incoming_call_push_freshness.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final NotificationController _controller;
  final NotificationNavigationHandler _navigationHandler;
  final PushTokenRepository _pushRepo;
  final InAppNotificationService _bannerService;
  final IncomingCallBootstrapper _incomingCallBootstrapper;
  final CallKitRecoveryService _callKitRecoveryService;

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
  static const String _notificationPermissionRequestedKey =
      'aos_notification_permission_requested_v1';

  PushNotificationService({
    required FirebaseMessaging messaging,
    required NotificationController controller,
    required NotificationNavigationHandler navigationHandler,
    required PushTokenRepository pushRepo,
    required InAppNotificationService bannerService,
    required IncomingCallBootstrapper incomingCallBootstrapper,
    required CallKitRecoveryService callKitRecoveryService,
  }) : _messaging = messaging,
       _controller = controller,
       _navigationHandler = navigationHandler,
       _pushRepo = pushRepo,
       _bannerService = bannerService,
       _incomingCallBootstrapper = incomingCallBootstrapper,
       _callKitRecoveryService = callKitRecoveryService;

  // =====================================================
  // INIT
  // =====================================================
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    appLogger.i('🔔 PushNotificationService init');

    var permissionGranted = false;
    try {
      permissionGranted = await _requestPermission();
    } catch (error, stackTrace) {
      // Permission inspection must not prevent FCM listeners or token
      // registration from starting. Delivery and display are separate states.
      appLogger.w(
        '⚠️ Notification permission inspection failed; continuing push setup',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _configureForegroundPresentation();

    _listenTokenRefresh();
    _listenForeground();
    _listenNotificationTap();

    await _callKitRecoveryService.recover();
    await _handleTerminatedLaunch();

    if (!permissionGranted) {
      appLogger.w(
        '🔕 Notification display permission is not granted. '
        'FCM token registration will still continue so the backend can '
        'target this device and diagnostics can distinguish delivery from '
        'display-permission failures.',
      );
    }

    // FCM token registration must not be gated by POST_NOTIFICATIONS. The
    // backend needs a current token even when visible notifications are
    // disabled, and Android data messages may still reach the application.
    await _setupToken();

    appLogger.i('🔔 PushNotificationService init completed');
  }

  // =====================================================
  // PERMISSION
  // =====================================================
  Future<bool> _requestPermission() async {
    final currentSettings = await _messaging.getNotificationSettings();
    final currentStatus = currentSettings.authorizationStatus;

    appLogger.i(
      '🔔 Notification permission before request: ${currentStatus.name}',
    );

    if (currentStatus == AuthorizationStatus.authorized ||
        currentStatus == AuthorizationStatus.provisional) {
      return true;
    }

    // On Apple platforms, `denied` is an actual user decision and the app
    // cannot prompt again. Android 13+ is different: Firebase reports `denied`
    // both before the first request and after a refusal. Persist whether AOS has
    // already requested permission so first launch is not mistaken for denial.
    if (Platform.isIOS && currentStatus == AuthorizationStatus.denied) {
      appLogger.w('🔕 Notification permission is denied on iOS');
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    final alreadyRequested =
        preferences.getBool(_notificationPermissionRequestedKey) ?? false;

    if (Platform.isAndroid &&
        currentStatus == AuthorizationStatus.denied &&
        alreadyRequested) {
      appLogger.w(
        '🔕 Notification permission was previously requested and remains denied',
      );
      return false;
    }

    final requestedSettings = await _messaging.requestPermission();
    await preferences.setBool(_notificationPermissionRequestedKey, true);

    final requestedStatus = requestedSettings.authorizationStatus;
    appLogger.i(
      '🔔 Notification permission after request: ${requestedStatus.name}',
    );

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

      appLogger.i(
        '🔔 FCM token obtained; length=${token.length}. Registering device.',
      );

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
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw const Failure(
        'FCM returned an empty device token.',
        error: 'EMPTY_PUSH_TOKEN',
      );
    }

    final deviceId = await DeviceId.get();

    appLogger.i(
      '🔔 Registering ${_deviceType.value} push token with backend '
      '(tokenLength=${normalizedToken.length}, deviceIdReady=${deviceId.trim().isNotEmpty})',
    );

    final result = await _pushRepo.registerPushToken(
      PushTokenDevice(
        token: normalizedToken,
        deviceType: _deviceType,
        deviceId: deviceId,
      ),
    );

    final failure = result.leftOrNull;
    if (failure != null) {
      appLogger.e(
        '🔔 Backend push-token registration failed '
        '(error=${failure.error ?? 'UNKNOWN'}, status=${failure.statusCode ?? 'none'})',
        error: failure,
      );
      throw failure;
    }

    if (result.rightOrNull != true) {
      throw const Failure(
        'Backend did not acknowledge push-token registration.',
        error: 'PUSH_TOKEN_NOT_ACKNOWLEDGED',
      );
    }

    appLogger.i('🔔 Backend acknowledged push-token registration');
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
        final data = asJsonMap(message.data);
        final callId = _cleanValue(data['call_id']) ?? _cleanValue(data['id']);
        final event = _messageEvent(data);

        appLogger.i(
          '🔔 Foreground FCM received '
          '(event=${event ?? 'unknown'}, callId=${callId ?? 'none'}, '
          'hasNotificationBlock=${message.notification != null}, '
          'messageId=${message.messageId ?? 'none'})',
        );

        if (_isIncomingCallEvent(event)) {
          CallRuntimeLog.write(
            'fcm_foreground_received',
            callId: callId,
            details: <String, Object?>{
              'has_notification_block': message.notification != null,
            },
          );
          if (!_isFreshIncomingCall(message)) {
            CallRuntimeLog.write('fcm_foreground_stale', callId: callId);
            return;
          }
        }

        final notification = _mapMessageToNotification(message);
        if (notification == null) return;

        if (notification.type == NotificationType.incomingCall) {
          // Incoming calls are transient backend events. They must not be
          // inserted into the persistent notification state.
          await _incomingCallBootstrapper.handlePushPayload(
            notification.payload.extra,
          );
          return;
        }

        _controller.upsertNotification(notification);

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
        final data = asJsonMap(message.data);
        final callId = _cleanValue(data['call_id']) ?? _cleanValue(data['id']);
        final event = _messageEvent(data);

        appLogger.i(
          '📲 Background notification opened '
          '(event=${event ?? 'unknown'}, callId=${callId ?? 'none'}, '
          'hasNotificationBlock=${message.notification != null}, '
          'messageId=${message.messageId ?? 'none'})',
        );

        if (_isIncomingCallEvent(event) && !_isFreshIncomingCall(message)) {
          CallRuntimeLog.write('fcm_opened_stale', callId: callId);
          return;
        }

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
    try {
      final message = await _messaging.getInitialMessage();

      if (message == null) return;

      final data = asJsonMap(message.data);
      final callId = _cleanValue(data['call_id']) ?? _cleanValue(data['id']);
      final event = _messageEvent(data);

      appLogger.i(
        '🚀 App opened from terminated push '
        '(event=${event ?? 'unknown'}, callId=${callId ?? 'none'}, '
        'hasNotificationBlock=${message.notification != null}, '
        'messageId=${message.messageId ?? 'none'})',
      );

      if (_isIncomingCallEvent(event) && !_isFreshIncomingCall(message)) {
        CallRuntimeLog.write('fcm_terminated_stale', callId: callId);
        return;
      }

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

      final event = _messageEvent(data);

      if (event == null) {
        appLogger.w(
          '⚠️ Push payload is missing event/type '
          '(keys=${data.keys.toList(growable: false)})',
        );
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

  String? _messageEvent(Map<String, dynamic> data) {
    return _cleanValue(data['event']) ??
        _cleanValue(data['notification_type']) ??
        _cleanValue(data['type']);
  }

  bool _isIncomingCallEvent(String? value) {
    final event = value
        ?.trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return event == 'aos_incoming_call' ||
        event == 'incoming_call' ||
        event == 'call';
  }

  bool _isFreshIncomingCall(RemoteMessage message) {
    return isIncomingCallPushFresh(
      sentTime: message.sentTime,
      now: DateTime.now(),
    );
  }

  String? _cleanValue(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
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
