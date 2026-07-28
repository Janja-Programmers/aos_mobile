import 'dart:async';

import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/call_media_service.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/repository/call_repository_impl.dart';
import 'package:africaonlinestores/features/connect/calls/utils/call_timer.dart';
import 'package:flutter_riverpod/legacy.dart';

class CallManager extends StateNotifier<CallState> {
  final CallRepository repository;
  final CallMediaService mediaService;
  final CallTimer callTimer;
  final String? Function() currentUserIdReader;

  bool _isJoining = false;
  bool _isLeaving = false;
  bool _callCancelled = false;

  StreamSubscription<Duration>? _durationSub;
  Timer? _resetTimer;
  Timer? _statusReconcileTimer;
  bool _statusReconcileInFlight = false;

  CallState get currentState => state;
  final Set<String> _localTerminalCallIds = <String>{};
  final Set<String> _callActionLocks = <String>{};

  CallManager({
    required this.repository,
    required this.mediaService,
    required this.callTimer,
    required this.currentUserIdReader,
  }) : super(CallState.initial()) {
    _durationSub = callTimer.stream.listen((duration) {
      if (state.duration != duration) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  // ================= HISTORY =================
  Future<void> loadCallLogs({String? type}) async {
    try {
      state = state.copyWith(
        isLoadingHistory: true,
        clearHistoryErrorMessage: true,
      );

      final calls = await repository.listCalls(type: type);

      state = state.copyWith(callLogs: calls, isLoadingHistory: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        historyErrorMessage: e.toString(),
      );
    }
  }

  Future<List<CallLog>> loadCallGroupDetail(CallLog call) async {
    final calls = await repository.getCallGroupDetail(call: call);

    if (calls.isEmpty) {
      return [call];
    }

    return calls;
  }

  Future<bool> deleteCallLog(CallLog call) async {
    try {
      state = state.copyWith(clearHistoryErrorMessage: true);

      final callIds = await _resolveCallIdsForDelete(call);

      if (callIds.isEmpty) {
        return false;
      }

      await repository.deleteCallLogs(callIds: callIds);

      final deletedIds = callIds.toSet();
      final deletedGroupId = call.groupId;

      final remaining = state.callLogs.where((item) {
        if (deletedIds.contains(item.id) ||
            deletedIds.contains(item.effectiveLatestCallId) ||
            deletedIds.contains(item.effectiveOldestCallId)) {
          return false;
        }

        if (deletedGroupId != null &&
            deletedGroupId.trim().isNotEmpty &&
            item.groupId == deletedGroupId) {
          return false;
        }

        return true;
      }).toList();

      state = state.copyWith(callLogs: remaining);

      return true;
    } catch (e) {
      state = state.copyWith(historyErrorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteCallLogs(List<CallLog> calls) async {
    try {
      state = state.copyWith(clearHistoryErrorMessage: true);

      final ids = <String>{};
      final groupIds = <String>{};

      for (final call in calls) {
        final callIds = await _resolveCallIdsForDelete(call);
        ids.addAll(callIds);

        final groupId = call.groupId?.trim();
        if (groupId != null && groupId.isNotEmpty) {
          groupIds.add(groupId);
        }
      }

      if (ids.isEmpty) {
        return false;
      }

      await repository.deleteCallLogs(callIds: ids.toList());

      final remaining = state.callLogs.where((item) {
        if (ids.contains(item.id) ||
            ids.contains(item.effectiveLatestCallId) ||
            ids.contains(item.effectiveOldestCallId)) {
          return false;
        }

        final itemGroupId = item.groupId?.trim();
        if (itemGroupId != null && groupIds.contains(itemGroupId)) {
          return false;
        }

        return true;
      }).toList();

      state = state.copyWith(callLogs: remaining);

      return true;
    } catch (e) {
      state = state.copyWith(historyErrorMessage: e.toString());
      return false;
    }
  }

  Future<List<String>> _resolveCallIdsForDelete(CallLog call) async {
    if (!call.isGrouped) {
      return call.id.trim().isEmpty ? <String>[] : <String>[call.id];
    }

    try {
      final groupCalls = await repository.getCallGroupDetail(call: call);
      final ids = groupCalls
          .map((item) => item.id.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (ids.isNotEmpty) {
        return ids;
      }
    } catch (_) {
      // Fall back to the latest row id below. Backend may still accept it.
    }

    return call.id.trim().isEmpty ? <String>[] : <String>[call.id];
  }

  Future<bool> clearCallHistory() async {
    try {
      state = state.copyWith(
        isLoadingHistory: true,
        clearHistoryErrorMessage: true,
      );

      await repository.clearCallHistory();

      state = state.copyWith(callLogs: <CallLog>[], isLoadingHistory: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        historyErrorMessage: e.toString(),
      );

      return false;
    }
  }

  // ================= OUTGOING =================

  Future<bool> startOutgoingCall({
    required String userId,
    required AOSCallType callType,
    CallParticipant? receiver,
  }) async {
    try {
      final trimmedUserId = userId.trim();

      if (trimmedUserId.isEmpty) {
        return false;
      }

      _callCancelled = false;

      state = state.copyWith(
        isBusy: true,
        direction: 'outgoing',
        clearErrorMessage: true,
      );

      final conversationId = await repository.openConversation(
        userId: trimmedUserId,
      );

      final initiatedCall = await repository.initiateCall(
        conversationId: conversationId,
        callType: callType,
      );

      state = state.copyWith(
        callMediaMode: callType == AOSCallType.video
            ? CallMediaMode.video
            : CallMediaMode.audio,
        isLocalVideoEnabled: false,
      );

      final safeReceiver =
          initiatedCall.receiver ??
          receiver ??
          CallParticipant(userId: trimmedUserId, displayName: trimmedUserId);

      _applyBackendState(
        BackendCallStatus.initiated,
        activeCall: initiatedCall,
        direction: 'outgoing',
        caller: initiatedCall.caller,
        receiver: safeReceiver,
      );

      if (_callCancelled) return false;

      state = state.copyWith(isBusy: false);

      return true;
    } catch (e) {
      await _failCall(e);
      return false;
    }
  }

  // ================= INCOMING =================
  Future<bool> onIncomingCallEvent({
    required String callId,
    required String roomName,
    required AOSCallType callType,
    String? token,
    String? wsUrl,
    String? conversationId,
    CallParticipant? caller,
    CallParticipant? receiver,
  }) async {
    final activeCall = state.activeCall;

    if (activeCall?.id == callId) {
      return false;
    }

    if (state.isCallInProgress) {
      try {
        await repository.rejectCall(callId: callId);
      } catch (_) {
        // Best effort only.
      }

      return false;
    }

    final incomingCall = Call(
      id: callId,
      conversationId: _cleanString(conversationId) ?? '',
      callType: callType,
      roomName: roomName,
      token: token ?? '',
      wsUrl: wsUrl ?? '',
      caller: caller,
    );

    try {
      state = state.copyWith(
        isBusy: true,
        activeCall: incomingCall.copyWith(receiver: receiver),
        direction: 'incoming',
        caller: caller,
        receiver: receiver,
        hasIncomingCallUi: false,
        clearErrorMessage: true,
        callMediaMode: callType == AOSCallType.video
            ? CallMediaMode.video
            : CallMediaMode.audio,
        isLocalVideoEnabled: false,
      );

      try {
        await repository.markCallRinging(callId: callId);
      } catch (_) {
        // Best effort only.
      }

      _applyBackendState(
        BackendCallStatus.ringing,
        activeCall: incomingCall.copyWith(receiver: receiver),
        direction: 'incoming',
        caller: caller,
        receiver: receiver,
        hasIncomingCallUi: true,
      );

      state = state.copyWith(isBusy: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        activeCallBuilder: () => null,
        callerBuilder: () => null,
        clearDirection: true,
        hasIncomingCallUi: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  Future<bool> ensureIncomingCallHydrated({required String callId}) async {
    final normalizedCallId = callId.trim();

    if (normalizedCallId.isEmpty) {
      return false;
    }

    if (state.isCallInProgress && state.activeCall?.id != normalizedCallId) {
      return false;
    }

    try {
      final statusPayload = await repository.getCallStatus(
        callId: normalizedCallId,
      );

      final backendStatus = _parseBackendStatus(statusPayload['status']);

      if (backendStatus == null || _isTerminalStatus(backendStatus)) {
        return false;
      }

      final callType = _parseCallType(statusPayload['call_type']);
      final caller = _parseParticipant(
        user: statusPayload['caller'],
        displayName: statusPayload['caller_display_name'],
        avatar: statusPayload['caller_avatar'],
      );
      final receiver = _parseParticipant(
        user: statusPayload['receiver'],
        displayName: statusPayload['receiver_display_name'],
        avatar: statusPayload['receiver_avatar'],
      );

      final hydratedCall = Call(
        id: normalizedCallId,
        conversationId: _cleanString(statusPayload['conversation_id']) ?? '',
        callType: callType,
        roomName: _cleanString(statusPayload['room_name']) ?? '',
        token: _cleanString(statusPayload['token']) ?? '',
        wsUrl: _cleanString(statusPayload['ws_url']) ?? '',
        caller: caller,
        receiver: receiver,
        videoUpgradeStatus:
            _cleanString(statusPayload['video_upgrade_status']) ?? 'none',
        videoUpgradeRequestedBy: _cleanString(
          statusPayload['video_upgrade_requested_by'],
        ),
      );

      if (backendStatus == BackendCallStatus.initiated) {
        try {
          await repository.markCallRinging(callId: normalizedCallId);
        } catch (_) {
          // Best effort only. The backend may already have marked it ringing.
        }
      }

      _applyBackendState(
        backendStatus == BackendCallStatus.initiated
            ? BackendCallStatus.ringing
            : backendStatus,
        activeCall: hydratedCall,
        direction: 'incoming',
        caller: caller,
        receiver: receiver,
        hasIncomingCallUi: true,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> acceptIncomingCall({String? expectedCallId}) async {
    final callId = _resolveActionCallId(expectedCallId);
    if (callId == null) return;

    if (!_callActionLocks.add(callId)) return;

    var backendAccepted = false;

    try {
      state = state.copyWith(isBusy: true, clearErrorMessage: true);

      final hydrated = await _syncIncomingCallForAction(callId: callId);
      if (!hydrated) {
        state = state.copyWith(isBusy: false);
        return;
      }

      final syncedStatus = state.backendStatus;
      if (syncedStatus == BackendCallStatus.ongoing) {
        await _joinAlreadyOngoingIncomingCall(callId);
        state = state.copyWith(isBusy: false);
        return;
      }

      if (!_isAnswerableStatus(syncedStatus)) {
        state = state.copyWith(isBusy: false);
        return;
      }

      final activeIncomingCall = state.activeCall;
      if (activeIncomingCall == null) {
        state = state.copyWith(isBusy: false);
        return;
      }

      await mediaService.prepareForCall(
        isVideo: activeIncomingCall.callType == AOSCallType.video,
      );

      final ongoingCall = await repository.acceptCall(callId: callId);
      backendAccepted = true;
      var mergedCall = _mergeCallForAction(state.activeCall, ongoingCall);

      if (mergedCall.token.isEmpty || mergedCall.wsUrl.isEmpty) {
        final tokenCall = await repository.getCallToken(callId: callId);
        mergedCall = _mergeCallForAction(
          mergedCall,
          tokenCall.copyWith(
            conversationId: mergedCall.conversationId,
            callType: mergedCall.callType,
            caller: mergedCall.caller,
            receiver: mergedCall.receiver,
            videoUpgradeStatus: mergedCall.videoUpgradeStatus,
            videoUpgradeRequestedBy: mergedCall.videoUpgradeRequestedBy,
          ),
        );
      }

      _applyBackendState(
        BackendCallStatus.ongoing,
        activeCall: mergedCall,
        direction: 'incoming',
        caller: mergedCall.caller,
        receiver: mergedCall.receiver,
        hasIncomingCallUi: false,
      );

      await _joinRoomInternal(mergedCall);

      state = state.copyWith(isBusy: false);
    } catch (e) {
      final joinedExisting = await _joinAlreadyOngoingIncomingCall(callId);
      if (joinedExisting) {
        state = state.copyWith(isBusy: false);
        return;
      }

      state = state.copyWith(isBusy: false);

      final synced = await _applyBackendStatusIfTerminal(
        callId: callId,
        hasIncomingCallUi: false,
      );

      if (!synced && backendAccepted) {
        try {
          await repository.endCall(callId: callId);
          await _leaveRoomInternal();
          _applyBackendState(BackendCallStatus.ended, hasIncomingCallUi: false);
          return;
        } catch (_) {
          // Fall through to the existing error state when backend cleanup fails.
        }
      }

      if (!synced) {
        await _failCall(e);
      }
    } finally {
      _callActionLocks.remove(callId);
    }
  }

  Future<void> rejectIncomingCall({String? expectedCallId}) async {
    final callId = _resolveActionCallId(expectedCallId);
    if (callId == null) return;

    if (!_callActionLocks.add(callId)) return;

    try {
      state = state.copyWith(isBusy: true, clearErrorMessage: true);

      final hydrated = await _syncIncomingCallForAction(callId: callId);
      if (!hydrated) {
        state = state.copyWith(isBusy: false);
        return;
      }

      final syncedStatus = state.backendStatus;
      if (!_isAnswerableStatus(syncedStatus)) {
        state = state.copyWith(isBusy: false);
        return;
      }

      await repository.rejectCall(callId: callId);
      await _leaveRoomInternal();

      _applyBackendState(BackendCallStatus.rejected, hasIncomingCallUi: false);
    } catch (e) {
      state = state.copyWith(isBusy: false);

      final synced = await _applyBackendStatusIfTerminal(
        callId: callId,
        hasIncomingCallUi: false,
      );

      if (!synced) {
        await _failCall(e);
      }
    } finally {
      _callActionLocks.remove(callId);
    }
  }

  String? _resolveActionCallId(String? expectedCallId) {
    final expected = _cleanString(expectedCallId);
    if (expected != null) return expected;

    return _cleanString(state.activeCall?.id);
  }

  Future<bool> _syncIncomingCallForAction({required String callId}) async {
    final hydrated = await ensureIncomingCallHydrated(callId: callId);
    if (!hydrated) return false;

    if (!_matchesActiveCall(callId)) {
      return false;
    }

    if (state.direction?.trim().toLowerCase() != 'incoming') {
      return false;
    }

    final status = state.backendStatus;
    if (_isTerminalStatus(status)) {
      await _applyBackendStatusIfTerminal(
        callId: callId,
        hasIncomingCallUi: false,
      );
      return false;
    }

    return _isAnswerableStatus(status) || status == BackendCallStatus.ongoing;
  }

  bool _isAnswerableStatus(BackendCallStatus? status) {
    return status == BackendCallStatus.initiated ||
        status == BackendCallStatus.ringing;
  }

  Call _mergeCallForAction(Call? current, Call updated) {
    if (current == null) return updated;

    return current.copyWith(
      id: updated.id.isNotEmpty ? updated.id : current.id,
      conversationId: updated.conversationId.isNotEmpty
          ? updated.conversationId
          : current.conversationId,
      callType: updated.callType,
      roomName: updated.roomName.isNotEmpty
          ? updated.roomName
          : current.roomName,
      token: updated.token.isNotEmpty ? updated.token : current.token,
      wsUrl: updated.wsUrl.isNotEmpty ? updated.wsUrl : current.wsUrl,
      caller: updated.caller ?? current.caller,
      receiver: updated.receiver ?? current.receiver,
      videoUpgradeStatus: updated.videoUpgradeStatus,
      videoUpgradeRequestedBy: updated.videoUpgradeRequestedBy,
    );
  }

  Future<bool> _joinAlreadyOngoingIncomingCall(String callId) async {
    final backendStatus = await _readBackendStatus(callId);
    if (backendStatus != BackendCallStatus.ongoing) {
      return false;
    }

    try {
      final tokenCall = await repository.getCallToken(callId: callId);
      final current = state.activeCall;
      final safeTokenCall = tokenCall.copyWith(
        conversationId: current?.conversationId,
        callType: current?.callType,
        caller: current?.caller,
        receiver: current?.receiver,
        videoUpgradeStatus: current?.videoUpgradeStatus,
        videoUpgradeRequestedBy: current?.videoUpgradeRequestedBy,
      );
      final mergedCall = _mergeCallForAction(current, safeTokenCall);

      _applyBackendState(
        BackendCallStatus.ongoing,
        activeCall: mergedCall,
        direction: 'incoming',
        caller: mergedCall.caller,
        receiver: mergedCall.receiver,
        hasIncomingCallUi: false,
      );

      await _joinRoomInternal(mergedCall);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> callNotAnswered({String? expectedCallId}) async {
    final callId = expectedCallId ?? state.activeCall?.id;

    if (callId == null || callId.isEmpty) {
      return;
    }

    if (!_matchesActiveCall(callId)) {
      return;
    }

    if (_shouldIgnoreRemoteTerminalEvent(callId)) {
      return;
    }

    if (_isTerminalStatus(state.backendStatus)) {
      return;
    }

    try {
      final nextStatus = await _resolveLocalNotAnsweredStatus(callId);

      // If the backend already moved the call to ongoing, the local/native
      // timeout is stale. Do not incorrectly close the active call as missed.
      if (nextStatus == BackendCallStatus.ongoing) {
        return;
      }

      await _leaveRoomInternal();

      _applyBackendState(nextStatus, hasIncomingCallUi: false);
    } catch (e) {
      await _failCall(e);
    }
  }

  // ================= SOCKET EVENTS =================
  Future<void> onCallRingingEvent({required String callId}) async {
    final call = state.activeCall;
    if (call == null || call.id != callId) return;

    if (_isTerminalStatus(state.backendStatus)) return;

    _applyBackendState(
      BackendCallStatus.ringing,
      activeCall: call,
      direction: 'outgoing',
    );
  }

  Future<void> onCallAcceptedEvent({required String callId}) async {
    final call = state.activeCall;
    if (call == null || call.id != callId) return;

    try {
      _applyBackendState(BackendCallStatus.ongoing, activeCall: call);

      await _joinRoomInternal(call);
    } catch (e) {
      await _failCall(e);
    }
  }

  Future<void> onCallRejectedEvent({required String callId}) async {
    if (_shouldIgnoreRemoteTerminalEvent(callId)) return;

    if (state.activeCall?.id != callId) return;

    await _leaveRoomInternal();
    _applyBackendState(BackendCallStatus.rejected);
  }

  Future<void> onCallNotAnswered({required String callId}) async {
    if (_shouldIgnoreRemoteTerminalEvent(callId)) return;

    if (state.activeCall?.id != callId) return;

    await _leaveRoomInternal();

    _applyBackendState(BackendCallStatus.missed, hasIncomingCallUi: false);
  }

  Future<void> onCallCancelledEvent({required String callId}) async {
    if (_shouldIgnoreRemoteTerminalEvent(callId)) return;

    try {
      if (state.activeCall?.id != callId) return;

      await _leaveRoomInternal();

      _applyBackendState(BackendCallStatus.cancelled, hasIncomingCallUi: false);
    } catch (e) {
      await _failCall(e);
    }
  }

  Future<void> onCallEndedEvent({required String callId}) async {
    if (_shouldIgnoreRemoteTerminalEvent(callId)) return;

    if (state.activeCall?.id != callId) return;

    await _leaveRoomInternal();

    _applyBackendState(BackendCallStatus.ended);
  }

  Future<void> onVideoUpgradeRequestedEvent({
    required String callId,
    String? requestedBy,
  }) async {
    final call = state.activeCall;
    if (call == null || call.id != callId) return;
    if (_isTerminalStatus(state.backendStatus)) return;
    if (state.callMediaMode == CallMediaMode.video) return;

    final requester = _cleanVideoUpgradeUser(requestedBy);
    final requestedByMe = requester == null
        ? state.isWaitingForVideoUpgradeResponse
        : _isCurrentUser(requester);

    state = state.copyWith(
      activeCall: call.copyWith(
        videoUpgradeStatus: 'requested',
        videoUpgradeRequestedBy: requester,
      ),
      isUpgradePending: true,
      videoUpgradeStatus: 'requested',
      videoUpgradeRequestedBy: requester,
      hasIncomingVideoUpgradeRequest: !requestedByMe,
      clearVideoUpgradeErrorMessage: true,
    );
  }

  Future<void> onVideoUpgradeAcceptedEvent({required String callId}) async {
    final call = state.activeCall;
    if (call == null || call.id != callId) return;
    if (_isTerminalStatus(state.backendStatus)) return;

    final upgradedCall = call.copyWith(
      callType: AOSCallType.video,
      videoUpgradeStatus: 'accepted',
      clearVideoUpgradeRequestedBy: true,
    );

    state = state.copyWith(
      activeCall: upgradedCall,
      callMediaMode: CallMediaMode.video,
      isUpgradePending: false,
      videoUpgradeStatus: 'accepted',
      clearVideoUpgradeRequestedBy: true,
      hasIncomingVideoUpgradeRequest: false,
      isLocalVideoEnabled: true,
      clearVideoUpgradeErrorMessage: true,
    );

    try {
      await mediaService.toggleCamera(true);
    } catch (_) {
      // Best effort only. The call can continue as audio if camera fails.
    }
  }

  Future<void> onVideoUpgradeDeclinedEvent({required String callId}) async {
    final call = state.activeCall;
    if (call == null || call.id != callId) return;

    _clearVideoUpgradeState(status: 'declined');
  }

  Future<void> onVideoUpgradeCancelledEvent({required String callId}) async {
    final call = state.activeCall;
    if (call == null || call.id != callId) return;

    _clearVideoUpgradeState(status: 'cancelled');
  }

  // ================= ROOM =================
  Future<void> _joinRoomInternal(Call call) async {
    if (_isJoining || state.hasActiveRoom) return;

    if (call.wsUrl.isEmpty || call.token.isEmpty) {
      return;
    }

    final joiningCallId = call.id;

    _isJoining = true;

    callTimer.stop();

    state = state.copyWith(hasActiveRoom: false, duration: Duration.zero);

    try {
      final room = await mediaService.joinCall(
        wsUrl: call.wsUrl,
        token: call.token,
        isVideo: call.callType == AOSCallType.video,
      );

      final activeCallId = state.activeCall?.id;
      final callStillActive =
          activeCallId == joiningCallId &&
          !_callCancelled &&
          !_isTerminalStatus(state.backendStatus);

      if (!callStillActive) {
        try {
          await mediaService.leaveCall();
        } catch (_) {
          // best effort
        }

        return;
      }

      callTimer.stop();

      state = state.copyWith(
        hasActiveRoom: true,
        room: room,
        duration: Duration.zero,
        isLocalVideoEnabled: call.callType == AOSCallType.video,
      );

      _refreshUiPhase(hasActiveRoom: true);

      callTimer.start();
    } catch (e) {
      final activeCallId = state.activeCall?.id;
      final callStillActive =
          activeCallId == joiningCallId &&
          !_callCancelled &&
          !_isTerminalStatus(state.backendStatus);

      if (!callStillActive) {
        return;
      }

      await _failCall(e);
    } finally {
      _isJoining = false;
    }
  }

  Future<void> _leaveRoomInternal() async {
    if (_isLeaving) return;
    _isLeaving = true;

    try {
      await mediaService.leaveCall();
    } catch (_) {
      // best effort
    } finally {
      callTimer.stop();

      state = state.copyWith(
        hasActiveRoom: false,
        isRemoteVideoEnabled: false,
        isLocalVideoEnabled: false,
        isUpgradePending: false,
        videoUpgradeStatus: 'none',
        clearVideoUpgradeRequestedBy: true,
        hasIncomingVideoUpgradeRequest: false,
        duration: Duration.zero,
      );

      _refreshUiPhase(hasActiveRoom: false);

      _isLeaving = false;
    }
  }

  // ================= END =================
  Future<void> endCurrentCall({String? expectedCallId}) async {
    if (!_matchesActiveCall(expectedCallId)) {
      return;
    }

    final call = state.activeCall;
    if (call == null) {
      return;
    }

    if (_isTerminalStatus(state.backendStatus)) {
      return;
    }

    final callId = call.id;
    if (callId.isEmpty) {
      return;
    }

    final status = state.backendStatus;

    // Mark this call as locally terminal before calling the backend.
    // If the backend later echoes aos_call_ended / aos_call_cancelled back to us,
    // _shouldIgnoreRemoteTerminalEvent will ignore it.
    _localTerminalCallIds.add(callId);
    _callCancelled = true;

    try {
      /// EARLY STATES → CANCEL
      if (status == BackendCallStatus.initiated ||
          status == BackendCallStatus.ringing) {
        await repository.cancelCall(callId: callId);

        await _leaveRoomInternal();

        _applyBackendState(
          BackendCallStatus.cancelled,
          hasIncomingCallUi: false,
        );

        return;
      }

      /// ACTIVE / CONNECTING CALL → END
      ///
      /// Note: ongoing can mean accepted but still joining LiveKit.
      /// So ending during "Connecting..." should still call endCall,
      /// then stale LiveKit join completion/failure will be ignored by _joinRoomInternal.
      if (status == BackendCallStatus.ongoing) {
        await repository.endCall(callId: callId);

        await _leaveRoomInternal();

        _applyBackendState(BackendCallStatus.ended, hasIncomingCallUi: false);

        return;
      }
    } catch (e) {
      await _failCall(e);
    }
  }

  bool _matchesActiveCall(String? expectedCallId) {
    if (expectedCallId == null || expectedCallId.isEmpty) {
      return true;
    }

    final activeCallId = state.activeCall?.id;
    if (activeCallId == null || activeCallId.isEmpty) {
      return false;
    }

    return activeCallId == expectedCallId;
  }

  bool _shouldIgnoreRemoteTerminalEvent(String callId) {
    if (_localTerminalCallIds.contains(callId)) {
      return true;
    }

    final activeCallId = state.activeCall?.id;

    if (activeCallId == null || activeCallId.isEmpty) {
      return true;
    }

    if (activeCallId != callId) {
      return true;
    }

    if (_isTerminalStatus(state.backendStatus) ||
        state.uiPhase == UiCallPhase.finished ||
        state.uiPhase == UiCallPhase.cancelled ||
        state.uiPhase == UiCallPhase.error) {
      return true;
    }

    return false;
  }

  bool _isTerminalStatus(BackendCallStatus? status) {
    return status == BackendCallStatus.ended ||
        status == BackendCallStatus.rejected ||
        status == BackendCallStatus.missed ||
        status == BackendCallStatus.cancelled ||
        status == BackendCallStatus.failed;
  }

  Future<BackendCallStatus> _resolveLocalNotAnsweredStatus(
    String callId,
  ) async {
    final backendStatus = await _readBackendStatus(callId);

    // Backend is now the source of truth for missed-call timing.
    // If it already finalized the call, mirror that exact terminal status.
    if (_isTerminalStatus(backendStatus)) {
      return backendStatus!;
    }

    // Race guard: the user may have accepted from another surface/device while
    // the native incoming-call UI timed out locally.
    if (backendStatus == BackendCallStatus.ongoing) {
      return BackendCallStatus.ongoing;
    }

    // If the backend is still initiated/ringing, close the local UI as missed.
    // The backend timeout job/event will remain authoritative for persisted
    // call history.
    return BackendCallStatus.missed;
  }

  Future<bool> _applyBackendStatusIfTerminal({
    required String callId,
    bool? hasIncomingCallUi,
  }) async {
    final backendStatus = await _readBackendStatus(callId);

    if (!_isTerminalStatus(backendStatus)) {
      return false;
    }

    await _leaveRoomInternal();

    _applyBackendState(backendStatus!, hasIncomingCallUi: hasIncomingCallUi);

    return true;
  }

  Future<Map<String, dynamic>?> _readBackendPayload(String callId) async {
    try {
      return await repository.getCallStatus(callId: callId);
    } catch (_) {
      return null;
    }
  }

  Future<BackendCallStatus?> _readBackendStatus(String callId) async {
    final payload = await _readBackendPayload(callId);
    if (payload == null) return null;

    return _parseBackendStatus(payload['status']);
  }

  AOSCallType _parseCallType(Object? value) {
    switch (_cleanString(value)?.toLowerCase()) {
      case 'video':
        return AOSCallType.video;
      default:
        return AOSCallType.audio;
    }
  }

  CallParticipant? _parseParticipant({
    required Object? user,
    Object? displayName,
    Object? avatar,
  }) {
    final userId = _cleanString(user);
    if (userId == null) return null;

    return CallParticipant(
      userId: userId,
      displayName: _cleanString(displayName) ?? userId,
      avatarUrl: normalizeMediaUrl(_cleanString(avatar)),
    );
  }

  String? _cleanString(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  BackendCallStatus? _parseBackendStatus(dynamic value) {
    final status = value?.toString().trim().toLowerCase();

    switch (status) {
      case 'initiated':
        return BackendCallStatus.initiated;
      case 'ringing':
        return BackendCallStatus.ringing;
      case 'ongoing':
        return BackendCallStatus.ongoing;
      case 'ended':
        return BackendCallStatus.ended;
      case 'rejected':
        return BackendCallStatus.rejected;
      case 'missed':
      case 'not_answered':
      case 'no_answer':
        return BackendCallStatus.missed;
      case 'cancelled':
      case 'canceled':
        return BackendCallStatus.cancelled;
      case 'failed':
        return BackendCallStatus.failed;
      default:
        return null;
    }
  }

  void _startStatusReconciliationIfNeeded() {
    final call = state.activeCall;
    final status = state.backendStatus;

    if (call == null || call.id.trim().isEmpty || status == null) {
      _stopStatusReconciliation();
      return;
    }

    if (_isTerminalStatus(status)) {
      _stopStatusReconciliation();
      return;
    }

    if (_statusReconcileTimer != null) {
      return;
    }

    _statusReconcileTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => unawaited(_reconcileActiveCallWithBackend()),
    );
  }

  void _stopStatusReconciliation() {
    _statusReconcileTimer?.cancel();
    _statusReconcileTimer = null;
    _statusReconcileInFlight = false;
  }

  Future<void> _reconcileActiveCallWithBackend() async {
    if (_statusReconcileInFlight) return;

    final call = state.activeCall;
    final callId = call?.id.trim();

    if (callId == null || callId.isEmpty) {
      _stopStatusReconciliation();
      return;
    }

    if (_isTerminalStatus(state.backendStatus)) {
      _stopStatusReconciliation();
      return;
    }

    _statusReconcileInFlight = true;

    try {
      final payload = await _readBackendPayload(callId);
      if (payload == null || !_matchesActiveCall(callId)) return;

      final backendStatus = _parseBackendStatus(payload['status']);
      if (backendStatus == null) return;

      if (_isTerminalStatus(backendStatus)) {
        await _leaveRoomInternal();
        _applyBackendState(backendStatus, hasIncomingCallUi: false);
        return;
      }

      if (backendStatus == BackendCallStatus.ongoing) {
        await _recoverOngoingCallFromBackend(payload: payload);
        return;
      }

      if (backendStatus == BackendCallStatus.ringing &&
          state.backendStatus != BackendCallStatus.ringing) {
        _applyBackendState(
          BackendCallStatus.ringing,
          activeCall: state.activeCall,
        );
      }
    } finally {
      _statusReconcileInFlight = false;
    }
  }

  Future<void> _recoverOngoingCallFromBackend({
    required Map<String, dynamic> payload,
  }) async {
    final call = state.activeCall;
    if (call == null) return;

    final payloadCall = _callFromStatusPayload(payload, fallback: call);
    var mergedCall = _mergeCallForAction(call, payloadCall);

    if (mergedCall.token.isEmpty || mergedCall.wsUrl.isEmpty) {
      try {
        final tokenCall = await repository.getCallToken(callId: mergedCall.id);
        mergedCall = _mergeCallForAction(
          mergedCall,
          tokenCall.copyWith(
            conversationId: mergedCall.conversationId,
            callType: mergedCall.callType,
            caller: mergedCall.caller,
            receiver: mergedCall.receiver,
            videoUpgradeStatus: mergedCall.videoUpgradeStatus,
            videoUpgradeRequestedBy: mergedCall.videoUpgradeRequestedBy,
          ),
        );
      } catch (_) {
        // If token recovery fails, keep the backend status sync but do not join.
      }
    }

    _applyBackendState(
      BackendCallStatus.ongoing,
      activeCall: mergedCall,
      direction: state.direction,
      caller: mergedCall.caller,
      receiver: mergedCall.receiver,
      hasIncomingCallUi: false,
    );

    if (!state.hasActiveRoom) {
      await _joinRoomInternal(mergedCall);
    }
  }

  Call _callFromStatusPayload(
    Map<String, dynamic> payload, {
    required Call fallback,
  }) {
    final caller = _parseParticipant(
      user: payload['caller'],
      displayName: payload['caller_display_name'],
      avatar: payload['caller_avatar'],
    );
    final receiver = _parseParticipant(
      user: payload['receiver'],
      displayName: payload['receiver_display_name'],
      avatar: payload['receiver_avatar'],
    );

    final payloadCallType = _cleanString(payload['call_type']) == null
        ? fallback.callType
        : _parseCallType(payload['call_type']);

    return Call(
      id:
          _cleanString(payload['call_id']) ??
          _cleanString(payload['id']) ??
          fallback.id,
      conversationId:
          _cleanString(payload['conversation_id']) ?? fallback.conversationId,
      callType: payloadCallType,
      roomName: _cleanString(payload['room_name']) ?? fallback.roomName,
      token: _cleanString(payload['token']) ?? fallback.token,
      wsUrl: _cleanString(payload['ws_url']) ?? fallback.wsUrl,
      caller: caller ?? fallback.caller,
      receiver: receiver ?? fallback.receiver,
      videoUpgradeStatus:
          _cleanString(payload['video_upgrade_status']) ??
          fallback.videoUpgradeStatus,
      videoUpgradeRequestedBy:
          _cleanString(payload['video_upgrade_requested_by']) ??
          fallback.videoUpgradeRequestedBy,
    );
  }

  // ================= CONTROLS =================
  Future<void> toggleMute() async {
    final next = !state.isMuted;
    await mediaService.toggleMute(!next);
    state = state.copyWith(isMuted: next);
  }

  Future<void> toggleSpeaker() async {
    final next = !state.isSpeakerOn;
    await mediaService.switchSpeaker(next);
    state = state.copyWith(isSpeakerOn: next);
  }

  Future<void> toggleVideo() async {
    if (state.callMediaMode == CallMediaMode.audio) {
      await requestVideoUpgrade();
      return;
    }

    final newValue = !state.isLocalVideoEnabled;

    state = state.copyWith(isLocalVideoEnabled: newValue);

    await mediaService.toggleCamera(newValue);
  }

  Future<void> switchCamera() async {
    if (state.callMediaMode != CallMediaMode.video) return;
    if (!state.isLocalVideoEnabled) return;

    await mediaService.switchCamera();
  }

  Future<void> requestVideoUpgrade() async {
    final call = state.activeCall;
    if (call == null || call.id.isEmpty) return;
    if (state.backendStatus != BackendCallStatus.ongoing) return;
    if (state.callMediaMode != CallMediaMode.audio) return;
    if (state.isUpgradePending) return;

    final requester = _currentUserId();

    state = state.copyWith(
      isUpgradePending: true,
      videoUpgradeStatus: 'requested',
      videoUpgradeRequestedBy: requester,
      hasIncomingVideoUpgradeRequest: false,
      clearVideoUpgradeErrorMessage: true,
    );

    try {
      final updatedCall = await repository.requestVideoUpgrade(callId: call.id);
      final requestedBy =
          _cleanVideoUpgradeUser(updatedCall.videoUpgradeRequestedBy) ??
          requester;

      state = state.copyWith(
        activeCall: _mergeCallForVideoUpgrade(call, updatedCall).copyWith(
          videoUpgradeStatus: 'requested',
          videoUpgradeRequestedBy: requestedBy,
        ),
        isUpgradePending: true,
        videoUpgradeStatus: 'requested',
        videoUpgradeRequestedBy: requestedBy,
        hasIncomingVideoUpgradeRequest: false,
        clearVideoUpgradeErrorMessage: true,
      );
    } catch (e) {
      _clearVideoUpgradeState(status: 'none', errorMessage: e.toString());
    }
  }

  Future<void> acceptVideoUpgrade() async {
    final call = state.activeCall;
    if (call == null || call.id.isEmpty) return;
    if (!state.hasIncomingVideoUpgradeRequest) return;
    if (state.backendStatus != BackendCallStatus.ongoing) return;

    state = state.copyWith(clearVideoUpgradeErrorMessage: true);

    try {
      final updatedCall = await repository.respondVideoUpgrade(
        callId: call.id,
        action: 'accepted',
      );

      final upgradedCall = _mergeCallForVideoUpgrade(call, updatedCall)
          .copyWith(
            callType: AOSCallType.video,
            videoUpgradeStatus: 'accepted',
            clearVideoUpgradeRequestedBy: true,
          );

      state = state.copyWith(
        activeCall: upgradedCall,
        callMediaMode: CallMediaMode.video,
        isUpgradePending: false,
        videoUpgradeStatus: 'accepted',
        clearVideoUpgradeRequestedBy: true,
        hasIncomingVideoUpgradeRequest: false,
        isLocalVideoEnabled: true,
        clearVideoUpgradeErrorMessage: true,
      );

      await mediaService.toggleCamera(true);
    } catch (e) {
      state = state.copyWith(videoUpgradeErrorMessage: e.toString());
    }
  }

  Future<void> declineVideoUpgrade() async {
    final call = state.activeCall;
    if (call == null || call.id.isEmpty) return;
    if (!state.hasIncomingVideoUpgradeRequest) return;

    state = state.copyWith(clearVideoUpgradeErrorMessage: true);

    try {
      await repository.respondVideoUpgrade(callId: call.id, action: 'declined');

      _clearVideoUpgradeState(status: 'declined');
    } catch (e) {
      state = state.copyWith(videoUpgradeErrorMessage: e.toString());
    }
  }

  Future<void> startLocalVideoPreview() async {
    if (state.callMediaMode != CallMediaMode.video) return;
    if (!state.hasActiveRoom) return;
    if (state.isLocalVideoEnabled) return;

    try {
      await mediaService.toggleCamera(true);

      state = state.copyWith(isLocalVideoEnabled: true);
    } catch (_) {
      // Best effort only.
    }
  }

  Future<void> stopLocalVideoPreviewIfNotInCall() async {
    if (state.backendStatus == BackendCallStatus.ongoing) return;
    if (state.hasActiveRoom) return;
    if (!state.isLocalVideoEnabled) return;

    try {
      await mediaService.toggleCamera(false);

      state = state.copyWith(isLocalVideoEnabled: false);
    } catch (_) {
      // Best effort only.
    }
  }

  // ================= INTERNAL =================

  String? _currentUserId() {
    final explicitCurrentUser = _cleanVideoUpgradeUser(currentUserIdReader());
    if (explicitCurrentUser != null) {
      return explicitCurrentUser;
    }

    final call = state.activeCall;
    if (call == null) return null;

    if (state.direction == 'outgoing') {
      return _cleanVideoUpgradeUser(call.caller?.userId);
    }

    if (state.direction == 'incoming') {
      return _cleanVideoUpgradeUser(call.receiver?.userId);
    }

    return null;
  }

  bool _isCurrentUser(String? userId) {
    final cleaned = _cleanVideoUpgradeUser(userId);
    final currentUserId = _cleanVideoUpgradeUser(_currentUserId());

    if (cleaned == null || currentUserId == null) {
      return false;
    }

    return cleaned == currentUserId;
  }

  String? _cleanVideoUpgradeUser(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text.toLowerCase();
  }

  Call _mergeCallForVideoUpgrade(Call current, Call updated) {
    return current.copyWith(
      id: updated.id.isNotEmpty ? updated.id : current.id,
      conversationId: updated.conversationId.isNotEmpty
          ? updated.conversationId
          : current.conversationId,
      callType: updated.callType,
      roomName: updated.roomName.isNotEmpty
          ? updated.roomName
          : current.roomName,
      token: updated.token.isNotEmpty ? updated.token : current.token,
      wsUrl: updated.wsUrl.isNotEmpty ? updated.wsUrl : current.wsUrl,
      caller: updated.caller ?? current.caller,
      receiver: updated.receiver ?? current.receiver,
      videoUpgradeStatus: updated.videoUpgradeStatus,
      videoUpgradeRequestedBy: updated.videoUpgradeRequestedBy,
    );
  }

  void _clearVideoUpgradeState({required String status, String? errorMessage}) {
    final call = state.activeCall;

    state = state.copyWith(
      activeCall: call?.copyWith(
        videoUpgradeStatus: status,
        clearVideoUpgradeRequestedBy: true,
      ),
      isUpgradePending: false,
      videoUpgradeStatus: status,
      clearVideoUpgradeRequestedBy: true,
      hasIncomingVideoUpgradeRequest: false,
      videoUpgradeErrorMessage: errorMessage,
      clearVideoUpgradeErrorMessage: errorMessage == null,
    );
  }

  void _applyBackendState(
    BackendCallStatus nextStatus, {
    Call? activeCall,
    String? direction,
    CallParticipant? caller,
    CallParticipant? receiver,
    bool? hasIncomingCallUi,
  }) {
    final isExactDuplicate =
        state.backendStatus == nextStatus &&
        activeCall == null &&
        direction == null &&
        caller == null &&
        receiver == null &&
        hasIncomingCallUi == null;

    if (isExactDuplicate) {
      return;
    }

    final nextDirection = direction ?? state.direction;
    final nextHasIncomingUi = hasIncomingCallUi ?? state.hasIncomingCallUi;
    final nextActiveCall = activeCall ?? state.activeCall;
    final nextCallMediaMode = nextActiveCall?.callType == AOSCallType.video
        ? CallMediaMode.video
        : state.callMediaMode;

    state = state.copyWith(
      backendStatus: nextStatus,
      activeCall: activeCall,
      callMediaMode: nextCallMediaMode,
      videoUpgradeStatus:
          nextActiveCall?.videoUpgradeStatus ?? state.videoUpgradeStatus,
      videoUpgradeRequestedBy:
          nextActiveCall?.videoUpgradeRequestedBy ??
          state.videoUpgradeRequestedBy,
      direction: nextDirection,
      caller: caller ?? state.caller,
      receiver: receiver ?? state.receiver,
      hasIncomingCallUi: nextHasIncomingUi,
      uiPhase: _deriveUiPhase(
        backendStatus: nextStatus,
        direction: nextDirection,
        hasActiveRoom: state.hasActiveRoom,
      ),
      isBusy: false,
    );

    if (_isTerminal(nextStatus)) {
      callTimer.stop();
      _stopStatusReconciliation();
      _scheduleReset();
    } else {
      _startStatusReconciliationIfNeeded();
    }
  }

  void _refreshUiPhase({bool? hasActiveRoom}) {
    final nextHasActiveRoom = hasActiveRoom ?? state.hasActiveRoom;

    state = state.copyWith(
      hasActiveRoom: nextHasActiveRoom,
      uiPhase: _deriveUiPhase(
        backendStatus: state.backendStatus,
        direction: state.direction,
        hasActiveRoom: nextHasActiveRoom,
      ),
    );
  }

  UiCallPhase _deriveUiPhase({
    required BackendCallStatus? backendStatus,
    required String? direction,
    required bool hasActiveRoom,
  }) {
    switch (backendStatus) {
      case null:
        return UiCallPhase.idle;

      case BackendCallStatus.initiated:
        return UiCallPhase.outgoingStarting;

      case BackendCallStatus.ringing:
        return direction == 'incoming'
            ? UiCallPhase.incomingRinging
            : UiCallPhase.outgoingRinging;

      case BackendCallStatus.ongoing:
        return hasActiveRoom ? UiCallPhase.inCall : UiCallPhase.joiningRoom;

      case BackendCallStatus.ended:
      case BackendCallStatus.rejected:
      case BackendCallStatus.missed:
      case BackendCallStatus.cancelled:
        return UiCallPhase.finished;

      case BackendCallStatus.failed:
        return UiCallPhase.error;
    }
  }

  bool _isTerminal(BackendCallStatus status) {
    return status == BackendCallStatus.ended ||
        status == BackendCallStatus.rejected ||
        status == BackendCallStatus.missed ||
        status == BackendCallStatus.cancelled ||
        status == BackendCallStatus.failed;
  }

  Future<void> _failCall(Object error) async {
    await _leaveRoomInternal();
    _stopStatusReconciliation();

    state = state.copyWith(
      backendStatus: BackendCallStatus.failed,
      uiPhase: UiCallPhase.error,
      errorMessage: error.toString(),
      isBusy: false,
      hasIncomingCallUi: false,
    );

    _scheduleReset();
  }

  void _scheduleReset() {
    _resetTimer?.cancel();
    if (state.isOutgoingNoAnswer) {
      return;
    }

    final currentCallId = state.activeCall?.id;

    _resetTimer = Timer(const Duration(milliseconds: 900), () {
      if (state.activeCall?.id == currentCallId &&
          state.backendStatus != null &&
          _isTerminal(state.backendStatus!)) {
        _resetToIdle();
      }
    });
  }

  Future<bool> callAgainAfterNoAnswer() async {
    final call = state.activeCall;
    final receiver = state.receiver ?? call?.receiver;
    final callType =
        call?.callType ??
        (state.callMediaMode == CallMediaMode.video
            ? AOSCallType.video
            : AOSCallType.audio);
    final userId = receiver?.userId.trim();

    if (userId == null || userId.isEmpty) {
      return false;
    }

    return startOutgoingCall(
      userId: userId,
      callType: callType,
      receiver: receiver,
    );
  }

  void resetToIdle() {
    _resetToIdle();
  }

  void _resetToIdle() {
    callTimer.stop();
    _stopStatusReconciliation();

    _localTerminalCallIds.clear();
    _callActionLocks.clear();
    _callCancelled = false;

    state = state.copyWith(
      uiPhase: UiCallPhase.idle,
      clearBackendStatus: true,
      activeCallBuilder: () => null,
      callerBuilder: () => null,
      receiverBuilder: () => null,
      isMuted: false,
      isSpeakerOn: false,
      isUpgradePending: false,
      videoUpgradeStatus: 'none',
      clearVideoUpgradeRequestedBy: true,
      hasIncomingVideoUpgradeRequest: false,
      clearVideoUpgradeErrorMessage: true,
      isRemoteVideoEnabled: true,
      isLocalVideoEnabled: false,
      duration: Duration.zero,
      clearErrorMessage: true,
      isBusy: false,
      hasIncomingCallUi: false,
      hasActiveRoom: false,
      clearDirection: true,
      clearRoomName: true,
      clearToken: true,
      clearWsUrl: true,
    );
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    _resetTimer?.cancel();
    _stopStatusReconciliation();
    unawaited(_durationSub?.cancel());
    callTimer.dispose();
    super.dispose();
  }
}
