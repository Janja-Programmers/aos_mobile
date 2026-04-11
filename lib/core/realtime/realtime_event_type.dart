enum RealtimeEventType {
  // Chat
  chatNewMessage,
  chatTyping,

  // Presence
  presenceUpdate,

  // Calls
  aosIncomingCall,
  aosCallAccepted,
  aosCallRejected,
  aosCallEnded,
  aosCallNotAnswered,

  // LIVE Events
  aosLiveStarted,
  aosLiveEnded,
  aosLiveViewerCount,

  // Unknown
  unknown,
}

RealtimeEventType mapRealtimeEvent(String event) {
  switch (event) {
    case "aos_new_message":
      return RealtimeEventType.chatNewMessage;

    case "aos_typing":
      return RealtimeEventType.chatTyping;

    case "aos_presence_update":
      return RealtimeEventType.presenceUpdate;

    case "aos_incoming_call":
      return RealtimeEventType.aosIncomingCall;

    case "aos_call_accepted":
      return RealtimeEventType.aosCallAccepted;

    case "aos_call_rejected":
      return RealtimeEventType.aosCallRejected;

    case "aos_call_ended":
      return RealtimeEventType.aosCallEnded;

    case "aos_call_not_answered":
      return RealtimeEventType.aosCallNotAnswered;

    // LIVE Mapping
    case "aos_live_started":
      return RealtimeEventType.aosLiveStarted;

    case "aos_live_ended":
      return RealtimeEventType.aosLiveEnded;

    case "aos_live_viewer_count":
      return RealtimeEventType.aosLiveViewerCount;

    default:
      return RealtimeEventType.unknown;
  }
}
