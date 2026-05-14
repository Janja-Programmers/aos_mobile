import 'package:africaonlinestores/features/auth/domain/auth_entity.dart';

/// API response model for user data
/// Handles JSON serialization with snake_case fields from API
/// Separate from domain entity to isolate API response format
class UserModel {
  final String email;
  final String fullName;
  final String userImage;
  final String? userId;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;

  UserModel({
    required this.email,
    required this.fullName,
    required this.userImage,
    this.userId,
    this.isEmailVerified,
    this.isPhoneVerified,
  });

  /// Parse from API JSON response
  /// Handles snake_case to camelCase conversion
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      userImage: (json['user_image'] ?? '').toString(),
      userId: json['user_id']?.toString(),
      isEmailVerified: json['email_verified'] as bool?,
      isPhoneVerified: json['phone_verified'] as bool?,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'user_image': userImage,
      'user_id': userId,
      'email_verified': isEmailVerified,
      'phone_verified': isPhoneVerified,
    };
  }

  /// Convert model to domain entity
  /// Strips API-specific fields and returns pure business object
  UserEntity toEntity() {
    return UserEntity(
      email: email,
      fullName: fullName,
      userImage: userImage,
      userId: userId,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
    );
  }
}

/// API response model for authentication response
/// Contains session data returned after login/register
class AuthResponseModel {
  final UserModel user;
  final String sessionId;
  final String? accessToken;
  final int? expiresIn; // seconds until expiration

  AuthResponseModel({
    required this.user,
    required this.sessionId,
    this.accessToken,
    this.expiresIn,
  });

  /// Parse from API JSON response
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(
        json['user'] ?? {},
      ),
      sessionId: (json['sid'] ?? json['session_id'] ?? '').toString(),
      accessToken: json['access_token']?.toString(),
      expiresIn: json['expires_in'] as int?,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'sid': sessionId,
      'access_token': accessToken,
      'expires_in': expiresIn,
    };
  }

  /// Convert model to domain entity
  AuthSession toEntity() {
    final expiresAt = expiresIn != null
        ? DateTime.now().add(Duration(seconds: expiresIn!))
        : null;

    return AuthSession(
      user: user.toEntity(),
      sessionId: sessionId,
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
  }
}
