import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('call dependencies are pinned to audited exact versions', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('flutter_callkit_incoming: 3.1.5'));
    expect(pubspec, isNot(contains('flutter_callkit_incoming: ^3.1.5')));
    expect(pubspec, contains('livekit_client: 2.10.0'));
    expect(pubspec, isNot(contains('livekit_client: ^2.10.0')));
  });

  test(
    'background CallKit actions use 3.1.5 sealed events and registration',
    () {
      final handler = File(
        'lib/features/connect/calls/platform/callkit/'
        'callkit_background_action_handler.dart',
      ).readAsStringSync();
      final mainSource = File('lib/main.dart').readAsStringSync();

      expect(handler, contains('CallEventActionCallAccept'));
      expect(handler, contains('CallEventActionCallDecline'));
      expect(handler, contains('CallEventActionCallEnded'));
      expect(handler, contains('CallEventActionCallTimeout'));
      expect(handler, isNot(contains('switch (event.event)')));
      expect(
        mainSource,
        contains('FlutterCallkitIncoming.onBackgroundMessage('),
      );
      expect(mainSource, contains('callKitBackgroundMessageHandler'));
    },
  );

  test(
    'native action recovery is retry-safe and precedes ringing recovery',
    () {
      final replayer = File(
        'lib/features/connect/calls/platform/callkit/'
        'pending_callkit_action_replayer.dart',
      ).readAsStringSync();
      final recovery = File(
        'lib/features/connect/calls/application/services/'
        'callkit_recovery_service.dart',
      ).readAsStringSync();

      expect(
        replayer,
        contains('PendingCallKitActionReplayResult.retryPending'),
      );
      expect(replayer, contains('if (!resolved)'));
      expect(replayer, contains('retaining for retry'));
      expect(replayer, contains('pendingActionMaxAge'));
      expect(recovery, contains('actionResult =='));
      expect(recovery, contains('retryPending'));
      expect(recovery, contains('deferring incoming payload restoration'));
    },
  );

  test('incoming FCM presentation mirrors backend 30 second TTL', () {
    final freshness = File(
      'lib/features/connect/calls/platform/callkit/'
      'incoming_call_push_freshness.dart',
    ).readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final pushSource = File(
      'lib/features/notifications/application/services/'
      'push_notification_service.dart',
    ).readAsStringSync();

    expect(freshness, contains('Duration(seconds: 30)'));
    expect(freshness, contains('age < incomingCallPushTtl'));
    expect(mainSource, contains('isIncomingCallPushFresh('));
    expect(pushSource, contains('isIncomingCallPushFresh('));
  });

  test(
    'foreground Android uses Flutter ringing UI without full-screen intent',
    () {
      final policy = File(
        'lib/features/connect/calls/application/services/'
        'call_presentation_policy.dart',
      ).readAsStringSync();
      final navigation = File(
        'lib/features/connect/calls/application/listeners/'
        'call_navigation_listener.dart',
      ).readAsStringSync();
      final session = File(
        'lib/features/connect/calls/presentation/screens/'
        'call_session_screen.dart',
      ).readAsStringSync();

      expect(policy, contains('isAndroid && isAppVisible'));
      expect(policy, contains('IncomingCallSurface.flutter'));
      expect(navigation, contains('UiCallPhase.incomingRinging'));
      expect(navigation, contains('IncomingCallSurface.flutter'));
      expect(session, contains('RingingScreen'));
      expect(session, contains('VideoRingingScreen'));
      expect(navigation, isNot(contains('Duration(milliseconds: 500)')));
    },
  );

  test(
    'Android manifest keeps FSI removed and adds LiveKit Bluetooth support',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android.permission.USE_FULL_SCREEN_INTENT'));
      expect(manifest, contains('tools:node="remove"'));
      expect(manifest, contains('android.permission.BLUETOOTH"'));
      expect(manifest, contains('android.permission.BLUETOOTH_ADMIN'));
      expect(manifest, contains('android.permission.BLUETOOTH_CONNECT'));
      expect(manifest, contains('android:maxSdkVersion="30"'));
      expect(manifest, contains('android.hardware.camera'));
      expect(manifest, contains('android.hardware.camera.autofocus'));
      expect(manifest, contains('android:required="false"'));
      expect(
        manifest,
        isNot(
          contains(
            'com.hiennv.flutter_callkit_incoming.activities.CallkitActivity',
          ),
        ),
      );
    },
  );

  test('AOS call code never requests Android full-screen-intent access', () {
    final callRoot = Directory('lib/features/connect/calls');
    final dartSources = callRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartSources) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('canUseFullScreenIntent(')));
      expect(source, isNot(contains('requestFullIntentPermission(')));
      expect(source, isNot(contains('requestFullScreenIntentPermission(')));
    }
  });

  test(
    'CallKit Android params explicitly choose notification not full screen',
    () {
      final source = File(
        'lib/features/connect/calls/platform/callkit/'
        'callkit_params_mapper.dart',
      ).readAsStringSync();

      expect(source, contains('isCustomNotification: false'));
      expect(source, contains('isFullScreen: false'));
      expect(source, contains('isShowFullLockedScreen: false'));
      expect(
        source,
        contains("incomingCallNotificationChannelName: 'AOS Calls'"),
      );
    },
  );

  test(
    'LiveKit call media uses external-call lifecycle and modern routing',
    () {
      final liveKit = File(
        'lib/core/media/livekit_service.dart',
      ).readAsStringSync();
      final media = File(
        'lib/features/connect/calls/application/services/'
        'call_media_service.dart',
      ).readAsStringSync();

      expect(
        liveKit,
        contains('AudioSessionManagementMode.externalCallSystem'),
      );
      expect(liveKit, contains('setEngineAvailability('));
      expect(liveKit, contains('AudioEngineAvailability.none'));
      expect(liveKit, contains('setSpeakerOutputPreferred('));
      expect(media, contains('Permission.bluetooth'));
      expect(media, contains('Permission.bluetoothConnect'));
      expect(media, contains('permissionsAlreadyPrepared'));
    },
  );

  test('incoming video does not start camera preview before answer', () {
    final source = File(
      'lib/features/connect/calls/presentation/screens/'
      'video_call_ringing_screen.dart',
    ).readAsStringSync();

    expect(source, contains("if (state.direction == 'outgoing')"));
    expect(
      source,
      isNot(
        contains(
          "state.direction == 'outgoing' || state.direction == 'incoming'",
        ),
      ),
    );
  });

  test('iOS call configuration matches implemented FCM contract', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final mapper = File(
      'lib/features/connect/calls/platform/callkit/'
      'callkit_params_mapper.dart',
    ).readAsStringSync();

    expect(plist, contains('<string>audio</string>'));
    expect(plist, contains('<string>fetch</string>'));
    expect(plist, contains('<string>remote-notification</string>'));
    expect(plist, isNot(contains('<string>voip</string>')));
    expect(mapper, contains("iconName: 'CallKitLogo'"));
    expect(mapper, contains('configureAudioSession: false'));
    expect(
      File(
        'ios/Runner/Assets.xcassets/CallKitLogo.imageset/Contents.json',
      ).existsSync(),
      isTrue,
    );
  });

  test('incoming call action copy is localized and accessible', () {
    final widget = File(
      'lib/features/connect/calls/presentation/widgets/session/'
      'incoming_call_action_bar.dart',
    ).readAsStringSync();

    expect(widget, contains('chat_decline_call'));
    expect(widget, contains('chat_answer_call'));
    expect(widget, contains('Semantics('));
    expect(widget, contains('button: true'));
    expect(widget, contains('maxLines: 2'));
  });

  test('outgoing native flow still registers CallKit startCall', () {
    final source = File(
      'lib/features/connect/calls/platform/callkit/callkit_service.dart',
    ).readAsStringSync();
    expect(source, contains('FlutterCallkitIncoming.startCall(params)'));
  });

  test('push token registration remains independent of display permission', () {
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
  });
}
