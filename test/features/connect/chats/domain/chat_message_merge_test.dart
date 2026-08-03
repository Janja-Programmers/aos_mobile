import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_merge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatMessage message(String id, int minute) {
    return ChatMessage(
      id: id,
      senderCanonicalId: 'ACC-1',
      messageType: 'text',
      hasAttachments: false,
      createdAt: DateTime.utc(2026, 1, 12, 9, minute),
      attachments: const [],
      content: id,
    );
  }

  test('realtime duplicate ids are removed without reordering', () {
    final result = dedupeChatMessagesPreservingOrder(<ChatMessage>[
      message('MSG-3', 3),
      message('MSG-2', 2),
      message('MSG-3', 3),
    ]);

    expect(result.map((item) => item.id), <String>['MSG-3', 'MSG-2']);
  });

  test('pagination appends only unique older messages', () {
    final result = appendUniqueOlderChatMessages(
      existing: <ChatMessage>[message('MSG-3', 3), message('MSG-2', 2)],
      older: <ChatMessage>[message('MSG-2', 2), message('MSG-1', 1)],
    );

    expect(
      result.map((item) => item.id),
      <String>['MSG-3', 'MSG-2', 'MSG-1'],
    );
  });
}
