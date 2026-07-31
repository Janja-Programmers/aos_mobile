import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthUser preserves public account identity and display name', () {
    final user = AuthUser.fromMap(const <String, dynamic>{
      'id': 'ACC-ABCDEFGHIJKLMNOPQRST',
      'email': 'bobby@example.invalid',
      'display_name': 'Bobby',
      'full_name': 'Stale User Name',
    });

    expect(user.accountId, 'ACC-ABCDEFGHIJKLMNOPQRST');
    expect(user.email, 'bobby@example.invalid');
    expect(user.fullName, 'Bobby');
  });

  test('legacy email id remains an auth email, not a public account id', () {
    final user = AuthUser.fromMap(const <String, dynamic>{
      'id': 'legacy@example.invalid',
      'full_name': 'Legacy User',
    });

    expect(user.accountId, isEmpty);
    expect(user.email, 'legacy@example.invalid');
  });
}
