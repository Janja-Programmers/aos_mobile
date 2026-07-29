import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';

class LiveRealtimeListener {
  final RealtimeService _realtime;
  final LiveManager _manager;

  StreamSubscription<RealtimeEvent>? _sub;

  LiveRealtimeListener(this._realtime, this._manager);

  // -----------------------------
  // INIT
  // -----------------------------
  void init() {
    unawaited(_sub?.cancel());

    _sub = _realtime.events.listen(_handleEvent);

    appLogger.i('[LiveRealtime] ✅ Listener attached');
  }

  // -----------------------------
  // DISPOSE
  // -----------------------------
  void dispose() {
    unawaited(_sub?.cancel());
    _sub = null;

    appLogger.i('[LiveRealtime] ❌ Listener disposed');
  }

  // -----------------------------
  // EVENT ROUTER
  // -----------------------------
  void _handleEvent(RealtimeEvent event) {
    switch (event.type) {
      case RealtimeEventType.aosLiveEnded:
        appLogger.i('_handleEvent | aosLiveEnded');
        _handleLiveEnded(event.data);
        break;

      case RealtimeEventType.aosLiveViewerCount:
        appLogger.i('_handleEvent | aosLiveViewerCount');
        _handleViewerCount(event.data);
        break;

      case RealtimeEventType.aosLiveStarted:
        appLogger.i('_handleEvent | aosLiveStarted');
        _handleLiveStarted(event.data);
        break;

      default:
        return;
    }
  }

  // -----------------------------
  // LIVE ENDED
  // -----------------------------
  void _handleLiveEnded(dynamic payload) {
    final data = _extract(payload);
    final liveId = data['live_id']?.toString();

    if (liveId == null || liveId.isEmpty) {
      appLogger.e('[LiveRealtime] Invalid live-ended payload');
      return;
    }

    _manager.onLiveEndedEvent(liveId: liveId);
  }

  // -----------------------------
  // VIEWER COUNT
  // -----------------------------
  void _handleViewerCount(dynamic payload) {
    final data = _extract(payload);

    final liveId = data['live_id']?.toString();
    final countRaw = data['viewer_count'];

    if (liveId == null || countRaw == null) {
      appLogger.e('[LiveRealtime] Invalid viewer-count payload');
      return;
    }

    final count = int.tryParse(countRaw.toString()) ?? 0;

    _manager.onViewerCountUpdatedEvent(liveId: liveId, viewerCount: count);
  }

  // -----------------------------
  // LIVE STARTED
  // -----------------------------
  void _handleLiveStarted(dynamic payload) {
    final data = _extract(payload);
    final liveId = data['live_id']?.toString();

    if (liveId == null || liveId.isEmpty) {
      appLogger.e('[LiveRealtime] Invalid live-started payload');
      return;
    }

    _manager.onLiveStartedEvent(liveId: liveId);
  }

  // -----------------------------
  // HELPER
  // -----------------------------
  Map<String, dynamic> _extract(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return const {};
  }
}
