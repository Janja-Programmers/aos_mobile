import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter buildTestRouter({
  required Widget home,
  List<RouteBase> routes = const <RouteBase>[],
  String initialLocation = '/',
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
  GoRouterRedirect? redirect,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    observers: observers,
    redirect: redirect,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return home;
        },
      ),
      ...routes,
    ],
  );
}

extension TestRouterPump on WidgetTester {
  Future<void> pumpTestRouter(
    GoRouter router, {
    List<Override> overrides = const <Override>[],
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
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
          routerConfig: router,
        ),
      ),
    );
    await pump();
  }
}
