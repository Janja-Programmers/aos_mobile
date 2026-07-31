import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/routing/helpers/route_guards.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authentication route classification', () {
    test('auth routes remain guest-accessible with query parameters', () {
      expect(RouteGuards.isAuthRoute('/login?redirect=%2Fconnect'), isTrue);
      expect(RouteGuards.isProtectedRoute('/login'), isFalse);
    });

    test('dynamic protected routes use their static base', () {
      expect(RouteGuards.isProtectedRoute('/report-ad/AD-TEST-1'), isTrue);
      expect(
        RouteGuards.isProtectedRoute('/seller/customize/SELLER-TEST-1'),
        isTrue,
      );
    });

    test('public marketplace detail remains available to guests', () {
      expect(RouteGuards.isProtectedRoute('/ads/detail/AD-TEST-1'), isFalse);
    });
  });

  group('authentication redirect resolution', () {
    test('guest protected redirect preserves the intended URI', () {
      final String? redirect = RouteGuards.authenticationRedirect(
        currentLocation: '/connect?tab=unread',
        isGuest: true,
        isAuthenticated: false,
      );

      final Uri uri = Uri.parse(redirect!);
      expect(uri.path, AppRoutes.login);
      expect(uri.queryParameters['redirect'], '/connect?tab=unread');
    });

    test('authenticated users can remain on a protected route', () {
      final String? redirect = RouteGuards.authenticationRedirect(
        currentLocation: AppRoutes.connect,
        isGuest: false,
        isAuthenticated: true,
      );

      expect(redirect, isNull);
    });

    test(
      'authenticated users are redirected away from guest-only auth routes',
      () {
        final String? redirect = RouteGuards.authenticationRedirect(
          currentLocation: AppRoutes.login,
          isGuest: false,
          isAuthenticated: true,
        );

        expect(redirect, AppRoutes.home);
      },
    );

    test('guest access to login does not create a redirect loop', () {
      final String? redirect = RouteGuards.authenticationRedirect(
        currentLocation: '${AppRoutes.login}?redirect=%2Fconnect',
        isGuest: true,
        isAuthenticated: false,
      );

      expect(redirect, isNull);
    });
  });
  group('session-resolution redirects', () {
    test('loading, restoring, and retryable failure remain on splash', () {
      expect(
        RouteGuards.requiresSessionResolution(const AuthLoading()),
        isTrue,
      );
      expect(
        RouteGuards.requiresSessionResolution(const AuthRestoring()),
        isTrue,
      );
      expect(
        RouteGuards.requiresSessionResolution(
          const AuthRestorationFailure(
            reason: AuthRestorationFailureReason.network,
          ),
        ),
        isTrue,
      );
    });

    test('guest and authenticated states are fully resolved', () {
      expect(RouteGuards.requiresSessionResolution(const AuthGuest()), isFalse);
      expect(
        RouteGuards.requiresSessionResolution(
          AuthAuthenticated(
            user: AuthUser(
              email: 'user@example.invalid',
              fullName: 'Test User',
            ),
            sid: 'test-session',
          ),
        ),
        isFalse,
      );
    });
  });
}
