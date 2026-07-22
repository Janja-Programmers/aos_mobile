import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/routing/helpers/route_guards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteGuards', () {
    test('treats protected route query strings as part of the same path', () {
      expect(
        RouteGuards.isProtectedRoute('${AppRoutes.createAd}?draftId=DRAFT-1'),
        isTrue,
      );
    });

    test('matches the static base of a protected dynamic route', () {
      expect(RouteGuards.isProtectedRoute('/report-ad/AD-1'), isTrue);
    });

    test('does not protect a public ad detail route', () {
      expect(RouteGuards.isProtectedRoute('/ads/detail/AD-1'), isFalse);
    });

    test(
      'recognizes only exact auth route paths after removing query data',
      () {
        expect(RouteGuards.isAuthRoute('/login?redirect=%2Fconnect'), isTrue);
        expect(RouteGuards.isAuthRoute('/login/other'), isFalse);
      },
    );
  });
}
