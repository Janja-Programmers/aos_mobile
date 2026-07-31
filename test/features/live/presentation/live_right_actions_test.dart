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
}
