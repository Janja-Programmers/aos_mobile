import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/localization/locale_prefs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AOSApp()));
}

class AOSApp extends ConsumerWidget {
  const AOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Default to system theme while loading prefs.
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = themeModeAsync.maybeWhen(
      data: (m) => m,
      orElse: () => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Africa Online Stores',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: _resolveLocale(ref.watch(localeControllerProvider)),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // NOTE: Keep this list small for now; app text translations are handled
      // via your own intl ARB setup. Material widgets will fall back to en.
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

Locale? _resolveLocale(AsyncValue<LocalePrefs> prefsAsync) {
  final prefs = prefsAsync.maybeWhen(data: (v) => v, orElse: () => null);

  if (prefs == null) return null;

  final lang = prefs.languageCode;
  final country = prefs.countryCode;

  if (lang.isEmpty) return null;
  return country.isEmpty ? Locale(lang) : Locale(lang, country);
}
