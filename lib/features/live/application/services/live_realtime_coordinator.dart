import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/controllers/live_cohost_controller.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';

class LiveRealtimeCoordinator {
  LiveRealtimeCoordinator({
    required RealtimeService realtime,
    required LiveManager liveManager,
    required LiveCommentsController commentsController,
    required LiveCohostController cohostController,
  }) : _realtime = realtime,
       _liveManager = liveManager,
       _commentsController = commentsController,
       _cohostController = cohostController;

  final RealtimeService _realtime;
  final LiveManager _liveManager;
  final LiveCommentsController _commentsController;
  final LiveCohostController _cohostController;
  final LinkedHashSet<String> _seenEventKeys = LinkedHashSet<String>();

  StreamSubscription<RealtimeEvent>? _eventSubscription;
  StreamSubscription<void>? _connectionSubscription;
  Future<void> _eventTail = Future<void>.value();
  bool _recoveryQueued = false;

  void start() {
    if (_eventSubscription != null) return;
    _eventSubscription = _realtime.events.listen(_enqueue);
    _connectionSubscription = _realtime.connections.listen((_) {
      _enqueueRecovery();
    });
  }

  void _enqueue(RealtimeEvent event) {
    _eventTail = _eventTail.then<void>((_) => _handle(event)).onError((
      Object error,
      StackTrace stackTrace,
    ) {
      appLogger.e(
        'Live realtime event failed',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  void _enqueueRecovery() {
    if (_recoveryQueued) return;
    _recoveryQueued = true;
    _eventTail = _eventTail
        .then<void>((_) async {
          try {
            await _recover();
          } finally {
            _recoveryQueued = false;
          }
        })
        .onError((Object error, StackTrace stackTrace) {
          appLogger.e(
            'Live realtime recovery failed',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }

  Future<void> _handle(RealtimeEvent event) async {
    final data = asJsonMap(event.data);
    final liveId = data['live_id']?.toString() ?? '';
    final currentLiveId = _liveManager.currentState.session?.liveId;
    if (liveId.isEmpty || currentLiveId != liveId) return;

    final eventKey = _eventKey(event.type, data);
    if (eventKey != null && !_remember(eventKey)) return;

    switch (event.type) {
      case RealtimeEventType.aosLiveStarted:
        _liveManager.onLiveStartedEvent(liveId: liveId);
        break;
      case RealtimeEventType.aosLiveEnded:
        await _liveManager.onLiveEndedEvent(liveId: liveId);
        break;
      case RealtimeEventType.aosLiveViewerCount:
        final viewerCount = _asInt(data['viewer_count']);
        if (viewerCount != null) {
          _liveManager.onViewerCountUpdatedEvent(
            liveId: liveId,
            viewerCount: viewerCount,
          );
        }
        break;
      case RealtimeEventType.aosLiveComment:
        _commentsController.insertFromRealtime(data);
        break;
      case RealtimeEventType.aosLiveCommentDeleted:
        _commentsController.removeManyFromRealtime(_deletedMessageIds(data));
        break;
      case RealtimeEventType.aosLiveReaction:
        final rawReaction = data['reaction'];
        if (rawReaction is Map<Object?, Object?>) {
          final reaction = LiveReaction.fromJson(asJsonMap(rawReaction));
          _liveManager.onLiveReactionEvent(reaction);
        }
        break;
      case RealtimeEventType.aosLiveCohostInvited:
      case RealtimeEventType.aosLiveCohostRequestReceived:
      case RealtimeEventType.aosLiveCohostAccepted:
      case RealtimeEventType.aosLiveCohostRejected:
      case RealtimeEventType.aosLiveCohostCancelled:
      case RealtimeEventType.aosLiveCohostActivated:
      case RealtimeEventType.aosLiveCohostStarted:
      case RealtimeEventType.aosLiveCohostEnded:
        await _cohostController.handleRealtime(data);
        break;
      case RealtimeEventType.aosLiveViewerJoined:
      case RealtimeEventType.aosLiveViewerLeft:
      case RealtimeEventType.chatNewMessage:
      case RealtimeEventType.chatTyping:
      case RealtimeEventType.aosMessageStatus:
      case RealtimeEventType.aosMessageEdited:
      case RealtimeEventType.aosMessagesDeleted:
      case RealtimeEventType.aosMessageReactionUpdated:
      case RealtimeEventType.presenceUpdate:
      case RealtimeEventType.aosIncomingCall:
      case RealtimeEventType.aosCallRinging:
      case RealtimeEventType.aosCallAccepted:
      case RealtimeEventType.aosCallRejected:
      case RealtimeEventType.aosCallEnded:
      case RealtimeEventType.aosCallNotAnswered:
      case RealtimeEventType.aosCallCancelled:
      case RealtimeEventType.aosCallVideoUpgradeRequested:
      case RealtimeEventType.aosCallVideoUpgradeAccepted:
      case RealtimeEventType.aosCallVideoUpgradeDeclined:
      case RealtimeEventType.aosCallVideoUpgradeCancelled:
      case RealtimeEventType.aosFollow:
      case RealtimeEventType.aosMissedCall:
      case RealtimeEventType.aosAdApproved:
      case RealtimeEventType.aosAdRejected:
      case RealtimeEventType.aosAdExpired:
      case RealtimeEventType.aosVerificationApproved:
      case RealtimeEventType.aosVerificationRejected:
      case RealtimeEventType.aosNewShort:
      case RealtimeEventType.aosShortLike:
      case RealtimeEventType.aosShortComment:
      case RealtimeEventType.aosCommentReply:
      case RealtimeEventType.pushNotification:
      case RealtimeEventType.unknown:
        break;
    }
  }

  Future<void> _recover() async {
    final session = _liveManager.currentState.session;
    if (session == null) return;

    try {
      await _realtime.joinSocketRoom(session.liveId);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Could not rejoin the Live realtime room',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final wasCohost = _liveManager.currentState.isCohost;
    await _liveManager.refreshActiveLive();
    if (_liveManager.currentState.session?.liveId != session.liveId) return;
    final live = _liveManager.currentState.live;
    if (live == null || live.id != session.liveId || !live.isActive) return;

    if (wasCohost && !live.viewerState.isCohost) {
      await _liveManager.returnToViewer();
    }

    await _commentsController.fetchComments(live.id);
    _cohostController.hydrate(live);
    if (live.viewerState.isHost || live.viewerState.cohostWorkflow != null) {
      await _cohostController.load(liveId: live.id);
    }
  }

  String? _eventKey(RealtimeEventType type, Map<String, dynamic> data) {
    final liveId = data['live_id']?.toString() ?? '';
    switch (type) {
      case RealtimeEventType.aosLiveReaction:
        final reaction = asJsonMap(data['reaction']);
        final id =
            reaction['reaction_id']?.toString() ??
            reaction['id']?.toString() ??
            '';
        return id.isEmpty ? null : '${type.name}:$liveId:$id';
      case RealtimeEventType.aosLiveComment:
        final message = asJsonMap(data['message'] ?? data['comment']);
        final id =
            message['message_id']?.toString() ??
            message['id']?.toString() ??
            '';
        return id.isEmpty ? null : '${type.name}:$liveId:$id';
      case RealtimeEventType.aosLiveCommentDeleted:
        final ids = _deletedMessageIds(data).join(',');
        return ids.isEmpty ? null : '${type.name}:$liveId:$ids';
      case RealtimeEventType.aosLiveCohostInvited:
      case RealtimeEventType.aosLiveCohostRequestReceived:
      case RealtimeEventType.aosLiveCohostAccepted:
      case RealtimeEventType.aosLiveCohostRejected:
      case RealtimeEventType.aosLiveCohostCancelled:
      case RealtimeEventType.aosLiveCohostActivated:
      case RealtimeEventType.aosLiveCohostStarted:
      case RealtimeEventType.aosLiveCohostEnded:
        final cohost = asJsonMap(data['cohost']);
        final id =
            cohost['cohost_id']?.toString() ?? cohost['id']?.toString() ?? '';
        final status = cohost['status']?.toString() ?? type.name;
        return id.isEmpty ? null : '$liveId:$id:$status';
      case RealtimeEventType.aosLiveEnded:
      case RealtimeEventType.aosLiveStarted:
        return '${type.name}:$liveId';
      default:
        return null;
    }
  }

  bool _remember(String key) {
    if (!_seenEventKeys.add(key)) return false;
    while (_seenEventKeys.length > 512) {
      _seenEventKeys.remove(_seenEventKeys.first);
    }
    return true;
  }

  Set<String> _deletedMessageIds(Map<String, dynamic> data) {
    final ids = <String>{};
    for (final item in asJsonList(data['deleted_message_ids'])) {
      final id = item?.toString() ?? '';
      if (id.isNotEmpty) ids.add(id);
    }
    final single = data['message_id']?.toString() ?? '';
    if (single.isNotEmpty) ids.add(single);
    return ids;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _eventTail;
    _eventSubscription = null;
    _connectionSubscription = null;
  }
}
