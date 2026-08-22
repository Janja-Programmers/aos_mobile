import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('selection mode shows a circular selector and toggles it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool? selected;
    final conversation = ChatConversation(
      id: 'CONV-1',
      user: 'ACC-OTHER',
      displayName: 'Bobby',
      lastMessage: 'Hello',
      unreadCount: 1,
    );

    await tester.pumpTestApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: ConversationTile(
          conversation: conversation,
          currentUserCanonicalId: 'ACC-CURRENT',
          selectionMode: true,
          onSelectionChanged: (value) => selected = value,
          onTap: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.radio_button_unchecked_rounded));
    expect(selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
