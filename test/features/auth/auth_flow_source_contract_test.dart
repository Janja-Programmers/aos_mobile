import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('password login has a deterministic home-navigation fallback', () {
    final source = File(
      'lib/features/auth/screens/login_screen.dart',
    ).readAsStringSync();

    expect(source, contains('(_) => context.go(AppRoutes.home)'));
  });

  test(
    'restore account reuses the shared OTP screen instead of inline OTP UI',
    () {
      final restoreSource = File(
        'lib/features/account/presentation/screens/restore_account_screen.dart',
      ).readAsStringSync();
      final otpSource = File(
        'lib/features/auth/screens/verify_otp_screen.dart',
      ).readAsStringSync();

      expect(restoreSource, contains('OtpPurpose.accountRestore'));
      expect(restoreSource, isNot(contains('_otpController')));
      expect(restoreSource, isNot(contains("labelText: 'Restore code'")));
      expect(restoreSource, isNot(contains('.restoreAccount(')));

      expect(otpSource, contains('OtpPurpose.accountRestore'));
      expect(otpSource, contains('.restoreAccount('));
      expect(otpSource, contains('.requestRestore('));
    },
  );

  test(
    'restorable deleted login routes to restore by stable backend error id',
    () {
      final source = File(
        'lib/features/auth/screens/login_screen.dart',
      ).readAsStringSync();

      expect(source, contains("error == 'ACCOUNT_DELETED_RESTORABLE'"));
      expect(source, contains('AppRoutes.nRestoreAccount'));
      expect(source, contains("queryParameters: {'email': email}"));
    },
  );

  test('restore route accepts a login-prefilled email', () {
    final routeSource = File(
      'lib/features/account/shared/routing/account_routes.dart',
    ).readAsStringSync();
    final screenSource = File(
      'lib/features/account/presentation/screens/restore_account_screen.dart',
    ).readAsStringSync();

    expect(routeSource, contains("state.uri.queryParameters['email']"));
    expect(screenSource, contains('this.prefillEmail'));
    expect(screenSource, contains('_emailController.text = email'));
  });

  test(
    'google sign-in uses one-shot authenticate result and preserves errors',
    () {
      final source = File(
        'lib/features/auth/data/google_auth_service.dart',
      ).readAsStringSync();

      expect(source, contains('await _signIn.authenticate()'));
      expect(source, contains('GoogleSignInException'));
      expect(source, contains('GOOGLE_CLIENT_CONFIG_ERROR'));
      expect(source, isNot(contains('authenticationEvents.listen')));
      expect(source, isNot(contains('Completer<String?>')));
    },
  );

  test(
    'google provider failures are preserved by the auth controller patch',
    () {
      final patch = File('auth_controller.patch').readAsStringSync();

      expect(patch, contains('on GoogleAuthServiceException catch'));
      expect(patch, contains('error.userMessage'));
      expect(patch, isNot(contains("Failure('Google sign-in cancelled.')")));
    },
  );
}
