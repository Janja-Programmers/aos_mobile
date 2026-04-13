import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:africaonlinestores/l10n/gen/app_localizations.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/theme/theme_prefs.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/calls/application/listeners/call_navigation_listener.dart';
import 'package:africaonlinestores/features/live/application/listeners/live_navigation_listeners.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      final realtime = ref.read(realtimeServiceProvider);

      /// -----------------------------
      /// AUTHENTICATED → CONNECT
      /// -----------------------------
      if (next is AuthAuthenticated) {
        if (!realtime.isConnected) {
          realtime.connect(
            baseUrl: AppConfig.baseUrl.trim(),
            siteName: AppConfig.siteName,
            sid: next.sid,
            email: next.user.email,
          );

          appLogger.i('[Realtime] Connected: ${next.user.email}');
        }
        return;
      }

      /// -----------------------------
      /// GUEST → DISCONNECT
      /// -----------------------------
      if (next is AuthGuest) {
        if (realtime.isConnected) {
          realtime.disconnect();
          appLogger.i('[Realtime] Disconnected (guest)');
        }
      }
    });

    return const AOSApp();
  }
}

class AOSApp extends ConsumerWidget {
  const AOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);

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
        return CallNavigationListener(
          child: LiveNavigationListener(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
