import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows one reaction aggregate beside the tappable viewer count', (
    tester,
  ) async {
    var viewerTaps = 0;
    await tester.pumpTestApp(
      Stack(
        children: [
          LiveTopBar(
            viewerCount: 17,
            reactionCount: 42,
            onEnd: () {},
            onViewers: () => viewerTaps++,
            isHost: false,
            hostName: 'Test Host',
            title: 'A production Live',
          ),
        ],
      ),
    );

    expect(find.bySemanticsLabel('Live now'), findsOneWidget);
    expect(find.bySemanticsLabel('42 reactions'), findsOneWidget);
    expect(find.bySemanticsLabel('17 viewers'), findsOneWidget);
    expect(find.text('Leave'), findsOneWidget);

    await tester.tap(find.byKey(const Key('live_viewer_count_button')));
    await tester.pump();
    expect(viewerTaps, 1);
  });

  testWidgets('follow action uses primary background and button text color', (
    tester,
  ) async {
    var followCalls = 0;

    await tester.pumpTestApp(
      Stack(
        children: [
          LiveTopBar(
            viewerCount: 17,
            reactionCount: 42,
            onEnd: () {},
            isHost: false,
            hostName: 'Test Host',
            title: 'A production Live',
            showFollow: true,
            onFollow: () => followCalls++,
          ),
        ],
      ),
    );

    final finder = find.byKey(const Key('live_follow_host_button'));
    final button = tester.widget<FilledButton>(finder);
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      AppColorTokens.light.primary,
    );
    expect(
      button.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColorTokens.light.btnText,
    );
    expect(find.text('Follow'), findsOneWidget);

    await tester.tap(finder);
    await tester.pump();
    expect(followCalls, 1);
  });

  testWidgets('top controls remain overflow-free with 200 percent text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpTestApp(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(2),
        ),
        child: Stack(
          children: [
            LiveTopBar(
              viewerCount: 12000,
              reactionCount: 85000,
              onEnd: () {},
              isHost: false,
              hostName: 'A very long host display name for testing',
              title: 'A long Live title that must remain bounded and readable',
              showFollow: true,
              onFollow: () {},
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Leave'), findsOneWidget);
  });
}
