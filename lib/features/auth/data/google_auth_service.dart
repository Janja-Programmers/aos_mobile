import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthServiceException implements Exception {
  const GoogleAuthServiceException({
    required this.error,
    required this.userMessage,
    this.description,
  });

  final String error;
  final String userMessage;
  final String? description;

  @override
  String toString() => 'GoogleAuthServiceException($error, $description)';
}

class GoogleAuthService {
  static final GoogleSignIn _signIn = GoogleSignIn.instance;

  static Future<void>? _initialization;

  static Future<void> _ensureInitialized() {
    return _initialization ??= _signIn.initialize(
      serverClientId: AppConfig.googleWebClientId,
    );
  }

  /// Starts the native Google sign-in flow and returns the ID token expected
  /// by the AOS backend.
  ///
  /// google_sign_in 7.x returns the authenticated account directly from
  /// [GoogleSignIn.authenticate]. Authentication event streams are useful for
  /// app-wide auth observation, but they are unnecessary for this one-shot
  /// button flow and previously made failures indistinguishable from cancel.
  static Future<String> signInAndGetIdToken() async {
    try {
      await _ensureInitialized();

      if (!_signIn.supportsAuthenticate()) {
        throw const GoogleAuthServiceException(
          error: 'GOOGLE_UI_UNAVAILABLE',
          userMessage: 'Google sign-in is unavailable on this device.',
        );
      }

      final GoogleSignInAccount account = await _signIn.authenticate();
      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.trim().isEmpty) {
        throw const GoogleAuthServiceException(
          error: 'GOOGLE_ID_TOKEN_MISSING',
          userMessage:
              'Google sign-in completed without an identity token. Please try again.',
        );
      }

      return idToken.trim();
    } on GoogleSignInException catch (error, stackTrace) {
      final GoogleAuthServiceException mapped = _mapGoogleException(error);
      appLogger.w(
        '[Auth] Google sign-in failed: ${mapped.error}; '
        'description=${error.description ?? 'none'}',
        error: error,
        stackTrace: stackTrace,
      );
      throw mapped;
    }
  }

  static GoogleAuthServiceException _mapGoogleException(
    GoogleSignInException exception,
  ) {
    final String? description = exception.description?.trim();

    switch (exception.code) {
      case GoogleSignInExceptionCode.canceled:
        // Android Credential Manager can also surface configuration failures
        // as `canceled` after account selection, so do not tell the user that
        // cancellation is definitely what happened.
        return GoogleAuthServiceException(
          error: 'GOOGLE_SIGN_IN_CANCELLED_OR_CONFIG',
          userMessage:
              'Google sign-in was cancelled or could not complete. Please try again.',
          description: description,
        );
      case GoogleSignInExceptionCode.interrupted:
        return GoogleAuthServiceException(
          error: 'GOOGLE_SIGN_IN_INTERRUPTED',
          userMessage: 'Google sign-in was interrupted. Please try again.',
          description: description,
        );
      case GoogleSignInExceptionCode.clientConfigurationError:
        return GoogleAuthServiceException(
          error: 'GOOGLE_CLIENT_CONFIG_ERROR',
          userMessage:
              'Google sign-in is not configured correctly for this app build.',
          description: description,
        );
      case GoogleSignInExceptionCode.providerConfigurationError:
        return GoogleAuthServiceException(
          error: 'GOOGLE_PROVIDER_CONFIG_ERROR',
          userMessage:
              'Google sign-in is temporarily unavailable on this device.',
          description: description,
        );
      case GoogleSignInExceptionCode.uiUnavailable:
        return GoogleAuthServiceException(
          error: 'GOOGLE_UI_UNAVAILABLE',
          userMessage:
              'Google sign-in cannot open right now. Please try again.',
          description: description,
        );
      case GoogleSignInExceptionCode.userMismatch:
        return GoogleAuthServiceException(
          error: 'GOOGLE_USER_MISMATCH',
          userMessage:
              'Google sign-in account state changed. Please try again.',
          description: description,
        );
      case GoogleSignInExceptionCode.unknownError:
        return GoogleAuthServiceException(
          error: 'GOOGLE_SIGN_IN_FAILED',
          userMessage: 'Google sign-in failed. Please try again.',
          description: description,
        );
    }
  }
}
