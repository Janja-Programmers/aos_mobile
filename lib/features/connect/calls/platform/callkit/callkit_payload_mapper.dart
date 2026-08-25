import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:uuid/uuid.dart';

class CallKitPayloadMapper {
  const CallKitPayloadMapper();

  CallKitParams fromPushData(Map<String, dynamic> data) {
    final callId = _clean(data['call_id'] ?? data['id']);
    if (callId == null) {
      throw ArgumentError('Missing call_id');
    }

    final callkitUuid = _resolveCallkitUuid(data, fallbackSeed: callId);

    final callerName =
        _clean(data['caller_display_name']) ??
        _clean(data['caller_name']) ??
        _clean(data['caller']) ??
        'AOS User';

    final callerAvatar = normalizeMediaUrl(
      _clean(data['caller_avatar']) ??
          _clean(data['avatar']) ??
          _clean(data['avatar_url']),
    );

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
      textAccept: 'Accept',
      textDecline: 'Decline',
      // Persistent missed-call notifications are owned by the backend. The
      // plugin must not create a second callback notification after timeout.
      missedCallNotification: const NotificationParams(
        showNotification: false,
        isShowCallback: false,
      ),
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
        // Play policy: AOS uses the incoming-call notification surface
        // rather than privileged full-screen intent.
        isShowFullLockedScreen: false,
        isImportant: true,
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

  String _resolveCallkitUuid(
    Map<String, dynamic> data, {
    required String fallbackSeed,
  }) {
    final explicit =
        _clean(data['callkit_uuid']) ??
        _clean(data['callkit_id']) ??
        _clean(data['uuid']);

    if (explicit != null && _looksLikeUuid(explicit)) {
      return explicit;
    }

    if (_looksLikeUuid(fallbackSeed)) {
      return fallbackSeed;
    }

    return const Uuid().v4();
  }

  bool _looksLikeUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value.trim());
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
