import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/theme/theme_prefs.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';

import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedTheme = await ThemePrefs.readThemeMode();
  final initialTheme = savedTheme ?? ThemeMode.light;

  // ✅ Initialize SharedPreferences
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
  @override
  void initState() {
    super.initState();

    appLogger.i('[App] initState → Bootstrapping app');

    // Bootstrap
    Future.microtask(() {
      ref.read(appBootstrapControllerProvider.notifier).initialize();
    });

    // 🔥 Realtime wiring
    Future.microtask(() {
      appLogger.i('[App] Setting up realtime listener');
      _setupRealtimeListener();
    });

    Future.microtask(() async {
      final apiClient = ref.read(apiClientProvider);

      await apiClient.setSid(
        "45c019dbe25b067f397b389fc984955a3354e7681be4363f89a40ec2",
      );
    });
  }

  void _setupRealtimeListener() {
    final realtime = ref.read(realtimeServiceProvider);

    // prevent duplicate connect
    if (!realtime.isConnected) {
      realtime.connect(
        baseUrl: "https://aos-staging.duckdns.org",
        siteName: "aos-staging.duckdns.org",
        sid: "45c019dbe25b067f397b389fc984955a3354e7681be4363f89a40ec2",
        email: "georgesbobby21@gmail.com",
      );

      appLogger.i('[Realtime] Connection triggered');
    } else {
      appLogger.w('[Realtime] Already connected → skipping');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(appBootstrapProvider);
    if (!bootstrap.isReady) {
      return const SizedBox.shrink();
    }
    return const AOSApp();
  }
}

class AOSApp extends ConsumerWidget {
  const AOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // ✅ This is what makes globalization work:
    // when preferences change, AOSApp rebuilds,
    // MaterialApp receives a new locale, and the whole app updates.
    final prefs = ref.watch(userPreferenceControllerProvider);

    return MaterialApp.router(
      title: 'Africa Online Stores',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // ✅ Globalize using saved preference language
      locale: resolveLocale(prefs),

      // ✅ Required for Flutter localization to load translations
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: kSupportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
