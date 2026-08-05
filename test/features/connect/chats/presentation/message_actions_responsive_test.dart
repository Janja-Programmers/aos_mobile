import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('message actions do not overflow on small RTL 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final message = ChatMessage(
      id: 'MSG-1',
      senderCanonicalId: 'ACC-1',
      messageType: 'text',
      hasAttachments: false,
      createdAt: DateTime.utc(2026, 1, 12),
      attachments: const [],
      content: 'A long message that still has safe actions.',
    );

    await tester.pumpTestApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: MessageActionsSheet(
            message: message,
            isMe: true,
            canEdit: true,
            onReply: () {},
            onEdit: () {},
            onCopy: () {},
            onToggleStar: () {},
            onToggleReaction: (_) {},
            onChooseReaction: () {},
            onDelete: () {},
            onTranslate: () {},
            onForward: () {},
            anchor: Offset.zero,
          ),
        ),
      ),
    );

    expect(find.text('Star'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
