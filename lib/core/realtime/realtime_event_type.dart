enum RealtimeEventType {
  // Chat
  chatNewMessage,
  chatTyping,

  // Presence
  presenceUpdate,

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

    default:
      return RealtimeEventType.unknown;
  }
}
