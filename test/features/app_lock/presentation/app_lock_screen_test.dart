import 'package:africaonlinestores/features/app_lock/application/app_lock_controller.dart';
import 'package:africaonlinestores/features/app_lock/data/app_lock_preference_repository.dart';
import 'package:africaonlinestores/features/app_lock/data/app_lock_secret_hasher.dart';
import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:africaonlinestores/features/app_lock/platform/native_app_lock_service.dart';
import 'package:africaonlinestores/features/app_lock/presentation/app_lock_screen.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lock screen is overflow safe at 200 percent text and RTL', (
    WidgetTester tester,
  ) async {
    final AppLockController controller = _controller();
    await controller.handleAuthState(_authenticated());

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MaterialApp(
            locale: Locale('ar'),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: <Locale>[
              Locale('ar'),
              Locale('en'),
              Locale('fr'),
              Locale('sw'),
              Locale('zh'),
            ],
            home: AppLockScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('AOS'), findsWidgets);
  });

  testWidgets('pattern entry supports more than four points before unlock', (
    WidgetTester tester,
  ) async {
    final AppLockController controller = _controller(
      method: AppLockMethod.pattern,
    );
    await controller.handleAuthState(_authenticated());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: <Locale>[
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
            Locale('sw'),
            Locale('zh'),
          ],
          home: AppLockScreen(),
        ),
      ),
    );

    for (final int point in <int>[1, 2, 3, 5, 9]) {
      await tester.tap(find.bySemanticsLabel(RegExp('Pattern point $point')));
      await tester.pump();
    }

    expect(controller.state.phase, AppLockPhase.locked);
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    expect(controller.state.phase, AppLockPhase.unlocked);
  });

  testWidgets('lock screen does not display account identity', (
    WidgetTester tester,
  ) async {
    final AppLockController controller = _controller();
    await controller.handleAuthState(_authenticated());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: <Locale>[
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
            Locale('sw'),
            Locale('zh'),
          ],
          home: AppLockScreen(),
        ),
      ),
    );

    expect(find.text('private@example.com'), findsNothing);
    expect(find.text('Private Name'), findsNothing);
    expect(find.textContaining('Reset app lock'), findsOneWidget);
  });
}

AppLockController _controller({AppLockMethod method = AppLockMethod.pin}) {
  return AppLockController(
    repository: _Repository(method),
    secretHasher: _Hasher(),
    nativeService: _NativeService(),
    clock: _Clock(),
  );
}

AuthAuthenticated _authenticated() => AuthAuthenticated(
  user: AuthUser(email: 'private@example.com', fullName: 'Private Name'),
  sid: 'sid',
);

class _Repository implements AppLockPreferenceRepository {
  const _Repository(this.method);

  final AppLockMethod method;

  @override
  Future<void> clear(String accountId) async {}

  @override
  Future<AppLockPreference> read(String accountId) async {
    return AppLockPreference(
      method: method,
      timeout: AppLockTimeout.immediately,
      secretHash: 'hash',
      salt: 'salt',
      hashIterations: 1,
    );
  }

  @override
  Future<void> write(String accountId, AppLockPreference preference) async {}
}

class _Hasher implements AppLockSecretHasher {
  @override
  Future<AppLockSecretDigest> create(String secret) async {
    return const AppLockSecretDigest(hash: 'hash', salt: 'salt', iterations: 1);
  }

  @override
  Future<bool> verify({
    required String secret,
    required String expectedHash,
    required String salt,
    required int iterations,
  }) async => true;
}

class _NativeService implements NativeAppLockService {
  @override
  Future<AppLockResult> authenticateBiometric({required String reason}) async {
    return const AppLockResult.success();
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<AppLockResult> checkBiometricAvailability() async {
    return const AppLockResult.success();
  }
}

class _Clock implements MonotonicClock {
  @override
  Duration get elapsed => Duration.zero;
}
