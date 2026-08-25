import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CallKit dependency is pinned to the known-good resolved version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('flutter_callkit_incoming: 3.0.0'));
    expect(pubspec, isNot(contains('flutter_callkit_incoming: ^3.0.0')));
  });

  test('incoming notification navigation remains owned by CallKit', () {
    final String handlerSource = File(
      'lib/features/notifications/application/services/'
      'notification_navigation_handler.dart',
    ).readAsStringSync();
    final String parserSource = File(
      'lib/features/notifications/application/services/'
      'notification_destination_parser.dart',
    ).readAsStringSync();

    expect(handlerSource, isNot(contains('CallListScreen')));
    expect(handlerSource, isNot(contains('_openCalls')));

    final List<String> incomingSplit = parserSource.split(
      'case NotificationType.incomingCall:',
    );
    expect(incomingSplit, hasLength(2));
    final String incomingCase = incomingSplit.last
        .split('case NotificationType.follow:')
        .first;
    expect(incomingCase, contains('return null;'));
  });

  test('outgoing flow invokes native CallKit startCall', () {
    final source = File(
      'lib/features/connect/calls/platform/callkit/callkit_service.dart',
    ).readAsStringSync();
    expect(source, contains('FlutterCallkitIncoming.startCall(params)'));
  });

  test('CallKit initialization never opens permission settings', () {
    final source = File(
      'lib/features/connect/calls/platform/callkit/callkit_service.dart',
    ).readAsStringSync();
    final initBody = source
        .split('Future<void> init() async {')[1]
        .split('Future<void> showIncomingCall')[0];

    expect(initBody, isNot(contains('requestNotificationPermission')));
  });

  test('full-screen-intent runtime APIs are absent from AOS call code', () {
    final serviceSource = File(
      'lib/features/connect/calls/platform/callkit/callkit_service.dart',
    ).readAsStringSync();
    final callsUiSource = File(
      'lib/features/connect/calls/presentation/screens/call_list_screen.dart',
    ).readAsStringSync();

    for (final source in <String>[serviceSource, callsUiSource]) {
      expect(source, isNot(contains('canUseFullScreenIntent')));
      expect(source, isNot(contains('requestFullIntentPermission')));
      expect(source, isNot(contains('requestFullScreenIntentPermission')));
    }
  });

  test('Android manifest removes dependency-provided full-screen intent', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('xmlns:tools="http://schemas.android.com/tools"'));
    expect(manifest, contains('android.permission.USE_FULL_SCREEN_INTENT'));
    expect(manifest, contains('tools:node="remove"'));
  });

  test('Android 13 notification permission ambiguity is tracked', () {
    final source = File(
      'lib/features/notifications/application/services/'
      'push_notification_service.dart',
    ).readAsStringSync();
    final requestBody = source
        .split('Future<bool> _requestPermission() async {')[1]
        .split('Future<void> _configureForegroundPresentation()')[0];

    expect(requestBody, contains('getNotificationSettings()'));
    expect(requestBody, contains('AuthorizationStatus.denied'));
    expect(requestBody, contains('_notificationPermissionRequestedKey'));
    expect(requestBody, contains('SharedPreferences.getInstance()'));
    expect(requestBody, contains('requestPermission('));
  });

  test('calls UI does not expose full-screen-intent settings', () {
    final source = File(
      'lib/features/connect/calls/presentation/screens/call_list_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('Enable full-screen incoming calls')));
    expect(source, isNot(contains('Open settings')));
    expect(source, isNot(contains('Full-screen incoming calls are disabled')));
  });

  test('3.0.0 background handler uses the legacy CallEvent API', () {
    final source = File(
      'lib/features/connect/calls/platform/callkit/'
      'callkit_background_action_handler.dart',
    ).readAsStringSync();

    expect(source, contains('switch (event.event)'));
    expect(source, contains('Event.actionCallAccept'));
    expect(source, contains('asJsonMap(event.body)'));
    expect(source, isNot(contains('CallEventActionCallAccept')));
    expect(source, isNot(contains('CallEventActionCallDecline')));
    expect(source, isNot(contains('CallEventActionCallEnded')));
    expect(source, isNot(contains('CallEventActionCallTimeout')));
  });

  test('push token registration is independent of display permission', () {
    final source = File(
      'lib/features/notifications/application/services/'
      'push_notification_service.dart',
    ).readAsStringSync();
    final initBody = source
        .split('Future<void> init() async {')[1]
        .split('Future<bool> _requestPermission()')[0];

    expect(initBody, contains('await _setupToken();'));
    expect(
      initBody,
      isNot(contains('if (permissionGranted) {\n        await _setupToken();')),
    );
    expect(source, contains('result.leftOrNull'));
    expect(source, contains('result.rightOrNull != true'));
  });

  test('call and notification initial loads are deferred until post-frame', () {
    final callsSource = File(
      'lib/features/connect/calls/presentation/screens/call_list_screen.dart',
    ).readAsStringSync();
    final notificationsSource = File(
      'lib/features/notifications/presentation/screens/'
      'notification_screen.dart',
    ).readAsStringSync();

    expect(callsSource, contains('addPostFrameCallback'));
    expect(notificationsSource, contains('addPostFrameCallback'));
    expect(notificationsSource, isNot(contains('Future<void>.microtask(()')));
  });

  test('persistent missed-call action starts a real callback flow', () {
    final source = File(
      'lib/features/notifications/presentation/screens/'
      'notification_screen.dart',
    ).readAsStringSync();

    expect(source, contains('missedCallCallbackServiceProvider'));
    expect(source, contains('notification.payload.callId'));
    expect(source, contains('callerUserId: callerUserId'));
  });

  test('Android call plugin configuration matches locked plugin docs', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final proguard = File('android/app/proguard-rules.pro').readAsStringSync();

    expect(manifest, contains('android:launchMode="singleInstance"'));
    expect(manifest, contains('android.permission.ACCESS_NETWORK_STATE'));
    expect(manifest, contains('android.permission.CHANGE_NETWORK_STATE'));
    expect(proguard, contains('com.hiennv.flutter_callkit_incoming.**'));
  });
}
