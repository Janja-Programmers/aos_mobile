import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'native notification registration logs never include token values',
    () async {
      final String appDelegate = await File(
        'ios/Runner/AppDelegate.swift',
      ).readAsString();

      expect(appDelegate, isNot(contains(r'\(fcmToken)')));
      expect(appDelegate, isNot(contains('localizedDescription')));
    },
  );

  test('debug Android builds do not require release signing secrets', () async {
    final String buildScript = await File(
      'android/app/build.gradle.kts',
    ).readAsString();

    expect(buildScript, contains('hasReleaseSigningProperties'));
    expect(buildScript, contains('isReleaseBuildRequested'));
    expect(buildScript, isNot(contains('as String')));
  });

  test(
    'background push diagnostics omit provider message identifiers',
    () async {
      final String mainSource = await File('lib/main.dart').readAsString();

      expect(mainSource, isNot(contains("'message_id': message.messageId")));
    },
  );
}
