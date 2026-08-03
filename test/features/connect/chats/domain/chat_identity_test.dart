import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatMessage message({required String sender}) {
    return ChatMessage(
      id: 'MSG-1',
      senderCanonicalId: sender,
      messageType: 'text',
      hasAttachments: false,
      createdAt: DateTime.utc(2026, 1, 12),
      attachments: const [],
      content: 'Hello',
    );
  }

  test('canonical sender id is the only ownership signal', () {
    final mine = message(sender: 'acc-2026-00001');

    expect(
      isMessageOwnedBy(
        message: mine,
        authenticatedCanonicalId: 'ACC-2026-00001',
      ),
      isTrue,
    );
    expect(
      isMessageOwnedBy(
        message: mine,
        authenticatedCanonicalId: 'same-display-name@example.com',
      ),
      isFalse,
    );
    expect(normalizeCanonicalUserId('same-display-name@example.com'), isEmpty);
  });

  test('account switching re-derives ownership instead of caching isMine', () {
    final accountAMessage = message(sender: 'ACC-A');

    expect(
      isMessageOwnedBy(
        message: accountAMessage,
        authenticatedCanonicalId: 'ACC-A',
      ),
      isTrue,
    );
    expect(
      isMessageOwnedBy(
        message: accountAMessage,
        authenticatedCanonicalId: 'ACC-B',
      ),
      isFalse,
    );
  });

  test('optimistic message stores normalized canonical sender id', () {
    final optimistic = ChatMessage.temp(
      id: 'temp-1',
      senderCanonicalId: ' acc-2026-00002 ',
      content: 'Sending',
    );

    expect(optimistic.senderCanonicalId, 'ACC-2026-00002');
    expect(
      isMessageOwnedBy(
        message: optimistic,
        authenticatedCanonicalId: 'ACC-2026-00002',
      ),
      isTrue,
    );
  });
}
