import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses backend sender and viewer state without display-name ownership', () {
    final message = ChatMessage.fromJson(<String, dynamic>{
      'id': 'MSG-1',
      'sender': 'acc-2026-00001',
      'sender_display_name': 'Changed Name',
      'message_type': 'text',
      'content': 'Original',
      'created_at': '2026-01-12T09:00:00Z',
      'viewer_state': <String, dynamic>{
        'is_starred': true,
        'my_reaction': '❤️',
      },
      'reactions': <Map<String, dynamic>>[
        <String, dynamic>{'emoji': '❤️', 'count': 2, 'reacted_by_me': true},
      ],
    });

    expect(message.senderCanonicalId, 'ACC-2026-00001');
    expect(message.senderDisplayName, 'Changed Name');
    expect(message.isStarred, isTrue);
    expect(message.myReaction, '❤️');
    expect(message.reactions.single.count, 2);
  });

  test('unknown message types stay explicit and invalid dates are stable', () {
    final first = ChatMessage.fromJson(<String, dynamic>{
      'id': 'MSG-X',
      'sender': 'ACC-X',
      'message_type': 'future_type',
      'created_at': 'not-a-date',
    });
    final second = ChatMessage.fromJson(<String, dynamic>{
      'id': 'MSG-X',
      'sender': 'ACC-X',
      'message_type': 'future_type',
    });

    expect(first.messageType, 'unknown');
    expect(first.createdAt, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
    expect(second.createdAt, first.createdAt);
  });

  test('edit and translation preserve sender and original content', () {
    final original = ChatMessage.fromJson(<String, dynamic>{
      'id': 'MSG-2',
      'sender': 'ACC-1',
      'message_type': 'text',
      'content': 'Hello',
      'created_at': '2026-01-12T09:00:00Z',
    });

    final translated = original.copyWith(
      translatedContent: 'Hallo',
      translationLanguage: 'German',
    );
    final edited = translated.copyWith(
      content: 'Hello there',
      isEdited: true,
      editedAt: DateTime.utc(2026, 1, 12, 9, 5),
      clearTranslation: true,
    );

    expect(translated.content, 'Hello');
    expect(translated.translatedContent, 'Hallo');
    expect(edited.senderCanonicalId, 'ACC-1');
    expect(edited.content, 'Hello there');
    expect(edited.translatedContent, isNull);
  });
}
