class AuthUser {
  AuthUser({required this.email, required this.fullName, this.userImage = '', this.bio});

  final String email;
  final String fullName;
  final String userImage;
  final String? bio;

  factory AuthUser.fromMap(Map<String, dynamic> m) {
    return AuthUser(
      email: (m['email'] ?? '').toString(),
      fullName: (m['full_name'] ?? '').toString(),
      userImage: (m['user_image'] ?? '').toString(),
      bio: (m['bio'] ?? '').toString(),
    );
  }
}

sealed class AuthState {
  const AuthState();

  bool get isLoading => this is AuthLoading;
  bool get isGuest => this is AuthGuest;
  bool get isAuthenticated => this is AuthAuthenticated;

  AuthAuthenticated? get asAuthenticated =>
      this is AuthAuthenticated ? this as AuthAuthenticated : null;
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final String sid;

  const AuthAuthenticated({required this.user, required this.sid});

  AuthAuthenticated copyWith({AuthUser? user}) {
    return AuthAuthenticated(user: user ?? this.user, sid: sid);
  }
}
