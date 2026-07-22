import 'package:flutter_test/flutter_test.dart';

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String value,
) async {
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  await tester.pumpAndSettle();
}
