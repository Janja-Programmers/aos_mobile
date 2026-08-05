import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  ChatMessage message({required String sender}) {
    return ChatMessage(
      id: 'MSG-1',
      senderCanonicalId: sender,
      messageType: 'text',
      hasAttachments: false,
      createdAt: DateTime.utc(2026, 1, 12, 9),
      attachments: const [],
      content: 'Hello',
    );
  }

  testWidgets('authenticated user message is aligned right', (tester) async {
    await tester.pumpTestApp(
      MessageBubble(message: message(sender: 'ACC-CURRENT'), isMe: true),
    );

    final align = tester.widget<Align>(
      find
          .descendant(
            of: find.byType(MessageBubble),
            matching: find.byType(Align),
          )
          .first,
    );

    expect(align.alignment, Alignment.centerRight);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incoming user message is aligned left', (tester) async {
    await tester.pumpTestApp(
      MessageBubble(message: message(sender: 'ACC-OTHER'), isMe: false),
    );

    final align = tester.widget<Align>(
      find
          .descendant(
            of: find.byType(MessageBubble),
            matching: find.byType(Align),
          )
          .first,
    );

    expect(align.alignment, Alignment.centerLeft);
    expect(tester.takeException(), isNull);
  });
}
