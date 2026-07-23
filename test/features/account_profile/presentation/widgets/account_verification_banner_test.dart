import 'package:africaonlinestores/features/verifications/presentation/widgets/account_verification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('unverified banner is actionable and exposes status text', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpTestApp(
      AccountVerificationBanner(
        title: 'Verify your account',
        subtitle: 'Choose personal or business verification.',
        tone: AccountVerificationBannerTone.available,
        onTap: () => taps += 1,
      ),
    );

    expect(find.text('Verify your account'), findsOneWidget);
    await tester.tap(find.text('Verify your account'));
    expect(taps, 1);
  });

  testWidgets('busy banner blocks duplicate navigation', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpTestApp(
      AccountVerificationBanner(
        title: 'Verify your account',
        subtitle: 'Loading status.',
        tone: AccountVerificationBannerTone.available,
        busy: true,
        onTap: () => taps += 1,
      ),
    );

    await tester.tap(find.text('Verify your account'));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
