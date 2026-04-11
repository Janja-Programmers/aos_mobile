import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';

class LiveSignalingHandler {
  final LiveManager liveManager;

  const LiveSignalingHandler({required this.liveManager});

  // ================= LIVE STARTED =================
  Future<void> handleLiveStarted(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id'] as String?;

      if (liveId == null) {
        appLogger.e('❌ Invalid live-started payload: $data');
        return;
      }

      appLogger.i('🔴 Live started parsed');

      await liveManager.onLiveStartedEvent(liveId: liveId);
    } catch (e, s) {
      appLogger.e('handleLiveStarted failed', error: e, stackTrace: s);
    }
  }

  // ================= LIVE ENDED =================
  Future<void> handleLiveEnded(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id'] as String?;

      if (liveId == null) {
        appLogger.e('❌ Invalid live-ended payload: $data');
        return;
      }

      appLogger.i('🔚 Live ended parsed');

      await liveManager.onLiveEndedEvent(liveId: liveId);
    } catch (e, s) {
      appLogger.e('handleLiveEnded failed', error: e, stackTrace: s);
    }
  }

  // ================= VIEWER COUNT =================
  Future<void> handleViewerCountUpdated(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id'] as String?;
      final viewerCount = data['viewer_count'] as int?;

      if (liveId == null || viewerCount == null) {
        appLogger.e('❌ Invalid viewer-count payload: $data');
        return;
      }

      appLogger.i('👀 Viewer count parsed → $viewerCount');

      await liveManager.onViewerCountUpdatedEvent(
        liveId: liveId,
        viewerCount: viewerCount,
      );
    } catch (e, s) {
      appLogger.e('handleViewerCountUpdated failed', error: e, stackTrace: s);
    }
  }
}
