class AuthUser {
  AuthUser({required this.email, required this.fullName, this.userImage = ''});

  final String email;
  final String fullName;
  final String userImage;

  factory AuthUser.fromMap(Map<String, dynamic> m) {
    return AuthUser(
      email: (m['email'] ?? '').toString(),
      fullName: (m['full_name'] ?? '').toString(),
      userImage: (m['user_image'] ?? '').toString(),
    );
  }
}

class AuthState {
  const AuthState({
    required this.initializing,
    required this.isLoggedIn,
    this.sid,
    this.user,
    this.errorMessage,
  });

  final bool initializing;
  final bool isLoggedIn;
  final String? sid;
  final AuthUser? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null && sid != null;
  bool get isGuest => !isAuthenticated;

  factory AuthState.initial() =>
      const AuthState(initializing: true, isLoggedIn: false);

  AuthState loggedOut() {
    return const AuthState(initializing: false, isLoggedIn: false);
  }

  AuthState copyWith({
    bool? initializing,
    bool? isLoggedIn,
    String? sid,
    bool clearSid = false,
    AuthUser? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      initializing: initializing ?? this.initializing,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      sid: clearSid ? null : (sid ?? this.sid),
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
