import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:africaonlinestores/core/config/app_config.dart';

class GoogleAuthService {
  static final GoogleSignIn _signIn = GoogleSignIn.instance;

  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _signIn.initialize(serverClientId: AppConfig.googleWebClientId);

    _initialized = true;
  }

  /// Starts Google sign-in and returns ID token for backend
  static Future<String?> signInAndGetIdToken() async {
    await _ensureInitialized();

    final completer = Completer<String?>();

    late StreamSubscription sub;
    sub = _signIn.authenticationEvents.listen(
      (event) async {
        try {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            final auth = event.user.authentication;
            completer.complete(auth.idToken);
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            completer.complete(null);
          }
        } catch (_) {
          completer.complete(null);
        } finally {
          await sub.cancel();
        }
      },
      onError: (Object _, StackTrace _) async {
        // Any auth flow error ends up here (treat as failure)
        if (!completer.isCompleted) completer.complete(null);
        await sub.cancel();
      },
    );

    try {
      await _signIn.authenticate();
    } catch (_) {
      await sub.cancel();
      return null;
    }

    return completer.future;
  }
}
