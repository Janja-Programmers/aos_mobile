import 'package:africaonlinestores/features/connect/calls/application/services/missed_call_callback_service.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('callback resolves original video call type before starting', () async {
    String? readCallId;
    String? startedUserId;
    AOSCallType? startedType;
    CallParticipant? startedReceiver;

    final service = MissedCallCallbackService(
      readCallStatus: ({required String callId}) async {
        readCallId = callId;
        return <String, dynamic>{
          'call_type': 'video',
          'caller': 'ACC-CANONICAL',
          'caller_display_name': 'Canonical Caller',
          'caller_avatar': 'https://example.com/canonical.png',
        };
      },
      startOutgoingCall:
          ({
            required String userId,
            required AOSCallType callType,
            CallParticipant? receiver,
          }) async {
            startedUserId = userId;
            startedType = callType;
            startedReceiver = receiver;
            return true;
          },
    );

    final started = await service.callBack(
      callerUserId: ' ACC-CALLER ',
      callerDisplayName: ' Caller ',
      callerAvatarUrl: ' https://example.com/avatar.png ',
      originalCallId: ' CALL-2026-00001 ',
    );

    expect(started, isTrue);
    expect(readCallId, 'CALL-2026-00001');
    expect(startedUserId, 'ACC-CANONICAL');
    expect(startedType, AOSCallType.video);
    expect(startedReceiver?.userId, 'ACC-CANONICAL');
    expect(startedReceiver?.displayName, 'Canonical Caller');
    expect(startedReceiver?.avatarUrl, 'https://example.com/canonical.png');
  });

  test(
    'callback safely falls back to audio when status lookup fails',
    () async {
      AOSCallType? startedType;

      final service = MissedCallCallbackService(
        readCallStatus: ({required String callId}) async {
          throw StateError('offline');
        },
        startOutgoingCall:
            ({
              required String userId,
              required AOSCallType callType,
              CallParticipant? receiver,
            }) async {
              startedType = callType;
              return true;
            },
      );

      final started = await service.callBack(
        callerUserId: 'ACC-CALLER',
        callerDisplayName: 'Caller',
        originalCallId: 'CALL-2026-00002',
      );

      expect(started, isTrue);
      expect(startedType, AOSCallType.audio);
    },
  );

  test('callback rejects a missing canonical caller ID', () async {
    var starterCalled = false;

    final service = MissedCallCallbackService(
      readCallStatus: ({required String callId}) async => <String, dynamic>{},
      startOutgoingCall:
          ({
            required String userId,
            required AOSCallType callType,
            CallParticipant? receiver,
          }) async {
            starterCalled = true;
            return true;
          },
    );

    final started = await service.callBack(
      callerUserId: '   ',
      callerDisplayName: 'Caller',
    );

    expect(started, isFalse);
    expect(starterCalled, isFalse);
  });
}
