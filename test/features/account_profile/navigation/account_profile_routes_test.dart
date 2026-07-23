import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/account/shared/routing/account_routes.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Account routes expose account lifecycle destinations', () {
    final List<GoRoute> routes = AccountRoutes.routes()
        .whereType<GoRoute>()
        .toList();
    final Map<String?, String> paths = <String?, String>{
      for (final GoRoute route in routes) route.name: route.path,
    };

    expect(paths[AppRoutes.nAccount], AppRoutes.account);
    expect(paths[AppRoutes.nDeleteAccount], AppRoutes.deleteAccount);
    expect(paths[AppRoutes.nRestoreAccount], AppRoutes.restoreAccount);
    expect(paths[AppRoutes.nUserVerification], AppRoutes.userVerification);
  });

  test('Social profile route uses the stable profile name and path', () {
    final GoRoute route = SocialRoutes.routes()
        .whereType<GoRoute>()
        .singleWhere((GoRoute item) => item.name == AppRoutes.nProfile);

    expect(route.path, AppRoutes.profile);
  });
}
