import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/incoming_call_action_bar.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpActionBar(
    WidgetTester tester, {
    required Locale locale,
    double textScale = 1,
    VoidCallback? onAnswer,
    VoidCallback? onDecline,
  }) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppColorTokens.light],
        ),
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: Scaffold(
          backgroundColor: const Color(0xFF0B141A),
          body: Align(
            alignment: Alignment.bottomCenter,
            child: IncomingCallActionBar(
              onAnswer: onAnswer ?? () {},
              onDecline: onDecline ?? () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('incoming actions remain reachable at 200% text scale', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    var answers = 0;
    var declines = 0;

    await pumpActionBar(
      tester,
      locale: const Locale('en'),
      textScale: 2,
      onAnswer: () => answers += 1,
      onDecline: () => declines += 1,
    );

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Answer'), findsOneWidget);
    expect(find.bySemanticsLabel('Decline'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Answer'));
    await tester.tap(find.bySemanticsLabel('Decline'));
    expect(answers, 1);
    expect(declines, 1);
  });

  testWidgets('incoming actions localize and lay out in RTL', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await pumpActionBar(tester, locale: const Locale('ar'), textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('رد'), findsOneWidget);
    expect(find.bySemanticsLabel('رفض'), findsOneWidget);

    final context = tester.element(find.byType(IncomingCallActionBar));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
