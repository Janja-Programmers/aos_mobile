import 'package:africaonlinestores/core/routing/app_routes.dart';

/// Helper utilities to classify routes.
class RouteGuards {
  static bool isOnboarding(String location) {
    return location.startsWith(AppRoutes.onboarding);
  }

  static bool isAuthRoute(String location) {
    return location.startsWith('/auth');
  }

  static bool isAccountRoute(String location) {
    return location.startsWith('/account');
  }

  static bool isSellerRoute(String location) {
    return location.startsWith('/seller');
  }

  static bool isCreateAdRoute(String location) {
    return location.startsWith(AppRoutes.createAd);
  }

  /// Routes accessible without authentication
  static bool isPublicRoute(String location) {
    return isAuthRoute(location) || isOnboarding(location);
  }

  /// Routes that require authentication
  static bool isProtectedRoute(String location) {
    return isSellerRoute(location) || isCreateAdRoute(location);
  }
}
