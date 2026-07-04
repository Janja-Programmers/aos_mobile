import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

class CallSignalingHandler {
  final CallManager callManager;

  const CallSignalingHandler({required this.callManager});

  // ================= INCOMING =================
  Future<bool> handleIncomingCall(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);
      final roomName = _cleanString(data['room_name']);
      final callTypeRaw = _cleanString(data['call_type']);
      final token = _cleanString(data['token']);
      final wsUrl = _cleanString(data['ws_url']);
      final conversationId =
          _cleanString(data['conversation_id']) ??
          _cleanString(data['conversation']);

      final callerUser = _cleanString(data['caller']);
      final callerDisplayName = _cleanString(data['caller_display_name']);
      final callerAvatar = _cleanString(data['caller_avatar']);

      final receiverUser = _cleanString(data['receiver']);
      final receiverDisplayName = _cleanString(data['receiver_display_name']);
      final receiverAvatar = _cleanString(data['receiver_avatar']);

      if (callId == null || roomName == null || callTypeRaw == null) {
        return false;
      }

      final callType = callTypeRaw.toLowerCase() == 'video'
          ? AOSCallType.video
          : AOSCallType.audio;

      final caller = callerUser == null
          ? null
          : CallParticipant(
              userId: callerUser,
              displayName: callerDisplayName ?? callerUser,
              avatarUrl: normalizeMediaUrl(callerAvatar),
            );

      final receiver = receiverUser == null
          ? null
          : CallParticipant(
              userId: receiverUser,
              displayName: receiverDisplayName ?? receiverUser,
              avatarUrl: normalizeMediaUrl(receiverAvatar),
            );

      return callManager.onIncomingCallEvent(
        callId: callId,
        roomName: roomName,
        conversationId: conversationId,
        callType: callType,
        token: token,
        wsUrl: wsUrl,
        caller: caller,
        receiver: receiver,
      );
    } catch (_) {
      return false;
    }
  }

  // ================= RINGING =================
  Future<void> handleCallRinging(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onCallRingingEvent(callId: callId);
    } catch (_) {}
  }

  // ================= ACCEPTED =================
  Future<void> handleCallAccepted(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);
      if (callId == null) {
        return;
      }

      await callManager.onCallAcceptedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= REJECTED =================
  Future<void> handleCallRejected(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onCallRejectedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= ENDED =================
  Future<void> handleCallEnded(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onCallEndedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= HANDLECALLNOTANSWERED =================
  Future<void> handleCallNotAnswered(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onCallNotAnswered(callId: callId);
    } catch (_) {}
  }

  // ================= CANCELLED =================
  Future<void> handleCallCancelled(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onCallCancelledEvent(callId: callId);
    } catch (_) {}
  }

  // ================= VIDEO UPGRADE REQUESTED =================
  Future<void> handleVideoUpgradeRequested(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);
      final requestedBy =
          _cleanString(data['video_upgrade_requested_by']) ??
          _cleanString(data['requested_by']) ??
          _cleanString(data['actor']) ??
          _cleanString(data['from_user']) ??
          _cleanString(data['user']);

      if (callId == null) {
        return;
      }

      await callManager.onVideoUpgradeRequestedEvent(
        callId: callId,
        requestedBy: requestedBy,
      );
    } catch (_) {}
  }

  // ================= VIDEO UPGRADE ACCEPTED =================
  Future<void> handleVideoUpgradeAccepted(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onVideoUpgradeAcceptedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= VIDEO UPGRADE DECLINED =================
  Future<void> handleVideoUpgradeDeclined(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onVideoUpgradeDeclinedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= VIDEO UPGRADE CANCELLED =================
  Future<void> handleVideoUpgradeCancelled(Map<String, dynamic> data) async {
    try {
      final callId = _extractCallId(data);

      if (callId == null) {
        return;
      }

      await callManager.onVideoUpgradeCancelledEvent(callId: callId);
    } catch (_) {}
  }

  // ================= HELPERS =================

  String? _extractCallId(Map<String, dynamic> data) {
    return _cleanString(data['call_id']) ??
        _cleanString(data['id']) ??
        _cleanString(data['callId']) ??
        _cleanString(data['callID']);
  }

  String? _cleanString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
