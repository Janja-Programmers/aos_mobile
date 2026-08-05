import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/call_signaling_handler.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_service.dart';

class SocketCallListener {
  final Stream<RealtimeEvent> eventStream;
  final CallSignalingHandler signalingHandler;
  final CallKitService callKitService;

  StreamSubscription<RealtimeEvent>? _sub;

  SocketCallListener({
    required this.eventStream,
    required this.signalingHandler,
    required this.callKitService,
  });

  void attach() {
    unawaited(_sub?.cancel());
    appLogger.i('📞 SocketCallListener attached');

    _sub = eventStream.listen(
      (event) async {
        final data = asJsonMap(event.data);
        final callId = _extractCallId(data);

        switch (event.type) {
          case RealtimeEventType.aosIncomingCall:
            _logRealtimeEvent('incoming', callId);
            await signalingHandler.handleIncomingCall(data);
            break;

          case RealtimeEventType.aosCallRinging:
            _logRealtimeEvent('ringing', callId);
            await signalingHandler.handleCallRinging(data);
            break;

          case RealtimeEventType.aosCallAccepted:
            _logRealtimeEvent('accepted', callId);
            await signalingHandler.handleCallAccepted(data);
            break;

          case RealtimeEventType.aosCallNotAnswered:
            _logRealtimeEvent('not_answered', callId);
            await signalingHandler.handleCallNotAnswered(data);
            await _endNativeCallFromPayload(data);
            break;

          case RealtimeEventType.aosCallRejected:
            _logRealtimeEvent('rejected', callId);
            await signalingHandler.handleCallRejected(data);
            await _endNativeCallFromPayload(data);
            break;

          case RealtimeEventType.aosCallEnded:
            _logRealtimeEvent('ended', callId);
            await signalingHandler.handleCallEnded(data);
            await _endNativeCallFromPayload(data);
            break;

          case RealtimeEventType.aosCallCancelled:
            _logRealtimeEvent('cancelled', callId);
            await signalingHandler.handleCallCancelled(data);
            await _endNativeCallFromPayload(data);
            break;

          case RealtimeEventType.aosCallVideoUpgradeRequested:
            _logRealtimeEvent('video_upgrade_requested', callId);
            await signalingHandler.handleVideoUpgradeRequested(data);
            break;

          case RealtimeEventType.aosCallVideoUpgradeAccepted:
            _logRealtimeEvent('video_upgrade_accepted', callId);
            await signalingHandler.handleVideoUpgradeAccepted(data);
            break;

          case RealtimeEventType.aosCallVideoUpgradeDeclined:
            _logRealtimeEvent('video_upgrade_declined', callId);
            await signalingHandler.handleVideoUpgradeDeclined(data);
            break;

          case RealtimeEventType.aosCallVideoUpgradeCancelled:
            _logRealtimeEvent('video_upgrade_cancelled', callId);
            await signalingHandler.handleVideoUpgradeCancelled(data);
            break;

          default:
            break;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        appLogger.e(
          '📞 SocketCallListener stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void _logRealtimeEvent(String event, String? callId) {
    appLogger.i(
      '📞 Realtime call event (event=$event, callId=${callId ?? 'none'})',
    );
  }

  Future<void> _endNativeCallFromPayload(Map<String, dynamic> data) async {
    await callKitService.endCall(callId: _extractCallId(data));
  }

  String? _extractCallId(Map<String, dynamic> data) {
    return _cleanString(data['call_id']) ??
        _cleanString(data['id']) ??
        _cleanString(data['callId']) ??
        _cleanString(data['callID']);
  }

  String? _cleanString(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  void detach() {
    if (_sub != null) {
      appLogger.i('📞 SocketCallListener detached');
    }
    unawaited(_sub?.cancel());
    _sub = null;
  }

  void dispose() {
    detach();
  }
}
