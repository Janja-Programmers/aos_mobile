import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/calls/application/services/call_signaling_handler.dart';

class SocketCallListener {
  final Stream<RealtimeEvent> eventStream;
  final CallSignalingHandler signalingHandler;

  StreamSubscription<RealtimeEvent>? _sub;

  SocketCallListener({
    required this.eventStream,
    required this.signalingHandler,
  });

  void attach() {
    _sub?.cancel();

    _sub = eventStream.listen((event) async {
      switch (event.type) {
        case RealtimeEventType.aosIncomingCall:
          appLogger.i('📞 incoming-call');
          await signalingHandler.handleIncomingCall(
            Map<String, dynamic>.from(event.data),
          );
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
          break;

        case RealtimeEventType.aosCallRejected:
          appLogger.i('❌ call-rejected');
          await signalingHandler.handleCallRejected(
            Map<String, dynamic>.from(event.data),
          );
          break;

        case RealtimeEventType.aosCallEnded:
          appLogger.i('🔚 call-ended');
          await signalingHandler.handleCallEnded(
            Map<String, dynamic>.from(event.data),
          );
          break;

        default:
          // ignore other events
          break;
      }
    });
  }

  void detach() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    detach();
  }
}
