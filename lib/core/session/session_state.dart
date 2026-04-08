enum AuthStatus { guest, restoring, authenticated, expired }

class SessionState {
  final AuthStatus status;
  final String? sid;
  // final User? user;
  final bool initializing;

  const SessionState({
    required this.status,
    this.sid,
    // this.user,
    this.initializing = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isRestoring => status == AuthStatus.restoring;
}
