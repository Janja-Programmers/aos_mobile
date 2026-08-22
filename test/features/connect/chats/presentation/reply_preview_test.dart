import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/reply_preview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('tapping a reply preview dispatches navigation to its message', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpTestApp(
      ReplyPreview(
        reply: const ChatReplyPreview(
          id: 'MSG-ORIGINAL',
          sender: 'ACC-1',
          senderDisplayName: 'Bobby',
          content: 'Original message',
          messageType: 'text',
        ),
        isMe: true,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Original message'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
