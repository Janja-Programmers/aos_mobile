import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/routing/helpers/route_guards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteGuards.authenticationRedirect', () {
    test('keeps public home reachable for guests', () {
      expect(
        RouteGuards.authenticationRedirect(
          currentLocation: AppRoutes.home,
          isGuest: true,
          isAuthenticated: false,
        ),
        isNull,
      );
    });

    test('sends a guest on a protected route to login', () {
      final redirect = RouteGuards.authenticationRedirect(
        currentLocation: AppRoutes.connect,
        isGuest: true,
        isAuthenticated: false,
      );

      expect(
        redirect,
        '${AppRoutes.login}?redirect=${Uri.encodeComponent(AppRoutes.connect)}',
      );
    });

    test('sends an authenticated user on login to home', () {
      expect(
        RouteGuards.authenticationRedirect(
          currentLocation: AppRoutes.login,
          isGuest: false,
          isAuthenticated: true,
        ),
        AppRoutes.home,
      );
    });

    test('preserves a valid protected post-login destination', () {
      final loginLocation =
          '${AppRoutes.login}?redirect=${Uri.encodeComponent(AppRoutes.connect)}';

      expect(
        RouteGuards.authenticationRedirect(
          currentLocation: loginLocation,
          isGuest: false,
          isAuthenticated: true,
        ),
        AppRoutes.connect,
      );
    });

    test('keeps restore public for guests', () {
      expect(
        RouteGuards.authenticationRedirect(
          currentLocation: AppRoutes.restoreAccount,
          isGuest: true,
          isAuthenticated: false,
        ),
        isNull,
      );
    });

    test('keeps authenticated accounts out of restore flow', () {
      expect(
        RouteGuards.authenticationRedirect(
          currentLocation: AppRoutes.restoreAccount,
          isGuest: false,
          isAuthenticated: true,
        ),
        AppRoutes.home,
      );
    });
  });
}
