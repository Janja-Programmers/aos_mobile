import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      return credential;
    } catch (e) {
      return null;
    }
  }
}
