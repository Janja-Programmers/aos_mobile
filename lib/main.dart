import 'dart:async';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/core/notifications/android_notification_channel.dart';
import 'package:africaonlinestores/core/privacy/privacy_cover.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/theme/theme_prefs.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/listeners/call_audio_feedback_listener.dart';
import 'package:africaonlinestores/features/connect/calls/application/listeners/call_navigation_listener.dart';
import 'package:africaonlinestores/features/connect/calls/application/listeners/callkit_state_listener.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/call_runtime_log.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_payload_mapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:africaonlinestores/features/live/application/listeners/live_navigation_listeners.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_banner_listener.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/listeners/upload_short_listener.dart';
import 'package:africaonlinestores/firebase_options.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/active_call_overlay.dart';
import 'package:africaonlinestores/shared/widgets/app_error_fallback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final data = asJsonMap(message.data);

  CallRuntimeLog.write(
    'fcm_background_received',
    callId: data['call_id']?.toString(),
    details: <String, Object?>{
      'has_notification_block': message.notification != null,
      'event': data['event']?.toString(),
      'type': data['type']?.toString(),
    },
  );

  final event = _normalizePushType(data['event']);
  final type = _normalizePushType(data['type']);
  final notificationType = _normalizePushType(data['notification_type']);
  final action = _normalizePushType(data['action']);

  final isIncomingCall =
      event == 'aos_incoming_call' ||
      event == 'incoming_call' ||
      event == 'call' ||
      type == 'incoming_call' ||
      type == 'call' ||
      notificationType == 'incoming_call' ||
      notificationType == 'call' ||
      action == 'incoming_call' ||
      action == 'call';

  if (!isIncomingCall) {
    CallRuntimeLog.write('fcm_background_not_call');
    return;
  }

  final callId = data['call_id']?.toString().trim();
  if (callId == null || callId.isEmpty || callId.toLowerCase() == 'null') {
    CallRuntimeLog.write('fcm_background_missing_call_id');
    return;
  }

  final params = const CallKitPayloadMapper().fromPushData(data);
  final pendingPayload = asJsonMap(params.extra ?? data);

  await const CallKitPendingPayloadStore().save(pendingPayload);

  try {
    CallRuntimeLog.write('callkit_show_requested', callId: callId);
    await FlutterCallkitIncoming.showCallkitIncoming(params);
    CallRuntimeLog.write('callkit_show_completed', callId: callId);
  } catch (error) {
    CallRuntimeLog.write(
      'callkit_show_failed',
      callId: callId,
      details: <String, Object?>{'error_type': error.runtimeType.toString()},
    );
    rethrow;
  }
}

String? _normalizePushType(Object? value) {
  final text = value?.toString().trim().toLowerCase();

  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }

  return text.replaceAll('-', '_').replaceAll(' ', '_');
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        appLogger.e('Uncaught platform error', error: error, stackTrace: stack);
        return true;
      };

      ErrorWidget.builder = (FlutterErrorDetails details) {
        return const AppErrorFallback();
      };

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosInit = DarwinInitializationSettings();

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          appLogger.i('Local notification response received');
        },
      );

      final androidNotifications = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidNotifications?.createNotificationChannel(
        AndroidNotificationConfig.general,
      );

      await androidNotifications?.createNotificationChannel(
        AndroidNotificationConfig.calls,
      );

      final savedTheme = await ThemePrefs.readThemeMode();
      final initialTheme = savedTheme ?? ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();

      runApp(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith(
              (ref) => ThemeController(initialTheme),
            ),
            onboardingStorageProvider.overrideWith(
              (ref) => OnboardingStorage(prefs),
            ),
          ],
          child: const AppRoot(),
        ),
      );
    },
    (error, stack) {
      appLogger.e('Uncaught zone error', error: error, stackTrace: stack);
    },
  );
}

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  ProviderSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    unawaited(ref.read(appBootstrapControllerProvider.notifier).initialize());

    _authSub = ref.listenManual<AuthState>(authControllerProvider, (
      prev,
      next,
    ) async {
      final realtime = ref.read(realtimeServiceProvider);

      /// -----------------------------
      /// AUTHENTICATED → CONNECT + NOTIFICATIONS
      /// -----------------------------
      if (next is AuthAuthenticated) {
        // 🔌 Realtime
        if (!realtime.isConnected) {
          realtime.connect(
            baseUrl: AppConfig.baseUrl.trim(),
            siteName: AppConfig.siteName,
            sid: next.sid,
            email: next.user.email,
          );
        }

        // 🔔 Initialize Push Notifications
        try {
          final pushService = ref.read(pushNotificationServiceProvider);
          await pushService.init();
        } catch (error, stackTrace) {
          appLogger.w(
            'Push notification initialization failed',
            error: error,
            stackTrace: stackTrace,
          );
        }

        // 📥 Load Notifications (initial fetch)
        try {
          await ref
              .read(notificationControllerProvider.notifier)
              .loadNotifications();
        } catch (error, stackTrace) {
          appLogger.w(
            'Initial notification loading failed',
            error: error,
            stackTrace: stackTrace,
          );
        }

        return;
      }

      /// -----------------------------
      /// GUEST → CLEANUP
      /// -----------------------------
      if (next is AuthGuest) {
        if (realtime.isConnected) {
          realtime.disconnect();
        }

        ref.read(pushNotificationServiceProvider).reset();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const RootLifecycleCoordinator(child: AOSApp());
  }
}

class AOSApp extends ConsumerWidget {
  const AOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const uploadSessionId = 'global_upload_session';

    ref.watch(uploadRouterListenerProvider(uploadSessionId));

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);

    ref.watch(socketCallListenerProvider);
    ref.watch(notificationRealtimeListenerProvider);
    ref.watch(protectedNavigationCoordinatorProvider);

    final PrivacyCoverState privacyCover = ref.watch(privacyCoverStateProvider);

    return MaterialApp.router(
      title: 'Africa Online Stores',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: resolveLocale(prefs),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: kSupportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final location = router.routerDelegate.currentConfiguration.uri
            .toString();

        final isOnActiveCall = location.contains(AppRoutes.callSession);

        final Widget protectedApplication = Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CallAudioFeedbackListener(
              child: CallKitStateListener(
                child: CallNavigationListener(
                  child: LiveNavigationListener(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            if (!isOnActiveCall) const ActiveCallOverlay(),
            const InAppBannerListener(),
          ],
        );

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            IgnorePointer(
              ignoring: privacyCover.isVisible,
              child: ExcludeSemantics(
                excluding: privacyCover.isVisible,
                child: protectedApplication,
              ),
            ),
            if (privacyCover.isVisible) const PrivacyCover(),
          ],
        );
      },
    );
  }
}
