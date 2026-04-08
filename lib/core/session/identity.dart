// core/session/identity.dart

import 'package:africaonlinestores/shared/user/user.dart';

/// Base identity type
sealed class Identity {
  const Identity();

  bool get isGuest => this is GuestIdentity;
  bool get isAuthenticated => this is AuthenticatedIdentity;
}

/// Guest (anonymous user)
class GuestIdentity extends Identity {
  final String? sessionId; // optional (for analytics, tracking)

  const GuestIdentity({this.sessionId});
}

/// Authenticated user identity
class AuthenticatedIdentity extends Identity {
  final User user;

  const AuthenticatedIdentity(this.user);
}
