import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

class CallSignalingHandler {
  final CallManager callManager;

  const CallSignalingHandler({required this.callManager});

  // ================= INCOMING =================
  Future<bool> handleIncomingCall(Map<String, dynamic> data) async {
    try {
      final callId = _cleanString(data['call_id']) ?? _cleanString(data['id']);
      final roomName = _cleanString(data['room_name']);
      final callTypeRaw = _cleanString(data['call_type']);

      final callerUser = _cleanString(data['caller']);
      final callerDisplayName = _cleanString(data['caller_display_name']);
      final callerAvatar = _cleanString(data['caller_avatar']);

      if (callId == null || roomName == null || callTypeRaw == null) {
        return false;
      }

      final callType = callTypeRaw == 'video'
          ? AOSCallType.video
          : AOSCallType.audio;

      final caller = callerUser == null
          ? null
          : CallParticipant(
              userId: callerUser,
              displayName: callerDisplayName ?? callerUser,
              avatarUrl: callerAvatar,
            );

      return callManager.onIncomingCallEvent(
        callId: callId,
        roomName: roomName,
        callType: callType,
        caller: caller,
      );
    } catch (_) {
      return false;
    }
  }

  // ================= ACCEPTED =================
  Future<void> handleCallAccepted(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;
      if (callId == null) {
        return;
      }

      await callManager.onCallAcceptedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= REJECTED =================
  Future<void> handleCallRejected(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        return;
      }

      await callManager.onCallRejectedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= ENDED =================
  Future<void> handleCallEnded(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        return;
      }

      await callManager.onCallEndedEvent(callId: callId);
    } catch (_) {}
  }

  // ================= HANDLECALLNOTANSWERED =================
  Future<void> handleCallNotAnswered(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        return;
      }

      await callManager.onCallNotAnswered(callId: callId);
    } catch (_) {}
  }

  // ================= CANCELLED =================
  Future<void> handleCallCancelled(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        return;
      }

      await callManager.onCallCancelledEvent(callId: callId);
    } catch (_) {}
  }

  // ================= HELPERS =================

  String? _cleanString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
