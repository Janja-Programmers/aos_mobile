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

    final callerUserId = _cleanString(caller?.userId);
    final callerName =
        _cleanString(caller?.displayName) ?? callerUserId ?? 'AOS User';

    final callerAvatar = _cleanString(caller?.avatarUrl);

    final callLabel = isVideo ? 'Incoming video call' : 'Incoming audio call';

    return CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Africa Online Stores',
      handle: callLabel,
      avatar: callerAvatar,
      type: isVideo ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: null,
      extra: {
        'call_id': callId,
        'call_type': isVideo ? 'video' : 'audio',
        'caller_display_name': callerName,
        'caller': ?callerUserId,
        'caller_avatar': ?callerAvatar,
        if (_cleanString(roomName) != null) 'room_name': roomName!.trim(),
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',

        // White UI / black text
        backgroundColor: '#FFFFFF',
        textColor: '#111111',

        // Accept action color
        actionColor: '#16A34A',
      ),
      ios: const IOSParams(
        supportsVideo: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );
  }

  String? _cleanString(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
