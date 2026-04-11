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

    default:
      return RealtimeEventType.unknown;
  }
}
