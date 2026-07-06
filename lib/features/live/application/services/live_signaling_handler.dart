import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';

class LiveSignalingHandler {
  final LiveManager liveManager;

  const LiveSignalingHandler({required this.liveManager});

  // ================= LIVE STARTED =================

  Future<void> handleLiveStarted(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();

      if (liveId == null || liveId.isEmpty) {
        appLogger.e('❌ Invalid live-started payload: $data');
        return;
      }

      await liveManager.onLiveStartedEvent(liveId: liveId);
    } catch (e, s) {
      appLogger.e('handleLiveStarted failed', error: e, stackTrace: s);
    }
  }

  // ================= LIVE ENDED =================

  Future<void> handleLiveEnded(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();

      if (liveId == null || liveId.isEmpty) {
        appLogger.e('❌ Invalid live-ended payload: $data');
        return;
      }

      appLogger.i('🔚 Live ended parsed → $liveId');

      await liveManager.onLiveEndedEvent(liveId: liveId);
    } catch (e, s) {
      appLogger.e('handleLiveEnded failed', error: e, stackTrace: s);
    }
  }

  // ================= VIEWER COUNT =================

  Future<void> handleViewerCountUpdated(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();
      final viewerCount = _parseInt(data['viewer_count']);

      if (liveId == null || liveId.isEmpty || viewerCount == null) {
        return;
      }

      await liveManager.onViewerCountUpdatedEvent(
        liveId: liveId,
        viewerCount: viewerCount,
      );
    } catch (e, s) {
      appLogger.e('handleViewerCountUpdated failed', error: e, stackTrace: s);
    }
  }

  // ================= VIEWER JOINED =================

  Future<void> handleViewerJoined(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();

      if (liveId == null || liveId.isEmpty) {
        appLogger.e('❌ Invalid viewer-joined payload: $data');
        return;
      }

      await liveManager.onViewerJoinedEvent(liveId: liveId, data: data);
    } catch (e, s) {
      appLogger.e('handleViewerJoined failed', error: e, stackTrace: s);
    }
  }

  // ================= VIEWER LEFT =================

  Future<void> handleViewerLeft(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();

      if (liveId == null || liveId.isEmpty) {
        appLogger.e('❌ Invalid viewer-left payload: $data');
        return;
      }

      await liveManager.onViewerLeftEvent(liveId: liveId, data: data);
    } catch (e, s) {
      appLogger.e('handleViewerLeft failed', error: e, stackTrace: s);
    }
  }

  // ================= LIVE COMMENT =================

  Future<void> handleLiveComment(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();
      final comment = data['message'] ?? data['comment'];

      if (liveId == null || liveId.isEmpty || comment is! Map) {
        appLogger.e('❌ Invalid live-comment payload: $data');
        return;
      }

      await liveManager.onLiveCommentEvent(
        liveId: liveId,
        comment: asJsonMap(comment),
      );
    } catch (_) {}
  }

  // ================= LIVE COMMENT DELETED =================

  Future<void> handleLiveCommentDeleted(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();
      final commentIds = asJsonList(data['deleted_message_ids'])
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      final commentId = commentIds.isNotEmpty
          ? commentIds.first
          : data['message_id']?.toString() ?? data['comment_id']?.toString();

      if (liveId == null ||
          liveId.isEmpty ||
          commentId == null ||
          commentId.isEmpty) {
        appLogger.e('❌ Invalid live-comment-deleted payload: $data');
        return;
      }

      await liveManager.onLiveCommentDeletedEvent(
        liveId: liveId,
        commentId: commentId,
      );
    } catch (e, s) {
      appLogger.e('handleLiveCommentDeleted failed', error: e, stackTrace: s);
    }
  }

  // ================= LIVE REACTION =================

  Future<void> handleLiveReaction(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();
      final rawReaction = data['reaction'];

      if (liveId == null || liveId.isEmpty || rawReaction is! Map) {
        appLogger.e('❌ Invalid live-reaction payload: $data');
        return;
      }

      final reaction = asJsonMap(rawReaction);

      appLogger.i(
        '❤️ Live reaction received → liveId=$liveId, type=${reaction['reaction_type']}',
      );

      await liveManager.onLiveReactionEvent(liveId: liveId, reaction: reaction);
    } catch (e, s) {
      appLogger.e('handleLiveReaction failed', error: e, stackTrace: s);
    }
  }

  // ================= LIVE CO-HOST =================

  Future<void> handleLiveCohostEvent(Map<String, dynamic> data) async {
    try {
      final liveId = data['live_id']?.toString();
      if (liveId == null || liveId.isEmpty) return;
      await liveManager.onLiveCohostEvent(liveId: liveId, data: data);
    } catch (e, s) {
      appLogger.e('handleLiveCohostEvent failed', error: e, stackTrace: s);
    }
  }

  // ================= HELPERS =================

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
