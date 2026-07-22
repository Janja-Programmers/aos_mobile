import 'package:africaonlinestores/core/utils/json_utils.dart';

/// Immutable request contract for mobile password login.
class MobileLoginRequest {
  const MobileLoginRequest({required this.identifier, required this.password});

  final String identifier;
  final String password;

  static const String clientType = 'mobile';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'identifier': identifier,
      'password': password,
      'client_type': clientType,
    };
  }
}

/// Defensively parsed authentication payload shared by login and `/me`.
///
/// Login payloads may contain [sid], [authenticated], and [expiresAt] inside
/// `data.session`. The `/me` endpoint intentionally omits session data and is
/// valid when it supplies a non-empty user object.
class AuthSessionPayload {
  const AuthSessionPayload({
    required this.user,
    required this.preferences,
    required this.roles,
    required this.seller,
    required this.sid,
    required this.authenticated,
    required this.expiresAt,
  });

  factory AuthSessionPayload.fromData(Map<String, dynamic> data) {
    final Map<String, dynamic> session = asJsonMap(data['session']);
    final bool? authenticated = session.containsKey('authenticated')
        ? asBool(session['authenticated'])
        : null;

    return AuthSessionPayload(
      user: asJsonMap(data['user']),
      preferences: asJsonMap(data['preferences']),
      roles: asJsonList(data['roles'])
          .map((Object? role) => role.toString().trim())
          .where((String role) => role.isNotEmpty)
          .toList(growable: false),
      seller: asJsonMap(data['seller']),
      sid: asString(session['sid']).trim(),
      authenticated: authenticated,
      expiresAt: asNullableString(session['expires_at']),
    );
  }

  final Map<String, dynamic> user;
  final Map<String, dynamic> preferences;
  final List<String> roles;
  final Map<String, dynamic> seller;
  final String sid;
  final bool? authenticated;
  final String? expiresAt;

  bool get hasUser => user.isNotEmpty;
  bool get isExplicitlyUnauthenticated => authenticated == false;
}
