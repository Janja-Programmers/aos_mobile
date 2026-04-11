import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/calls/domain/call_participant.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/calls/application/services/livekit_service.dart';
import 'package:africaonlinestores/features/calls/application/services/livekit_track_events.dart';
import 'package:africaonlinestores/features/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/calls/domain/call.dart';
import 'package:africaonlinestores/features/calls/repository/call_repository_impl.dart';
import 'package:africaonlinestores/features/calls/utils/call_logger.dart';
import 'package:africaonlinestores/features/calls/utils/call_timer.dart';

class CallManager extends StateNotifier<CallState> {
  final CallRepository repository;
  final LiveKitService liveKitService;
  final CallTimer callTimer;

  bool _isJoining = false;
  bool _isLeaving = false;

  StreamSubscription? _trackSub;

  CallManager({
    required this.repository,
    required this.liveKitService,
    required this.callTimer,
  }) : super(CallState.initial()) {
    _listenToTracks();
  }

  // ================= TRACK EVENTS =================
  void _listenToTracks() {
    _trackSub = liveKitService.trackEvents.listen((event) {
      if (event is RemoteVideoTrackEvent) {
        state = state.copyWith(isRemoteVideoEnabled: true);
      }

      if (event is RemoteVideoRemovedEvent) {
        state = state.copyWith(isRemoteVideoEnabled: false);
      }

      if (event is LocalVideoTrackEvent) {
        state = state.copyWith(isLocalVideoEnabled: true);
      }

      if (event is LocalVideoRemovedEvent) {
        state = state.copyWith(isLocalVideoEnabled: false);
      }

      if (event is TrackClearedEvent) {
        state = state.copyWith(
          isRemoteVideoEnabled: false,
          isLocalVideoEnabled: false,
        );
      }
    });
  }

  // ================= OUTGOING =================
  Future<bool> startOutgoingCall({
    required String userId,
    required AOSCallType callType,
  }) async {
    try {
      if (state.hasActiveCall ||
          state.status == CallStatus.dialing ||
          state.status == CallStatus.ringing ||
          state.status == CallStatus.connecting ||
          state.status == CallStatus.incoming) {
        appLogger.i('❌ Call already in progress');
        return false;
      }

      state = state.copyWith(
        status: CallStatus.dialing,
        isBusy: true,
        direction: 'outgoing',
      );

      final conversationId = await repository.openConversation(userId: userId);

      final call = await repository.initiateCall(
        conversationId: conversationId,
        callType: callType,
      );

      state = state.copyWith(
        activeCall: call,
        status: CallStatus.ringing,
        isBusy: false,
        direction: 'outgoing',
      );

      await _joinRoomInternal(call);

      appLogger.i('📞 Dialing...');
      return true;
    } catch (e, s) {
      appLogger.e('startOutgoingCall failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: CallStatus.failed,
        errorMessage: e.toString(),
        isBusy: false,
      );

      return false;
    }
  }

  // ================= INCOMING =================
  Future<void> onIncomingCallEvent({
    required String callId,
    required String roomName,
    required AOSCallType callType,
    CallParticipant? caller,
  }) async {
    if (state.hasActiveCall) {
      appLogger.i('⚠️ Rejecting incoming (busy)');
      return;
    }

    state = state.copyWith(
      status: CallStatus.incoming,
      hasIncomingCallUi: true,
      direction: 'incoming',
      caller: caller,
      activeCall: Call(
        id: callId,
        conversationId: '',
        callType: callType,
        roomName: roomName,
        token: '',
        wsUrl: '',
        caller: caller,
      ),
    );
  }

  Future<void> acceptIncomingCall() async {
    try {
      final callId = state.activeCall?.id;

      if (callId == null) return;

      state = state.copyWith(
        status: CallStatus.connecting,
        hasIncomingCallUi: false,
      );

      final call = await repository.acceptCall(callId: callId);

      state = state.copyWith(activeCall: call);

      await _joinRoomInternal(call);
    } catch (e, s) {
      appLogger.e('acceptIncomingCall failed', error: e, stackTrace: s);
    }
  }

  Future<void> rejectIncomingCall() async {
    try {
      appLogger.i(
        "📵 rejectIncomingCall BEFORE mutation | Status: ${state.status.toString()}",
      );

      final callId = state.activeCall?.id;
      if (callId == null) return;

      await repository.rejectCall(callId: callId);

      state = state.copyWith(
        status: CallStatus.rejected,
        hasIncomingCallUi: false,
      );

      appLogger.i(
        "📵 rejectIncomingCall Completed | Status: ${state.status.toString()}",
      );
    } catch (e) {
      appLogger.e('rejectIncomingCall failed', error: e);
    }
  }

  Future<void> onCallNotAnswered({required String callId}) async {
    try {
      appLogger.i(
        "📵 CallManager BEFORE mutation | Status: ${state.status.toString()}",
      );

      state = state.copyWith(
        status: CallStatus.notAnswered,
        hasIncomingCallUi: false,
      );

      appLogger.i(
        "CallManager: CallNotAnswered Mutation | Status: ${state.status.toString()}",
      );
    } catch (e) {
      appLogger.e('onCallNotAnswered failed', error: e);
    }
  }

  // ================= SOCKET EVENTS =================
  Future<void> onCallAcceptedEvent({
    required String callId,
    required String token,
    required String wsUrl,
  }) async {
    final call = state.activeCall;
    if (call == null) return;

    final updatedCall = call.copyWith(token: token, wsUrl: wsUrl);

    state = state.copyWith(
      activeCall: updatedCall,
      status: CallStatus.connecting,
    );

    await _joinRoomInternal(updatedCall);
  }

  Future<void> onCallRejectedEvent({required String callId}) async {
    state = state.copyWith(status: CallStatus.rejected);
  }

  Future<void> onCallEndedEvent({required String callId}) async {
    if (state.activeCall?.id != callId) return;

    appLogger.i('📡 Remote ended call → leaving locally');

    // ✅ ONLY leave room locally
    await _leaveRoomInternal();

    // ✅ update state
    state = state.copyWith(
      status: CallStatus.ended,
      activeCall: null,
      isBusy: false,
    );

    appLogger.i('🏁 Call ended via remote event');
  }

  // ================= ROOM =================
  Future<void> _joinRoomInternal(Call call) async {
    if (_isJoining) return;
    _isJoining = true;

    try {
      await liveKitService.connect(
        wsUrl: call.wsUrl,
        token: call.token,
        isVideo: call.callType == AOSCallType.video,
      );

      callTimer.start();

      state = state.copyWith(status: CallStatus.connected, hasActiveRoom: true);

      CallLogger.room('🎥 Joined room');
    } catch (e, s) {
      appLogger.e('joinRoom failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: CallStatus.failed,
        errorMessage: e.toString(),
      );
    } finally {
      _isJoining = false;
    }
  }

  Future<void> _leaveRoomInternal() async {
    if (_isLeaving) return;
    _isLeaving = true;

    try {
      await liveKitService.disconnect();
      callTimer.stop();

      state = state.copyWith(
        hasActiveRoom: false,
        isRemoteVideoEnabled: false,
        isLocalVideoEnabled: false,
      );

      CallLogger.room('👋 Left room');
    } finally {
      _isLeaving = false;
    }
  }

  // ================= END =================
  Future<void> endCurrentCall() async {
    appLogger.i('🔚 Attempting to end call');

    try {
      final callId = state.activeCall?.id;

      if (callId != null) {
        appLogger.i('📡 Ending call on backend → $callId');

        await repository.endCall(callId: callId);

        appLogger.i('✅ Backend call ended → $callId');
      } else {
        appLogger.i('⚠️ No callId → cancelling locally (outgoing)');
      }

      await _leaveRoomInternal();

      state = state.copyWith(
        status: CallStatus.ended,
        activeCall: null,
        isBusy: false,
      );

      appLogger.i('🏁 Call fully terminated');
    } catch (e, s) {
      appLogger.e('❌ endCurrentCall failed', error: e, stackTrace: s);
    }
  }

  // ================= CONTROLS =================
  Future<void> toggleMute() async {
    final next = !state.isMuted;
    await liveKitService.toggleMicrophone(!next);

    state = state.copyWith(isMuted: next);
  }

  Future<void> toggleSpeaker() async {
    final next = !state.isSpeakerOn;
    await liveKitService.switchSpeaker(next);

    state = state.copyWith(isSpeakerOn: next);
  }

  Future<void> toggleVideo() async {
    final next = !state.isVideoEnabled;
    await liveKitService.toggleCamera(next);

    state = state.copyWith(isVideoEnabled: next);
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    _trackSub?.cancel();
    callTimer.dispose();
    liveKitService.dispose();
    super.dispose();
  }
}
