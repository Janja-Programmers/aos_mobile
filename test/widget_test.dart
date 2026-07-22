import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('shared widget harness installs AOS theme and localization', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      Builder(
        builder: (BuildContext context) {
          return Text(
            Localizations.localeOf(context).languageCode,
            key: const Key('locale'),
            style: TextStyle(color: context.appColors.textPrimary),
          );
        },
      ),
    );

    expect(find.byKey(const Key('locale')), findsOneWidget);
    expect(find.text('en'), findsOneWidget);
  });
}
