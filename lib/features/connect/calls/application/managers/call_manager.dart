import 'dart:async';

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

  CallState get currentState => state;
  final Set<String> _localTerminalCallIds = <String>{};

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
      conversationId: '',
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

    if (state.activeCall?.id == normalizedCallId) {
      return true;
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
    if (!_matchesActiveCall(expectedCallId)) {
      return;
    }

    final call = state.activeCall;
    if (call == null) {
      return;
    }

    if (state.uiPhase != UiCallPhase.incomingRinging) {
      return;
    }

    if (_isTerminalStatus(state.backendStatus)) {
      return;
    }

    try {
      final callId = state.activeCall?.id;

      if (callId == null) return;
      if (state.backendStatus != BackendCallStatus.ringing) return;
      if (state.isBusy) return;

      state = state.copyWith(isBusy: true);

      final ongoingCall = await repository.acceptCall(callId: callId);

      _applyBackendState(
        BackendCallStatus.ongoing,
        activeCall: ongoingCall,
        direction: 'incoming',
        hasIncomingCallUi: false,
      );

      await _joinRoomInternal(ongoingCall);

      state = state.copyWith(isBusy: false);
    } catch (e) {
      state = state.copyWith(isBusy: false);

      final failedCallId = state.activeCall?.id;
      final synced =
          !(failedCallId == null) &&
          await _applyBackendStatusIfTerminal(
            callId: failedCallId,
            hasIncomingCallUi: false,
          );

      if (!synced) {
        await _failCall(e);
      }
    }
  }

  Future<void> rejectIncomingCall({String? expectedCallId}) async {
    if (!_matchesActiveCall(expectedCallId)) {
      return;
    }

    final call = state.activeCall;
    if (call == null) {
      return;
    }

    if (state.uiPhase != UiCallPhase.incomingRinging) {
      return;
    }

    if (_isTerminalStatus(state.backendStatus)) {
      return;
    }

    try {
      final callId = state.activeCall?.id;
      if (callId == null) return;

      await repository.rejectCall(callId: callId);
      await _leaveRoomInternal();

      _applyBackendState(BackendCallStatus.rejected, hasIncomingCallUi: false);
    } catch (e) {
      await _failCall(e);
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

  Future<BackendCallStatus?> _readBackendStatus(String callId) async {
    try {
      final status = await repository.getCallStatus(callId: callId);
      return _parseBackendStatus(status['status']);
    } catch (_) {
      return null;
    }
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
      avatarUrl: _cleanString(avatar),
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
    // ✅ Optional duplicate guard
    if (state.backendStatus == nextStatus &&
        (activeCall == null || state.activeCall?.id == activeCall.id)) {
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
      _scheduleReset();
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

    _localTerminalCallIds.clear();
    _callCancelled = false;

    state = state.copyWith(
      uiPhase: UiCallPhase.idle,
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
      isLocalVideoEnabled: true,
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
    unawaited(_durationSub?.cancel());
    callTimer.dispose();
    super.dispose();
  }
}
