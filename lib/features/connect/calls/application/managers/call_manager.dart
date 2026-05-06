import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/connect/calls/application/services/call_media_service.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/repository/call_repository_impl.dart';
import 'package:africaonlinestores/features/connect/calls/utils/call_timer.dart';

class CallManager extends StateNotifier<CallState> {
  final CallRepository repository;
  final CallMediaService mediaService;
  final CallTimer callTimer;

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

  // ================= OUTGOING =================
  Future<bool> startOutgoingCall({
    required String userId,
    required AOSCallType callType,
    CallParticipant? receiver,
  }) async {
    try {
      if (userId.trim().isEmpty) {
        return false;
      }

      _callCancelled = false;

      state = state.copyWith(
        isBusy: true,
        direction: 'outgoing',
        clearErrorMessage: true,
      );

      final conversationId = await repository.openConversation(userId: userId);

      final initiatedCall = await repository.initiateCall(
        conversationId: conversationId,
        callType: callType,
      );

      state = state.copyWith(
        callMediaMode: callType == AOSCallType.video
            ? CallMediaMode.video
            : CallMediaMode.audio,
      );

      /// ✅ Correct order
      _applyBackendState(
        BackendCallStatus.initiated,
        activeCall: initiatedCall,
        direction: 'outgoing',
        receiver:
            receiver ??
            CallParticipant(
              userId: userId,
              displayName: userId,
              avatarUrl: null,
            ),
      );

      if (_callCancelled) return false;

      await _joinRoomInternal(initiatedCall);

      if (_callCancelled) {
        return false;
      }

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
        activeCall: incomingCall,
        direction: 'incoming',
        caller: caller,
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
        activeCall: incomingCall,
        direction: 'incoming',
        caller: caller,
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

      _applyBackendState(BackendCallStatus.missed, hasIncomingCallUi: false);
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
      await _leaveRoomInternal();

      _applyBackendState(BackendCallStatus.missed, hasIncomingCallUi: false);
    } catch (e) {
      await _failCall(e);
    }
  }

  // ================= SOCKET EVENTS =================
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
        room: null,
        isRemoteVideoEnabled: false,
        isLocalVideoEnabled: false,
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
    // Audio → simulate upgrade
    if (state.callMediaMode == CallMediaMode.audio) {
      state = state.copyWith(isUpgradePending: true);

      // 🔥 simulate delay
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        callMediaMode: CallMediaMode.video,
        isUpgradePending: false,
        isLocalVideoEnabled: true,
      );

      await mediaService.toggleCamera(true);
      return;
    }

    // Video → toggle camera
    final newValue = !state.isLocalVideoEnabled;

    state = state.copyWith(isLocalVideoEnabled: newValue);

    await mediaService.toggleCamera(newValue);
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

    state = state.copyWith(
      backendStatus: nextStatus,
      activeCall: activeCall,
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

    final currentCallId = state.activeCall?.id;

    _resetTimer = Timer(const Duration(milliseconds: 900), () {
      if (state.activeCall?.id == currentCallId &&
          state.backendStatus != null &&
          _isTerminal(state.backendStatus!)) {
        _resetToIdle();
      }
    });
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
      backendStatus: null,
      room: null,
      activeCallBuilder: () => null,
      callerBuilder: () => null,
      receiverBuilder: () => null,
      isMuted: false,
      isSpeakerOn: false,
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
    _durationSub?.cancel();
    callTimer.dispose();
    super.dispose();
  }
}
