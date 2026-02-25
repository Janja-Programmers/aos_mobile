import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/core/providers.dart'
    show userPreferenceControllerProvider;
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/theme/theme_prefs.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedTheme = await ThemePrefs.readThemeMode();
  final initialTheme = savedTheme ?? ThemeMode.system;

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeController(initialTheme)),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    return bootstrap.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (_) => const AOSApp(),
    );
  }
}

class AOSApp extends ConsumerWidget {
  const AOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    final prefsAsync = ref.watch(userPreferenceControllerProvider);
    final prefs = prefsAsync.maybeWhen(data: (v) => v, orElse: () => null);

    return MaterialApp.router(
      title: 'Africa Online Stores',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: resolveLocale(prefs),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('sw'),
        Locale('fr'),
        Locale('ar'),
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
