import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/auth/domain/auth_contract.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_fixture.dart';

void main() {
  group('AuthSessionPayload', () {
    test('reads SID only from data.session.sid', () async {
      final Map<String, dynamic> message = await loadAuthMessageFixture(
        'login_success.json',
      );
      final Map<String, dynamic> data = asJsonMap(message['data']);
      data['sid'] = 'legacy-top-level-sid';

      final AuthSessionPayload payload = AuthSessionPayload.fromData(data);

      expect(payload.sid, 'test-session-id');
      expect(payload.sid, isNot('legacy-top-level-sid'));
    });

    test('maps authenticated and nullable expires_at safely', () async {
      final Map<String, dynamic> message = await loadAuthMessageFixture(
        'login_success.json',
      );
      final AuthSessionPayload payload = AuthSessionPayload.fromData(
        asJsonMap(message['data']),
      );

      expect(payload.authenticated, isTrue);
      expect(payload.expiresAt, isNull);
      expect(payload.isExplicitlyUnauthenticated, isFalse);
    });

    test(
      'maps non-null expires_at without interpreting backend time policy',
      () async {
        final Map<String, dynamic> message = await loadAuthMessageFixture(
          'login_success_without_seller.json',
        );
        final AuthSessionPayload payload = AuthSessionPayload.fromData(
          asJsonMap(message['data']),
        );

        expect(payload.expiresAt, '2026-08-01T12:00:00Z');
        expect(payload.seller, isEmpty);
      },
    );

    test(
      'allows /me payloads that intentionally omit session and SID',
      () async {
        final Map<String, dynamic> message = await loadAuthMessageFixture(
          'me_success.json',
        );
        final AuthSessionPayload payload = AuthSessionPayload.fromData(
          asJsonMap(message['data']),
        );

        expect(payload.hasUser, isTrue);
        expect(payload.sid, isEmpty);
        expect(payload.authenticated, isNull);
      },
    );

    test(
      'marks explicit unauthenticated session data as unsafe for login',
      () async {
        final Map<String, dynamic> message = await loadAuthMessageFixture(
          'login_unauthenticated_session.json',
        );
        final AuthSessionPayload payload = AuthSessionPayload.fromData(
          asJsonMap(message['data']),
        );

        expect(payload.sid, 'stale-test-session-id');
        expect(payload.isExplicitlyUnauthenticated, isTrue);
      },
    );

    test('defensively handles malformed collection values', () {
      final AuthSessionPayload payload = AuthSessionPayload.fromData(
        <String, dynamic>{
          'session': 'invalid',
          'user': <String, dynamic>{'email': 'user@example.invalid'},
          'roles': 'AOS User',
          'preferences': <String>['invalid'],
        },
      );

      expect(payload.sid, isEmpty);
      expect(payload.roles, isEmpty);
      expect(payload.preferences, isEmpty);
      expect(payload.hasUser, isTrue);
    });
  });
}
