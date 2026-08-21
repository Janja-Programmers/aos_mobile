import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loading state renders conversation-row shimmer placeholders', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const <ThemeExtension<dynamic>>[AppColorTokens.light],
        ),
        home: const Scaffold(
          body: ConnectStateView.loading(
            title: 'Loading conversations',
            message: 'Please wait while conversations load.',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Loading conversations'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('connect_loading_row_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('connect_loading_row_7')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading shimmer remains overflow-free at 200% text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          extensions: const <ThemeExtension<dynamic>>[AppColorTokens.dark],
        ),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ConnectStateView.loading(
              title: 'Loading calls',
              message: 'Please wait while call history loads.',
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
