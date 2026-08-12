import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_right_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('share action is visible and reachable', (tester) async {
    var shareCount = 0;

    await tester.pumpTestApp(
      Stack(
        children: [
          LiveRightActions(
            onLike: () {},
            onShare: () {
              shareCount++;
            },
            onFlip: () {},
            onMute: () {},
            onCohost: () {},
            isHost: false,
            isMuted: false,
          ),
        ],
      ),
    );

    expect(find.byTooltip('Share live'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.share_rounded));
    await tester.pump();

    expect(shareCount, 1);
  });

  testWidgets('long press exposes every backend-supported reaction', (
    tester,
  ) async {
    LiveReactionType? selected;

    await tester.pumpTestApp(
      Stack(
        children: [
          LiveRightActions(
            onLike: () {},
            onReaction: (reaction) => selected = reaction,
            onShare: () {},
            onFlip: () {},
            onMute: () {},
            onCohost: () {},
            isHost: false,
            isMuted: false,
          ),
        ],
      ),
    );

    await tester.longPress(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    for (final reaction in LiveReactionType.values) {
      expect(find.text(reaction.label), findsOneWidget);
      expect(find.text(reaction.emoji), findsOneWidget);
    }

    await tester.tap(find.text('Fire'));
    await tester.pumpAndSettle();

    expect(selected, LiveReactionType.fire);
  });

  testWidgets('actions remain overflow-free on a small high-text screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpTestApp(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 480),
          textScaler: TextScaler.linear(2),
        ),
        child: Stack(
          children: [
            LiveRightActions(
              onLike: () {},
              onReaction: (_) {},
              onShare: () {},
              onFlip: () {},
              onMute: () {},
              onCohost: () {},
              isHost: true,
              isMuted: false,
              showCohost: true,
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });
}
