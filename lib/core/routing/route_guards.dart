import 'package:africaonlinestores/core/routing/app_routes.dart';

class RouteGuards {
  static const _protectedPrefixes = [
    AppRoutes.sellerBase,
    AppRoutes.myAds,
    AppRoutes.createAd,
    AppRoutes.account,
    AppRoutes.reportAdBase,
  ];

  static bool isOnboarding(String location) {
    return location.startsWith(AppRoutes.onboarding);
  }

  static bool isAuthRoute(String location) {
    return location.startsWith('/auth');
  }

  /// Public routes
  static bool isPublicRoute(String location) {
    return isAuthRoute(location) || isOnboarding(location);
  }

  /// Protected routes (require login)
  static bool isProtectedRoute(String location) {
    return _protectedPrefixes.any(location.startsWith);
  }
}
