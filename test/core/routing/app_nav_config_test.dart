import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/routing/app_nav_item.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main navigation uses the approved order', (tester) async {
    late List<AppNavItem> items;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            items = AppNavConfig.items(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      items.map((item) => item.label),
      orderedEquals(['Home', 'Feed', 'Post', 'Connect', 'Account']),
    );
    expect(items[2].requiresAuth, isTrue);
    expect(items[3].requiresAuth, isTrue);
    expect(items[3].behavior, AppNavBehavior.push);
  });

  testWidgets('route groups resolve to the correct destination', (
    tester,
  ) async {
    late BuildContext testContext;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            testContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(AppNavConfig.indexForLocation(testContext, '/'), 0);
    expect(AppNavConfig.indexForLocation(testContext, '/categories/cars'), 0);
    expect(AppNavConfig.indexForLocation(testContext, '/feeds'), 1);
    expect(AppNavConfig.indexForLocation(testContext, '/shorts/detail'), 1);
    expect(AppNavConfig.indexForLocation(testContext, '/seller'), 2);
    expect(AppNavConfig.indexForLocation(testContext, '/ads/edit/AD-001'), 2);
    expect(AppNavConfig.indexForLocation(testContext, '/connect'), 3);
    expect(AppNavConfig.indexForLocation(testContext, '/chats/view/CHAT-1'), 3);
    expect(AppNavConfig.indexForLocation(testContext, '/account/security'), 4);
  });
}
