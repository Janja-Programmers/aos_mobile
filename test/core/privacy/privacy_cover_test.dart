import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/core/privacy/privacy_cover.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AuthAuthenticated authenticated = AuthAuthenticated(
    user: AuthUser(
      email: 'private@example.invalid',
      fullName: 'Private Person',
    ),
    sid: 'private-session',
  );

  group('PrivacyCoverCoordinator', () {
    test('covers authenticated content when the app is hidden', () {
      const PrivacyCoverCoordinator coordinator = PrivacyCoverCoordinator();
      const AppLifecycleSnapshot lifecycle = AppLifecycleSnapshot(
        phase: AppVisibilityPhase.hidden,
        sequence: 1,
        isInitial: false,
      );

      final PrivacyCoverState state = coordinator.resolve(
        authState: authenticated,
        lifecycle: lifecycle,
      );

      expect(state.isVisible, isTrue);
    });

    test('does not cover an inactive system-overlay transition', () {
      const PrivacyCoverCoordinator coordinator = PrivacyCoverCoordinator();
      const AppLifecycleSnapshot lifecycle = AppLifecycleSnapshot(
        phase: AppVisibilityPhase.inactive,
        sequence: 1,
        isInitial: false,
      );

      final PrivacyCoverState state = coordinator.resolve(
        authState: authenticated,
        lifecycle: lifecycle,
      );

      expect(state.isVisible, isFalse);
    });

    test('does not expose a privacy cover for guest state', () {
      const PrivacyCoverCoordinator coordinator = PrivacyCoverCoordinator();
      const AppLifecycleSnapshot lifecycle = AppLifecycleSnapshot(
        phase: AppVisibilityPhase.background,
        sequence: 1,
        isInitial: false,
      );

      final PrivacyCoverState state = coordinator.resolve(
        authState: const AuthGuest(),
        lifecycle: lifecycle,
      );

      expect(state.isVisible, isFalse);
    });
  });

  testWidgets(
    'opaque cover is responsive, semantic, and contains no account data',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: Scaffold(
                body: Stack(
                  children: <Widget>[
                    Semantics(
                      label: 'private account information',
                      child: const Text(
                        'Private Person private@example.invalid',
                      ),
                    ),
                    const PrivacyCover(),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      final Finder cover = find.byType(PrivacyCover);
      final Finder coloredBox = find.descendant(
        of: cover,
        matching: find.byType(ColoredBox),
      );
      expect(coloredBox, findsOneWidget);
      expect(tester.widget<ColoredBox>(coloredBox).color.a, 1.0);
      expect(
        find.descendant(
          of: cover,
          matching: find.textContaining('Private Person'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: cover,
          matching: find.textContaining('private@example.invalid'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      final BuildContext coverContext = tester.element(cover);
      final AppLocalizations localizations = AppLocalizations.of(coverContext);
      final SemanticsHandle semantics = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(localizations.privacy_cover_accessibility_label),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('private account information'),
        findsNothing,
      );
      semantics.dispose();
    },
  );
}
