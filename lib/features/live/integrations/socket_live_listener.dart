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
      try {
        final data = Map<String, dynamic>.from(event.data);

        switch (event.type) {
          case RealtimeEventType.aosLiveStarted:
            appLogger.i('🔴 live-started');
            await signalingHandler.handleLiveStarted(data);
            break;

          case RealtimeEventType.aosLiveEnded:
            appLogger.i('🔚 live-ended');
            await signalingHandler.handleLiveEnded(data);
            break;

          case RealtimeEventType.aosLiveViewerCount:
            appLogger.i('👀 viewer-count');
            await signalingHandler.handleViewerCountUpdated(data);
            break;

          case RealtimeEventType.aosLiveViewerJoined:
            appLogger.i('👋 viewer-joined');
            await signalingHandler.handleViewerJoined(data);
            break;

          case RealtimeEventType.aosLiveViewerLeft:
            appLogger.i('👋 viewer-left');
            await signalingHandler.handleViewerLeft(data);
            break;

          case RealtimeEventType.aosLiveComment:
            appLogger.i('💬 live-comment');
            await signalingHandler.handleLiveComment(data);
            break;

          case RealtimeEventType.aosLiveCommentDeleted:
            appLogger.i('🗑️ live-comment-deleted');
            await signalingHandler.handleLiveCommentDeleted(data);
            break;

          case RealtimeEventType.aosLiveReaction:
            appLogger.i('❤️ live-reaction');
            await signalingHandler.handleLiveReaction(data);
            break;

          default:
            break;
        }
      } catch (e, s) {
        appLogger.e(
          'SocketLiveListener failed for event: ${event.type}',
          error: e,
          stackTrace: s,
        );
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
