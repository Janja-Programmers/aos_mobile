import 'package:africaonlinestores/features/auth/shared/widgets/otp_resend_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'resend remains disabled until the implemented cooldown reaches zero',
    (WidgetTester tester) async {
      int resendCalls = 0;

      await tester.pumpTestApp(
        OtpResendRow(
          initialSeconds: 2,
          onResend: () {
            resendCalls++;
          },
        ),
      );

      expect(
        find.byKey(const Key('auth.otp.resend.countdown')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('auth.otp.resend.action')), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('auth.otp.resend.action')), findsOneWidget);
      await tester.tap(find.byKey(const Key('auth.otp.resend.action')));
      await tester.pump();

      expect(resendCalls, 1);
      expect(
        find.byKey(const Key('auth.otp.resend.countdown')),
        findsOneWidget,
      );
    },
  );
}
