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
        .split('Future<bool> canUseFullScreenIntent()')[0];

    expect(initBody, isNot(contains('requestFullIntentPermission')));
    expect(initBody, isNot(contains('requestNotificationPermission')));
  });

  test('full-screen settings are guarded by an availability check', () {
    final source = File(
      'lib/features/connect/calls/platform/callkit/callkit_service.dart',
    ).readAsStringSync();
    final requestBody = source
        .split('Future<bool> requestFullScreenIntentPermission() async {')[1]
        .split('Future<void> showIncomingCall')[0];

    expect(
      requestBody,
      contains('if (await canUseFullScreenIntent()) return true;'),
    );
    expect(requestBody, contains('requestFullIntentPermission()'));
  });

  test('notification permission is requested only while undecided', () {
    final source = File(
      'lib/features/notifications/application/services/'
      'push_notification_service.dart',
    ).readAsStringSync();
    final requestBody = source
        .split('Future<bool> _requestPermission() async {')[1]
        .split('Future<void> _configureForegroundPresentation()')[0];

    expect(requestBody, contains('getNotificationSettings()'));
    expect(requestBody, contains('AuthorizationStatus.denied'));
    expect(requestBody, contains('requestPermission()'));
  });

  test('calls UI exposes explicit full-screen settings action', () {
    final source = File(
      'lib/features/connect/calls/presentation/screens/call_list_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Enable full-screen incoming calls'));
    expect(source, contains('_requestFullScreenIntentPermission'));
    expect(source, contains('AppLifecycleState.resumed'));
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
}
