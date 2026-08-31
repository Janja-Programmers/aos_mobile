import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';

class RouteGuards {
  static bool requiresSessionResolution(AuthState authState) {
    return authState is AuthLoading ||
        authState is AuthRestoring ||
        authState is AuthRestorationFailure;
  }

  static const _protectedPrefixes = [
    AppRoutes.sellerStore,
    AppRoutes.sellerLocation,
    AppRoutes.sellerCustomizeStore,
    AppRoutes.sellerVerification,
    AppRoutes.myAds,
    AppRoutes.connect,
    AppRoutes.createAd,
    AppRoutes.passwordSecurity,
    AppRoutes.userVerification,
    AppRoutes.deleteAccount,
    AppRoutes.activityCenter,
    AppRoutes.notifications,
    AppRoutes.notification,
    AppRoutes.chatsList,
    AppRoutes.messages,
    AppRoutes.callsList,
    AppRoutes.newCall,
    AppRoutes.profile,
    AppRoutes.reportAdBase,
    AppRoutes.reviewAdBase,
  ];

  static const _authRoutes = [
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.verifyOtp,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
    AppRoutes.restoreAccount,
  ];

  static bool isOnboarding(String location) {
    return location.startsWith(AppRoutes.onboarding);
  }

  static bool isAuthRoute(String location) {
    final path = _pathOnly(location);
    return _authRoutes.any((route) => path == route);
  }

  /// Public routes
  static bool isPublicRoute(String location) {
    return isAuthRoute(location) || isOnboarding(location);
  }

  /// Protected routes (require login)
  static bool isProtectedRoute(String location) {
    final path = _pathOnly(location);

    return _protectedPrefixes.any((route) {
      final base = _staticRouteBase(route);
      return path == base || path.startsWith('$base/');
    });
  }

  /// Routes that may be publicly reachable for guests but expose private
  /// account content when an authenticated session exists.
  static bool isAppLockProtectedRoute(String location) {
    final String path = _pathOnly(location);
    return isProtectedRoute(location) || path == AppRoutes.account;
  }

  /// Resolves only authentication-dependent redirects.
  ///
  /// Bootstrap and onboarding redirects remain owned by the app router.
  static String? authenticationRedirect({
    required String currentLocation,
    required bool isGuest,
    required bool isAuthenticated,
  }) {
    if (isGuest && isProtectedRoute(currentLocation)) {
      final String encodedLocation = Uri.encodeComponent(currentLocation);
      return '${AppRoutes.login}?redirect=$encodedLocation';
    }

    if (isAuthenticated && isAuthRoute(currentLocation)) {
      return _postAuthenticationDestination(currentLocation) ?? AppRoutes.home;
    }

    return null;
  }

  static String? _postAuthenticationDestination(String currentLocation) {
    final Uri? authUri = Uri.tryParse(currentLocation);
    if (authUri == null || authUri.path != AppRoutes.login) return null;

    final String target = authUri.queryParameters['redirect']?.trim() ?? '';
    if (target.isEmpty || target.length > 2048) return null;
    if (!target.startsWith('/') || target.startsWith('//')) return null;
    if (target.contains('\\')) return null;

    final Uri? targetUri = Uri.tryParse(target);
    if (targetUri == null || targetUri.hasScheme || targetUri.hasAuthority) {
      return null;
    }

    try {
      for (final String segment in targetUri.pathSegments) {
        final String decoded = Uri.decodeComponent(segment);
        if (decoded == '.' || decoded == '..') return null;
      }
    } on FormatException {
      return null;
    }

    return isProtectedRoute(target) ? target : null;
  }

  static String _pathOnly(String location) {
    return Uri.tryParse(location)?.path ?? location.split('?').first;
  }

  static String _staticRouteBase(String route) {
    final dynamicIndex = route.indexOf('/:');
    if (dynamicIndex == -1) return route;

    return route.substring(0, dynamicIndex);
  }
}
