import 'package:africaonlinestores/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:africaonlinestores/l10n/gen/app_localizations.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/notifications/android_notification_channel.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/theme/theme_prefs.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/listeners/call_navigation_listener.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/live/application/listeners/live_navigation_listeners.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/listeners/upload_short_listener.dart';

import 'package:africaonlinestores/shared/widgets/active_call_overlay.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 🔥 MUST initialize Firebase here again (separate isolate)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You CANNOT use:
  // - ref
  // - navigation
  // - UI

  // ✅ Only safe operations
  appLogger.i('[FCM BG] Message received: ${message.data}');

  // Optional (future):
  // - Save to local storage (Hive/SharedPreferences)
  // - Schedule local notification
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (response) {
      appLogger.i('Notification tapped: ${response.payload}');
    },
  );

  // 🔥 CREATE CHANNEL
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(AndroidNotificationConfig.channel);

  final savedTheme = await ThemePrefs.readThemeMode();
  final initialTheme = savedTheme ?? ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeController(initialTheme)),
        onboardingStorageProvider.overrideWith(
          (ref) => OnboardingStorage(prefs),
        ),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  bool _bootstrapStarted = false;

  @override
  void initState() {
    super.initState();

    appLogger.i('[App] Bootstrapping...');
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ Ensure bootstrap runs ONCE (safe)
    if (!_bootstrapStarted) {
      _bootstrapStarted = true;

      Future.microtask(() {
        ref.read(appBootstrapControllerProvider.notifier).initialize();
      });
    }

    /// ✅ SAFE place for ref.listen
    ref.listen<AuthState>(authControllerProvider, (prev, next) async {
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
        } catch (_) {}

        // 📥 Load Notifications (initial fetch)
        try {
          await ref
              .read(notificationControllerProvider.notifier)
              .loadNotifications();
        } catch (_, _) {}

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

    return const AOSApp();
  }
}

class AOSApp extends ConsumerWidget {
  const AOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadSessionId = "global_upload_session";

    ref.watch(uploadRouterListenerProvider(uploadSessionId));

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);

    ref.watch(socketCallListenerProvider);

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

        return Stack(
          children: [
            CallNavigationListener(
              child: LiveNavigationListener(
                child: child ?? const SizedBox.shrink(),
              ),
            ),

            if (!isOnActiveCall) const ActiveCallOverlay(),
          ],
        );
      },
    );
  }
}
