import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/live/application/services/live_signaling_handler.dart';

class SocketLiveListener {
  final Stream<RealtimeEvent> eventStream;
  final LiveSignalingHandler signalingHandler;

  StreamSubscription<RealtimeEvent>? _sub;

  SocketLiveListener({
    required this.eventStream,
    required this.signalingHandler,
  });

  void attach() {
    _sub?.cancel();

    _sub = eventStream.listen((event) async {
      switch (event.type) {
        case RealtimeEventType.aosLiveStarted:
          appLogger.i('🔴 live-started');
          await signalingHandler.handleLiveStarted(
            Map<String, dynamic>.from(event.data),
          );
          break;

        case RealtimeEventType.aosLiveEnded:
          appLogger.i('🔚 live-ended');
          await signalingHandler.handleLiveEnded(
            Map<String, dynamic>.from(event.data),
          );
          break;

        case RealtimeEventType.aosLiveViewerCount:
          appLogger.i('👀 viewer-count');
          await signalingHandler.handleViewerCountUpdated(
            Map<String, dynamic>.from(event.data),
          );
          break;

        default:
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
