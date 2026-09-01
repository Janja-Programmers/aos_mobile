import 'dart:io';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_body.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_header.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/widgets/user_verification_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget testApp({
    required Widget child,
    Size size = const Size(320, 640),
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[AppColorTokens.light],
      ),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: textScaler),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
  }

  testWidgets('verification header fits a small screen at 200% text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        textScaler: const TextScaler.linear(2),
        child: const SingleChildScrollView(
          child: UserVerificationStepHeader(
            icon: Icons.person_outline_rounded,
            title: 'Personal Details',
            subtitle:
                'Enter your legal name exactly as it appears on your identity document and provide a reachable phone number.',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Personal Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'verification stepper keeps compact 48dp targets without overflow',
    (tester) async {
      await tester.pumpWidget(
        testApp(
          textScaler: const TextScaler.linear(2),
          child: UserVerificationStepper(
            currentStep: 1,
            completedSteps: const <int>{0},
            onStepTapped: (_) {},
            isStepAccessible: (_) => true,
          ),
        ),
      );
      await tester.pump();

      final stepperSize = tester.getSize(find.byType(UserVerificationStepper));
      expect(stepperSize.width, lessThanOrEqualTo(320));
      expect(tester.takeException(), isNull);

      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Verification step 1 of 4'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'verification step content is width constrained on large windows',
    (tester) async {
      const contentKey = ValueKey<String>('verification-content');

      await tester.pumpWidget(
        testApp(
          size: const Size(900, 1000),
          child: const UserVerificationStepBody(
            child: SizedBox(
              key: contentKey,
              width: double.infinity,
              height: 900,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.byKey(contentKey)).width,
        lessThanOrEqualTo(UserVerificationStepBody.maxContentWidth),
      );
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'verification presentation does not disable text scaling or scale pages',
    () {
      final directory = Directory(
        'lib/features/verifications/user_verification/presentation',
      );
      final dartFiles = directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final source = file.readAsStringSync();
        expect(source, isNot(contains('Transform.scale(')), reason: file.path);
        expect(
          source,
          isNot(contains('MediaQuery.withNoTextScaling')),
          reason: file.path,
        );
        expect(source, isNot(contains('textScaleFactor')), reason: file.path);
      }
    },
  );
}
