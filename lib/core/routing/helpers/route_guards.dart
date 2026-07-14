import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

class RouteGuards {
  static const _protectedPrefixes = [
    AppRoutes.sellerStore,
    AppRoutes.sellerLocation,
    AppRoutes.sellerCustomizeStore,
    AppRoutes.myAds,
    AppRoutes.connect,
    AppRoutes.createAd,
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

  static String _pathOnly(String location) {
    return Uri.tryParse(location)?.path ?? location.split('?').first;
  }

  static String _staticRouteBase(String route) {
    final dynamicIndex = route.indexOf('/:');
    if (dynamicIndex == -1) return route;

    return route.substring(0, dynamicIndex);
  }
}
