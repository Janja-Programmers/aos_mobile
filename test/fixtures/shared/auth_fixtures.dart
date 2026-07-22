import 'package:africaonlinestores/features/auth/domain/auth_state.dart';

AuthAuthenticated authenticatedAuthState({
  String email = 'user@example.invalid',
  String fullName = 'Test User',
  String sid = 'test-session-id',
  bool isVerified = false,
  Map<String, dynamic> preferences = const <String, dynamic>{
    'country': 'KE',
    'language': 'en',
    'currency': 'KES',
  },
  List<String> roles = const <String>['AOS User'],
  AuthSellerSummary seller = AuthSellerSummary.empty,
}) {
  return AuthAuthenticated(
    user: AuthUser(email: email, fullName: fullName, isVerified: isVerified),
    sid: sid,
    preferences: preferences,
    roles: roles,
    seller: seller,
  );
}

const AuthGuest guestAuthState = AuthGuest();
const AuthLoading loadingAuthState = AuthLoading();
