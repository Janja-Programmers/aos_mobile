import 'package:africaonlinestores/features/account/presentation/widgets/account_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('missing avatar renders deterministic initials fallback', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      const AccountHeaderCard(
        fullName: 'Test Owner',
        email: 'owner@example.invalid',
        initials: 'TO',
        baseUrl: 'https://example.invalid',
      ),
    );

    expect(find.text('TO'), findsOneWidget);
    expect(find.text('Test Owner'), findsOneWidget);
    expect(find.text('owner@example.invalid'), findsOneWidget);
  });

  testWidgets('verified account displays the shared badge', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      const AccountHeaderCard(
        fullName: 'Verified Owner',
        email: 'verified@example.invalid',
        initials: 'VO',
        baseUrl: 'https://example.invalid',
        isVerified: true,
      ),
    );

    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('header tap invokes profile navigation callback', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpTestApp(
      AccountHeaderCard(
        fullName: 'Test Owner',
        email: 'owner@example.invalid',
        initials: 'TO',
        baseUrl: 'https://example.invalid',
        onEdit: () => taps += 1,
      ),
    );

    await tester.tap(find.text('Test Owner'));
    expect(taps, 1);
  });
}
