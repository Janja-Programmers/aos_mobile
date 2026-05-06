import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

class CallSignalingHandler {
  final CallManager callManager;

  const CallSignalingHandler({required this.callManager});

  // ================= INCOMING =================
  Future<bool> handleIncomingCall(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;
      final callerRaw = data['caller'] as String?;
      final callerNameRaw = data['caller_name'] as String?;
      final callerAvatarRaw = data['caller_avatar'] as String?;
      final roomName = data['room_name'] as String?;
      final callTypeRaw = data['call_type'] as String?;

      if (callId == null || roomName == null || callTypeRaw == null) {
        return false;
      }

      final callType = callTypeRaw == 'video'
          ? AOSCallType.video
          : AOSCallType.audio;

      final caller = callerRaw != null
          ? CallParticipant(
              userId: callerRaw,
              displayName: _safeDisplayName(
                callerNameRaw: callerNameRaw,
                fallback: callerRaw,
              ),
              avatarUrl: _safeNullableString(callerAvatarRaw),
            )
          : null;

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

  String _safeDisplayName({
    required String? callerNameRaw,
    required String fallback,
  }) {
    final name = callerNameRaw?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return _emailToReadableName(fallback);
  }

  String _emailToReadableName(String value) {
    if (!value.contains('@')) return value;

    final localPart = value.split('@').first.trim();

    if (localPart.isEmpty) return value;

    return localPart
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
  }

  String? _safeNullableString(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
