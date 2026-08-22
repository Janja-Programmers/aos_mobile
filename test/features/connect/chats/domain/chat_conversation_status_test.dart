import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conversation parses authoritative last-message status fields', () {
    final conversation = ChatConversation.fromJson(<String, dynamic>{
      'id': 'CONV-1',
      'user': 'ACC-OTHER',
      'display_name': 'Other user',
      'last_message_id': 'MSG-9',
      'last_message': 'Hello',
      'last_message_delivered_at': '2026-08-21 12:00:00',
      'last_message_read_at': '2026-08-21 12:01:00',
      'unread_count': 0,
    });

    expect(conversation.lastMessageId, 'MSG-9');
    expect(conversation.lastMessageDeliveredAt, isNotNull);
    expect(conversation.lastMessageReadAt, isNotNull);
  });

  test('status event updates only the exact last message id', () {
    final conversation = ChatConversation(
      id: 'CONV-1',
      user: 'ACC-OTHER',
      displayName: 'Other user',
      lastMessage: 'Newest',
      lastMessageId: 'MSG-NEWEST',
      unreadCount: 0,
    );
    final deliveredAt = DateTime.utc(2026, 8, 21, 12);

    final stale = conversation.applyLastMessageStatus(
      messageIds: const <String>{'MSG-OLDER'},
      deliveredAt: deliveredAt,
    );
    final matching = conversation.applyLastMessageStatus(
      messageIds: const <String>{'MSG-NEWEST'},
      deliveredAt: deliveredAt,
    );

    expect(stale.lastMessageDeliveredAt, isNull);
    expect(stale.lastMessageReadAt, isNull);
    expect(matching.lastMessageDeliveredAt, deliveredAt);
    expect(matching.lastMessageReadAt, isNull);
  });

  test('read timestamp also implies delivery for the same last message', () {
    final readAt = DateTime.utc(2026, 8, 21, 12, 1);
    final conversation = ChatConversation(
      id: 'CONV-1',
      user: 'ACC-OTHER',
      displayName: 'Other user',
      lastMessageId: 'MSG-1',
      unreadCount: 0,
    );

    final updated = conversation.applyLastMessageStatus(
      messageIds: const <String>{'MSG-1'},
      readAt: readAt,
    );

    expect(updated.lastMessageDeliveredAt, readAt);
    expect(updated.lastMessageReadAt, readAt);
  });
}
