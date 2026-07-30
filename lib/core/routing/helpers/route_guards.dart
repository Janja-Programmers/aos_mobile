import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

class RouteGuards {
  static const _protectedPrefixes = [
    AppRoutes.sellerStore,
    AppRoutes.sellerLocation,
    AppRoutes.sellerCustomizeStore,
    AppRoutes.sellerVerification,
    AppRoutes.myAds,
    AppRoutes.connect,
    AppRoutes.createAd,
    AppRoutes.userVerification,
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
      return AppRoutes.home;
    }

    return null;
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
