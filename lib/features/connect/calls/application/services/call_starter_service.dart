import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_service.dart';

class CallStarterService {
  final CallManager callManager;
  final CallKitService callKitService;

  const CallStarterService({
    required this.callManager,
    required this.callKitService,
  });

  Future<bool> startOutgoingCall({
    required String userId,
    required AOSCallType callType,
    CallParticipant? receiver,
  }) async {
    final trimmedUserId = userId.trim();

    if (trimmedUserId.isEmpty) {
      return false;
    }

    final started = await callManager.startOutgoingCall(
      userId: trimmedUserId,
      callType: callType,
      receiver: receiver,
    );

    if (!started) {
      return false;
    }

    final call = callManager.currentState.activeCall;

    if (call == null || call.id.trim().isEmpty) {
      return false;
    }

    final callkitUuid = await callKitService.registerOutgoingCall(
      callId: call.id,
      callType: call.callType,
      receiver: call.receiver ?? callManager.currentState.receiver ?? receiver,
    );

    if (callkitUuid == null) {
      await callManager.endCurrentCall(expectedCallId: call.id);
      return false;
    }

    return true;
  }
}
