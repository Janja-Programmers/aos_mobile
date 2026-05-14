import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user
/// Contains only business-relevant information, no API response-specific fields
class UserEntity extends Equatable {
  final String email;
  final String fullName;
  final String userImage;
  
  // Additional domain fields that may not come from API
  final String? userId;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;

  const UserEntity({
    required this.email,
    required this.fullName,
    required this.userImage,
    this.userId,
    this.isEmailVerified,
    this.isPhoneVerified,
  });

  /// Create a copy with optional fields replaced
  UserEntity copyWith({
    String? email,
    String? fullName,
    String? userImage,
    String? userId,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserEntity(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userImage: userImage ?? this.userImage,
      userId: userId ?? this.userId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  @override
  List<Object?> get props => [email, fullName, userImage, userId, isEmailVerified, isPhoneVerified];
}

/// Authentication credentials for login
class AuthCredentials extends Equatable {
  final String email;
  final String password;

  const AuthCredentials({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Registration data
class RegistrationData extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String? country;
  final String? language;
  final String? currency;

  const RegistrationData({
    required this.email,
    required this.password,
    required this.fullName,
    this.country,
    this.language,
    this.currency,
  });

  @override
  List<Object?> get props => [email, password, fullName, country, language, currency];
}

/// Authentication session containing user and token
class AuthSession extends Equatable {
  final UserEntity user;
  final String sessionId;
  final String? accessToken;
  final DateTime? expiresAt;

  const AuthSession({
    required this.user,
    required this.sessionId,
    this.accessToken,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  AuthSession copyWith({
    UserEntity? user,
    String? sessionId,
    String? accessToken,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      user: user ?? this.user,
      sessionId: sessionId ?? this.sessionId,
      accessToken: accessToken ?? this.accessToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [user, sessionId, accessToken, expiresAt];
}
