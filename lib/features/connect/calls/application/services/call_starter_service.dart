import 'package:africaonlinestores/core/utils/logger.dart';
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
      appLogger.w('📞 Outgoing call ignored: receiver ID is empty');
      return false;
    }

    appLogger.i(
      '📞 CallStarterService start requested '
      '(receiver=$trimmedUserId, type=${callType.name})',
    );

    final started = await callManager.startOutgoingCall(
      userId: trimmedUserId,
      callType: callType,
      receiver: receiver,
    );

    if (!started) {
      appLogger.w('📞 CallManager did not start the outgoing call');
      return false;
    }

    final call = callManager.currentState.activeCall;

    if (call == null || call.id.trim().isEmpty) {
      appLogger.e(
        '📞 Outgoing call started without a canonical backend call ID',
      );
      return false;
    }

    final callkitUuid = await callKitService.registerOutgoingCall(
      callId: call.id,
      callType: call.callType,
      receiver: call.receiver ?? callManager.currentState.receiver ?? receiver,
    );

    if (callkitUuid == null) {
      appLogger.e(
        '📞 Native outgoing-call registration failed (callId=${call.id})',
      );
      await callManager.endCurrentCall(expectedCallId: call.id);
      return false;
    }

    appLogger.i('📞 Outgoing call initialized end-to-end (callId=${call.id})');
    return true;
  }
}
