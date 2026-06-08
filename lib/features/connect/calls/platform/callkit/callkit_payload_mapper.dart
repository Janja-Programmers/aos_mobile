import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';

class CallKitPayloadMapper {
  const CallKitPayloadMapper();

  CallKitParams fromPushData(Map<String, dynamic> data) {
    final callId = _clean(data['call_id'] ?? data['id']);
    final callkitUuid = _clean(data['callkit_uuid']) ?? callId;

    if (callId == null || callkitUuid == null) {
      throw ArgumentError('Missing call_id/callkit_uuid');
    }

    final callerName =
        _clean(data['caller_display_name']) ??
        _clean(data['caller_name']) ??
        _clean(data['caller']) ??
        'AOS User';

    final callerAvatar =
        _clean(data['caller_avatar']) ??
        _clean(data['avatar']) ??
        _clean(data['avatar_url']);

    final callType = _clean(data['call_type'])?.toLowerCase();
    final isVideo = callType == 'video';

    final roomName = _clean(data['room_name']);

    return CallKitParams(
      id: callkitUuid,
      nameCaller: callerName,
      appName: 'Africa Online Stores',
      avatar: callerAvatar,
      handle: isVideo ? 'Incoming video call' : 'Incoming voice call',
      type: isVideo ? 1 : 0,
      duration: 30000,
      textAccept: 'Answer',
      textDecline: 'Reject',
      extra: {
        ...data,
        'call_id': callId,
        'callkit_uuid': callkitUuid,
        'call_type': isVideo ? 'video' : 'audio',
        'caller_display_name': callerName,
        'caller_avatar': callerAvatar,
        'room_name': roomName,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        isShowCallID: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FFFFFF',
        textColor: '#111111',
        actionColor: '#16A34A',
        incomingCallNotificationChannelName: 'AOS Calls',
        missedCallNotificationChannelName: 'Missed Calls',
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: isVideo,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        configureAudioSession: false,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
