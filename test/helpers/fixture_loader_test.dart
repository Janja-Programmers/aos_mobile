import 'package:flutter_test/flutter_test.dart';

import 'fixture_loader.dart';

void main() {
  test('loads a sanitized shared auth fixture as an object', () async {
    final Map<String, dynamic> fixture = await loadJsonObjectFixture(
      'shared/auth/authenticated_session.json',
    );

    final Map<String, dynamic> message = Map<String, dynamic>.from(
      fixture['message'] as Map<Object?, Object?>,
    );

    expect(message['ok'], isTrue);
    expect(message['data'], isA<Map<Object?, Object?>>());
  });
}
