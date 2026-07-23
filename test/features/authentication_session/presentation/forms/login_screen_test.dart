import 'dart:async';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api_provider.dart';
import 'package:africaonlinestores/features/auth/screens/login_screen.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_session_storage.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_preferences.dart';
import '../../../../test_config/test_environment.dart';
import '../../fakes/scripted_auth_api.dart';
import '../../helpers/auth_controller_harness.dart';

void main() {
  group('LoginScreen', () {
    testWidgets(
      'renders identifier, password, remember-me, and submit controls',
      (WidgetTester tester) async {
        final _LoginWidgetHarness harness = await _buildLoginWidgetHarness();

        await tester.pumpTestApp(
          const LoginScreen(),
          overrides: harness.overrides,
        );

        expect(find.byKey(const Key('auth.login.identifier')), findsOneWidget);
        expect(find.byKey(const Key('auth.login.password')), findsOneWidget);
        expect(find.byKey(const Key('auth.login.rememberMe')), findsOneWidget);
        expect(find.byKey(const Key('auth.login.submit')), findsOneWidget);
      },
    );

    testWidgets(
      'prefills only the remembered identifier when remember-me is enabled',
      (WidgetTester tester) async {
        final _LoginWidgetHarness harness = await _buildLoginWidgetHarness(
          storage: FakeSessionStorage(
            rememberedEmail: 'remembered@example.invalid',
          ),
        );

        await tester.pumpTestApp(
          const LoginScreen(),
          overrides: harness.overrides,
        );
        await tester.pump();

        final AppFormField identifier = tester.widget<AppFormField>(
          find.byKey(const Key('auth.login.identifier')),
        );
        expect(identifier.controller?.text, 'remembered@example.invalid');

        final AppPasswordFormField password = tester
            .widget<AppPasswordFormField>(
              find.byKey(const Key('auth.login.password')),
            );
        expect(password.controller?.text, isEmpty);
      },
    );

    testWidgets('route prefill takes precedence over remembered identifier', (
      WidgetTester tester,
    ) async {
      final _LoginWidgetHarness harness = await _buildLoginWidgetHarness(
        storage: FakeSessionStorage(
          rememberedEmail: 'remembered@example.invalid',
        ),
      );

      await tester.pumpTestApp(
        const LoginScreen(prefillEmail: 'route@example.invalid'),
        overrides: harness.overrides,
      );
      await tester.pump();

      final AppFormField identifier = tester.widget<AppFormField>(
        find.byKey(const Key('auth.login.identifier')),
      );
      expect(identifier.controller?.text, 'route@example.invalid');
    });

    testWidgets('empty fields show validation and do not call the API', (
      WidgetTester tester,
    ) async {
      final _LoginWidgetHarness harness = await _buildLoginWidgetHarness();

      await tester.pumpTestApp(
        const LoginScreen(),
        overrides: harness.overrides,
      );
      await tester.tap(find.byKey(const Key('auth.login.submit')));
      await tester.pump();

      expect(find.text('Email or phone is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(harness.api.loginCalls, 0);
    });

    testWidgets('password visibility toggle changes obscureText', (
      WidgetTester tester,
    ) async {
      final _LoginWidgetHarness harness = await _buildLoginWidgetHarness();

      await tester.pumpTestApp(
        const LoginScreen(),
        overrides: harness.overrides,
      );

      EditableText passwordField = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('auth.login.password')),
          matching: find.byType(EditableText),
        ),
      );
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      passwordField = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('auth.login.password')),
          matching: find.byType(EditableText),
        ),
      );
      expect(passwordField.obscureText, isFalse);
    });

    testWidgets('INVALID_CREDENTIALS displays the generic message', (
      WidgetTester tester,
    ) async {
      final _LoginWidgetHarness harness = await _buildLoginWidgetHarness(
        loginHandler: (String identifier, String password) async {
          return failedAuthResponse(
            Failure.fromServerPayload(<String, dynamic>{
              'error': 'INVALID_CREDENTIALS',
              'message': 'Unknown account.',
            }),
          );
        },
      );

      await tester.pumpTestApp(
        const LoginScreen(),
        overrides: harness.overrides,
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('auth.login.identifier')),
          matching: find.byType(TextFormField),
        ),
        'user@example.invalid',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('auth.login.password')),
          matching: find.byType(TextFormField),
        ),
        'fake-password',
      );
      await tester.tap(find.byKey(const Key('auth.login.submit')));
      await tester.pump();
      await tester.pump();

      expect(find.text('Invalid email, phone, or password.'), findsOneWidget);
      expect(find.text('Unknown account.'), findsNothing);
      expect(harness.api.loginCalls, 1);
    });

    testWidgets('loading state blocks a rapid duplicate tap', (
      WidgetTester tester,
    ) async {
      final Completer<AuthApiResponse> pending = Completer<AuthApiResponse>();
      final _LoginWidgetHarness harness = await _buildLoginWidgetHarness(
        loginHandler: (String identifier, String password) => pending.future,
      );

      await tester.pumpTestApp(
        const LoginScreen(),
        overrides: harness.overrides,
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('auth.login.identifier')),
          matching: find.byType(TextFormField),
        ),
        'user@example.invalid',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('auth.login.password')),
          matching: find.byType(TextFormField),
        ),
        'fake-password',
      );

      await tester.tap(find.byKey(const Key('auth.login.submit')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('auth.login.submit')));
      await tester.pump();

      expect(harness.api.loginCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      pending.complete(
        failedAuthResponse(
          const Failure('Network unavailable.', type: FailureType.network),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(harness.api.loginCalls, 1);
    });
  });
}

class _LoginWidgetHarness {
  const _LoginWidgetHarness({
    required this.overrides,
    required _AuthApiHolder holder,
  }) : _holder = holder;

  final List<Override> overrides;
  final _AuthApiHolder _holder;

  ScriptedAuthApi get api => _holder.value!;
}

class _AuthApiHolder {
  ScriptedAuthApi? value;
}

Future<_LoginWidgetHarness> _buildLoginWidgetHarness({
  FakeSessionStorage? storage,
  LoginHandler? loginHandler,
}) async {
  final preferences = await setUpTestPreferences();
  final OnboardingStorage onboardingStorage = OnboardingStorage(preferences);
  final FakeSessionStorage sessionStorage = storage ?? FakeSessionStorage();
  final _AuthApiHolder holder = _AuthApiHolder();

  final List<Override> overrides = <Override>[
    onboardingStorageProvider.overrideWithValue(onboardingStorage),
    sessionStorageProvider.overrideWithValue(sessionStorage),
    apiClientProvider.overrideWith((Ref ref) {
      final ApiClient client = ApiClient(
        baseUrl: TestEnvironment.apiBaseUrl,
        ref: ref,
      );
      ref.onDispose(client.dispose);
      return client;
    }),
    authApiProvider.overrideWith((Ref ref) {
      final ScriptedAuthApi api = ScriptedAuthApi(
        ref.watch(apiClientProvider),
        loginHandler: loginHandler,
      );
      holder.value = api;
      return api;
    }),
  ];

  return _LoginWidgetHarness(overrides: overrides, holder: holder);
}
