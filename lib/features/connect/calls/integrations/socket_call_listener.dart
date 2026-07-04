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

    _sub = eventStream.listen((event) async {
      switch (event.type) {
        case RealtimeEventType.aosIncomingCall:
          appLogger.i('📞 incoming-call');

          final data = asJsonMap(event.data);

          await signalingHandler.handleIncomingCall(data);

          break;

        case RealtimeEventType.aosCallRinging:
          appLogger.i('📳 call-ringing');
          await signalingHandler.handleCallRinging(asJsonMap(event.data));
          break;

        case RealtimeEventType.aosCallAccepted:
          appLogger.i('✅ call-accepted');
          await signalingHandler.handleCallAccepted(asJsonMap(event.data));
          break;

        case RealtimeEventType.aosCallNotAnswered:
          appLogger.i('📵 call-not-answered');
          await signalingHandler.handleCallNotAnswered(asJsonMap(event.data));

          await _endNativeCallFromPayload(asJsonMap(event.data));
          break;

        case RealtimeEventType.aosCallRejected:
          appLogger.i('❌ call-rejected');
          await signalingHandler.handleCallRejected(asJsonMap(event.data));

          await _endNativeCallFromPayload(asJsonMap(event.data));
          break;

        case RealtimeEventType.aosCallEnded:
          appLogger.i('🔚 call-ended');
          await signalingHandler.handleCallEnded(asJsonMap(event.data));

          await _endNativeCallFromPayload(asJsonMap(event.data));
          break;

        case RealtimeEventType.aosCallCancelled:
          appLogger.i('📴 call-cancelled');
          await signalingHandler.handleCallCancelled(asJsonMap(event.data));

          await _endNativeCallFromPayload(asJsonMap(event.data));
          break;

        case RealtimeEventType.aosCallVideoUpgradeRequested:
          appLogger.i('📹 video-upgrade-requested');
          await signalingHandler.handleVideoUpgradeRequested(
            asJsonMap(event.data),
          );
          break;

        case RealtimeEventType.aosCallVideoUpgradeAccepted:
          appLogger.i('✅ video-upgrade-accepted');
          await signalingHandler.handleVideoUpgradeAccepted(
            asJsonMap(event.data),
          );
          break;

        case RealtimeEventType.aosCallVideoUpgradeDeclined:
          appLogger.i('🚫 video-upgrade-declined');
          await signalingHandler.handleVideoUpgradeDeclined(
            asJsonMap(event.data),
          );
          break;

        case RealtimeEventType.aosCallVideoUpgradeCancelled:
          appLogger.i('📵 video-upgrade-cancelled');
          await signalingHandler.handleVideoUpgradeCancelled(
            asJsonMap(event.data),
          );
          break;

        default:
          break;
      }
    });
  }

  Future<void> _endNativeCallFromPayload(Map<String, dynamic> data) async {
    final callId =
        _cleanString(data['call_id']) ??
        _cleanString(data['id']) ??
        _cleanString(data['callId']) ??
        _cleanString(data['callID']);
    await callKitService.endCall(callId: callId);
  }

  String? _cleanString(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  void detach() {
    unawaited(_sub?.cancel());
    _sub = null;
  }

  void dispose() {
    detach();
  }
}
