import 'package:africaonlinestores/core/api/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure authentication mapping', () {
    test('uses error as the stable machine-readable failure key', () {
      final Failure failure = Failure.fromServerPayload(<String, dynamic>{
        'error': 'INVALID_CREDENTIALS',
        'message': 'The account does not exist.',
      });

      expect(failure.error, 'INVALID_CREDENTIALS');
      expect(failure.type, FailureType.unauthorized);
      expect(failure.message, 'Invalid email, phone, or password.');
    });

    test(
      'does not treat the legacy code key as the current error contract',
      () {
        final Failure failure = Failure.fromServerPayload(<String, dynamic>{
          'code': 'INVALID_CREDENTIALS',
          'message': 'Legacy payload.',
        });

        expect(failure.error, isNull);
        expect(failure.message, 'Legacy payload.');
      },
    );

    test('wrong password and unknown account produce identical UI text', () {
      final Failure wrongPassword = Failure.fromServerPayload(<String, dynamic>{
        'error': 'INVALID_CREDENTIALS',
        'message': 'Wrong password.',
      });
      final Failure unknownAccount = Failure.fromServerPayload(
        <String, dynamic>{
          'error': 'INVALID_CREDENTIALS',
          'message': 'Unknown account.',
        },
      );

      expect(wrongPassword.message, unknownAccount.message);
      expect(wrongPassword.message, 'Invalid email, phone, or password.');
    });

    test('maps account lifecycle errors to explicit forbidden failures', () {
      for (final String error in <String>[
        'ACCOUNT_DISABLED',
        'ACCOUNT_DELETED',
        'ACCOUNT_DELETED_RESTORABLE',
        'ACCOUNT_SUSPENDED',
      ]) {
        final Failure failure = Failure.fromServerPayload(<String, dynamic>{
          'error': error,
        });
        expect(failure.type, FailureType.forbidden, reason: error);
      }
    });

    test('unknown errors retain a bounded fallback message', () {
      final Failure failure = Failure.fromServerPayload(<String, dynamic>{
        'error': 'UNKNOWN_AUTH_FAILURE',
      }, fallbackMessage: 'Login failed.');

      expect(failure.error, 'UNKNOWN_AUTH_FAILURE');
      expect(failure.message, 'Login failed.');
      expect(failure.type, FailureType.unknown);
    });
  });
}
