import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

extension TestAppPump on WidgetTester {
  /// Pumps [child] with the production theme, localization and Riverpod scope.
  Future<void> pumpTestApp(
    Widget child, {
    List<Override> overrides = const <Override>[],
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          supportedLocales: kSupportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          navigatorObservers: navigatorObservers,
          home: Scaffold(body: child),
        ),
      ),
    );
    await pump();
  }
}
