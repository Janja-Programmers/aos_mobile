import 'package:africaonlinestores/features/auth/domain/auth_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MobileLoginRequest', () {
    test('serializes the exact current mobile login contract', () {
      const MobileLoginRequest request = MobileLoginRequest(
        identifier: 'user@example.invalid',
        password: 'fake-password',
      );

      expect(request.toJson(), <String, dynamic>{
        'identifier': 'user@example.invalid',
        'password': 'fake-password',
        'client_type': 'mobile',
      });
    });

    test('never emits legacy email, usr, or pwd fields', () {
      const MobileLoginRequest request = MobileLoginRequest(
        identifier: '+254700000000',
        password: 'fake-password',
      );
      final Map<String, dynamic> json = request.toJson();

      expect(
        json.keys,
        containsAll(<String>['identifier', 'password', 'client_type']),
      );
      expect(json, isNot(contains('email')));
      expect(json, isNot(contains('usr')));
      expect(json, isNot(contains('pwd')));
    });

    test('uses mobile as the non-configurable client type', () {
      expect(MobileLoginRequest.clientType, 'mobile');
    });
  });
}
