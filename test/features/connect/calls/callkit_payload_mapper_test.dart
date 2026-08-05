import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_payload_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps authoritative incoming-call payload to native params', () {
    final params = const CallKitPayloadMapper().fromPushData(<String, dynamic>{
      'event': 'aos_incoming_call',
      'type': 'incoming_call',
      'call_id': 'CALL-2026-00003',
      'call_type': 'video',
      'caller_display_name': 'AOS Caller',
      'room_name': 'call-room',
    });

    expect(params.extra?['call_id'], 'CALL-2026-00003');
    expect(params.type, 1);
    expect(params.nameCaller, 'AOS Caller');
    expect(params.android?.ringtonePath, 'system_ringtone_default');
    expect(params.missedCallNotification?.showNotification, isFalse);
    expect(params.missedCallNotification?.isShowCallback, isFalse);
  });

  test('rejects a payload without the canonical call id', () {
    expect(
      () => const CallKitPayloadMapper().fromPushData(<String, dynamic>{}),
      throwsArgumentError,
    );
  });
}
