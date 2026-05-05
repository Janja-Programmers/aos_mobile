import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/connect/calls/application/services/call_signaling_handler.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
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
    _sub?.cancel();

    _sub = eventStream.listen((event) async {
      switch (event.type) {
        case RealtimeEventType.aosIncomingCall:
          appLogger.i('📞 incoming-call');

          final data = Map<String, dynamic>.from(event.data);

          final shouldRing = await signalingHandler.handleIncomingCall(data);

          if (shouldRing) {
            await _showCallKitIncoming(data);
          }

          break;

        case RealtimeEventType.aosCallAccepted:
          appLogger.i('✅ call-accepted');
          await signalingHandler.handleCallAccepted(
            Map<String, dynamic>.from(event.data),
          );
          break;

        case RealtimeEventType.aosCallNotAnswered:
          appLogger.i('📵 call-not-answered');
          await signalingHandler.handleCallNotAnswered(
            Map<String, dynamic>.from(event.data),
          );

          await _endNativeCallFromPayload(event.data);
          break;

        case RealtimeEventType.aosCallRejected:
          appLogger.i('❌ call-rejected');
          await signalingHandler.handleCallRejected(
            Map<String, dynamic>.from(event.data),
          );

          await _endNativeCallFromPayload(event.data);
          break;

        case RealtimeEventType.aosCallEnded:
          appLogger.i('🔚 call-ended');
          await signalingHandler.handleCallEnded(
            Map<String, dynamic>.from(event.data),
          );

          await _endNativeCallFromPayload(event.data);
          break;

        case RealtimeEventType.aosCallCancelled:
          appLogger.i('📴 call-cancelled');
          await signalingHandler.handleCallCancelled(
            Map<String, dynamic>.from(event.data),
          );

          await _endNativeCallFromPayload(event.data);
          break;

        default:
          break;
      }
    });
  }

  Future<void> _showCallKitIncoming(Map<String, dynamic> data) async {
    final callId = data['call_id']?.toString();
    final roomName = data['room_name']?.toString();
    final callTypeRaw = data['call_type']?.toString();
    final callerRaw = data['caller']?.toString();

    if (callId == null || callId.isEmpty) {
      appLogger.e('❌ Cannot show CallKit: missing call_id');
      return;
    }

    final callType = callTypeRaw == 'video'
        ? AOSCallType.video
        : AOSCallType.audio;

    final caller = callerRaw == null || callerRaw.isEmpty
        ? null
        : CallParticipant(
            userId: callerRaw,
            displayName: callerRaw,
            avatarUrl: null,
          );

    await callKitService.showIncomingCall(
      callId: callId,
      callType: callType,
      caller: caller,
      roomName: roomName,
    );
  }

  Future<void> _endNativeCallFromPayload(Map<String, dynamic> data) async {
    final callId = data['call_id']?.toString();
    await callKitService.endCall(callId: callId);
  }

  void detach() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    detach();
  }
}
