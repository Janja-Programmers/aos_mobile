import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conversation preview ownership uses canonical last sender id', () {
    final conversation = ChatConversation.fromJson(<String, dynamic>{
      'id': 'CONV-1',
      'user': 'acc-other',
      'display_name': 'Same Name',
      'last_sender': 'acc-current',
      'last_message': 'Hello',
      'unread_count': 0,
    });

    expect(conversation.user, 'ACC-OTHER');
    expect(conversation.lastSender, 'ACC-CURRENT');
    expect(conversation.isLastMessageMine('ACC-CURRENT'), isTrue);
    expect(conversation.isLastMessageMine('same-name@example.com'), isFalse);
  });
}
