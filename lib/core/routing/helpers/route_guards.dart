import 'package:africaonlinestores/core/routing/app_routes.dart';

class RouteGuards {
  static const _protectedPrefixes = [
    AppRoutes.sellerStore,
    AppRoutes.myAds,
    AppRoutes.chats,
    AppRoutes.createAd,
    AppRoutes.updateProfile,
    AppRoutes.reportAdBase,
    AppRoutes.reviewAdBase,
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
