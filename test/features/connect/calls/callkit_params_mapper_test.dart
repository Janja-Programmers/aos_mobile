import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_params_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = CallKitParamsMapper();

  test('incoming params preserve backend call id and known-good ringtone', () {
    final params = mapper.incoming(
      callkitUuid: '44d915e1-5ff4-4bed-bf13-c423048ec97a',
      callId: 'CALL-2026-00001',
      callType: AOSCallType.audio,
      caller: const CallParticipant(
        userId: 'caller-id',
        displayName: 'Caller Name',
      ),
      roomName: 'room-1',
    );

    expect(params.extra?['call_id'], 'CALL-2026-00001');
    expect(params.android?.textAccept, 'Accept');
    expect(params.android?.textDecline, 'Decline');
    expect(params.android?.isFullScreen, isFalse);
    expect(params.android?.isCustomNotification, isFalse);
    expect(params.android?.ringtonePath, 'system_ringtone_default');
    expect(params.android?.incomingCallNotificationChannelName, 'AOS Calls');
    expect(params.android?.isShowFullLockedScreen, isFalse);
    expect(params.missedCallNotification?.showNotification, isFalse);
    expect(params.missedCallNotification?.isShowCallback, isFalse);
  });

  test('outgoing params start native call with callee and canonical id', () {
    final params = mapper.outgoing(
      callkitUuid: '44d915e1-5ff4-4bed-bf13-c423048ec97a',
      callId: 'CALL-2026-00002',
      callType: AOSCallType.video,
      receiver: const CallParticipant(
        userId: 'receiver-id',
        displayName: 'Receiver Name',
      ),
    );

    expect(params.extra?['call_id'], 'CALL-2026-00002');
    expect(params.extra?['call_type'], 'video');
    expect(params.nameCaller, 'Receiver Name');
    expect(params.type, 1);
    expect(params.callingNotification?.showNotification, isTrue);
  });
}
