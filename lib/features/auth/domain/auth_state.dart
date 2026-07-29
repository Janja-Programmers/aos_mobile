import 'package:africaonlinestores/core/utils/json_utils.dart';

class AuthUser {
  AuthUser({
    required this.email,
    required this.fullName,
    this.userImage = '',
    this.bio,
    this.isVerified = false,
  });

  final String email;
  final String fullName;
  final String userImage;
  final String? bio;
  final bool isVerified;

  factory AuthUser.fromMap(Map<String, dynamic> m) {
    return AuthUser(
      email: (m['email'] ?? m['id'] ?? '').toString(),
      fullName: (m['full_name'] ?? '').toString(),
      userImage: (m['user_image'] ?? '').toString(),
      bio: (m['bio'] ?? '').toString(),
      isVerified:
          _bool(m['is_verified']) ||
          _bool(m['identity_verified']) ||
          _bool(m['is_identity_verified']) ||
          _bool(m['verified']),
    );
  }

  static bool _bool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    final clean = value.toString().trim().toLowerCase();
    return clean == '1' ||
        clean == 'true' ||
        clean == 'yes' ||
        clean == 'approved';
  }
}

class AuthSellerSummary {
  const AuthSellerSummary({required this.isSeller, this.sellerId, this.status});

  final bool isSeller;
  final String? sellerId;
  final String? status;

  factory AuthSellerSummary.fromMap(Map<String, dynamic> map) {
    return AuthSellerSummary(
      isSeller: asBool(map['is_seller']),
      sellerId: asNullableString(map['seller_id']),
      status: asNullableString(map['status']),
    );
  }

  static const empty = AuthSellerSummary(isSeller: false);
}

sealed class AuthState {
  const AuthState();

  bool get isLoading => this is AuthLoading || this is AuthRestoring;
  bool get isGuest => this is AuthGuest;
  bool get isAuthenticated => this is AuthAuthenticated;

  AuthAuthenticated? get asAuthenticated =>
      this is AuthAuthenticated ? this as AuthAuthenticated : null;
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

enum AuthRestorationFailureReason { network, timeout, server, unknown }

class AuthRestoring extends AuthState {
  const AuthRestoring();
}

class AuthRestorationFailure extends AuthState {
  const AuthRestorationFailure({required this.reason});

  final AuthRestorationFailureReason reason;
}

class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final String sid;
  final Map<String, dynamic> preferences;
  final List<String> roles;
  final AuthSellerSummary seller;

  const AuthAuthenticated({
    required this.user,
    required this.sid,
    this.preferences = const {},
    this.roles = const [],
    this.seller = AuthSellerSummary.empty,
  });

  AuthAuthenticated copyWith({
    AuthUser? user,
    String? sid,
    Map<String, dynamic>? preferences,
    List<String>? roles,
    AuthSellerSummary? seller,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      sid: sid ?? this.sid,
      preferences: preferences ?? this.preferences,
      roles: roles ?? this.roles,
      seller: seller ?? this.seller,
    );
  }
}
