import 'package:africaonlinestores/app/splash/splash_screen.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/authentication_session/helpers/auth_controller_harness.dart';

void main() {
  testWidgets(
    'retryable restoration state is scrollable, RTL-safe, and overflow-free',
    (WidgetTester tester) async {
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => failedAuthResponse(
          const Failure('Network unavailable.', type: FailureType.network),
        ),
      );
      addTearDown(harness.container.dispose);

      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: harness.container,
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates:
                const <LocalizationsDelegate<dynamic>>[
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  viewInsets: const EdgeInsets.only(bottom: 220),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(FilledButton))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'retryable restoration supports dark landscape at 200 percent text',
    (WidgetTester tester) async {
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => failedAuthResponse(
          const Failure('Server unavailable.', type: FailureType.server),
        ),
      );
      addTearDown(harness.container.dispose);

      tester.view.physicalSize = const Size(640, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: harness.container,
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            localizationsDelegates:
                const <LocalizationsDelegate<dynamic>>[
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(FilledButton))).brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
