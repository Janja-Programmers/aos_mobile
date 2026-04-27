enum CallMediaMode { audio, video }

enum BackendCallStatus {
  initiated,
  ringing,
  ongoing,
  ended,
  rejected,
  missed,
  cancelled,
  failed,
}

enum UiCallPhase {
  idle,
  outgoingStarting,
  outgoingRinging,
  incomingRinging,
  joiningRoom,
  inCall,
  finished,
  cancelled,
  error,
}
