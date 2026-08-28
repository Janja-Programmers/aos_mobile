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

enum IncomingCallHydrationOutcome { hydrated, terminal, unavailable, conflict }

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
