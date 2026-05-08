import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';

import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

class CallKitParamsMapper {
  const CallKitParamsMapper();

  CallKitParams incoming({
    required String callId,
    required AOSCallType callType,
    CallParticipant? caller,
    String? roomName,
  }) {
    final isVideo = callType == AOSCallType.video;

    final callerName = caller?.displayName.trim().isNotEmpty == true
        ? caller!.displayName
        : caller?.userId ?? 'AOS User';

    return CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'AOS',
      handle: isVideo ? 'Incoming Video Call' : 'Incoming Call',
      type: isVideo ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: {
        'call_id': callId,
        'call_type': isVideo ? 'video' : 'audio',
        if (roomName != null && roomName.isNotEmpty) 'room_name': roomName,
        if (caller != null) 'caller': caller.userId,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955FA',
        actionColor: '#4CAF50',
        textColor: '#FFFFFF',
      ),
      ios: const IOSParams(
        supportsVideo: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );
  }
}
