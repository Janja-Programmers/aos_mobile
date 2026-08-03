import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reaction payload parsing preserves authoritative counts and viewer state', () {
    final message = ChatMessage.fromJson(<String, dynamic>{
      'id': 'MSG-REACTION',
      'sender': 'ACC-OTHER',
      'message_type': 'text',
      'content': 'Hello',
      'created_at': '2026-01-12T09:00:00Z',
      'viewer_state': <String, dynamic>{'my_reaction': '👍'},
      'reactions': <Map<String, dynamic>>[
        <String, dynamic>{
          'emoji': '👍',
          'count': 3,
          'reacted_by_me': true,
        },
      ],
    });

    expect(message.myReaction, '👍');
    expect(message.reactions.single.emoji, '👍');
    expect(message.reactions.single.count, 3);
    expect(message.reactions.single.reactedByMe, isTrue);
  });

  test('star state changes without changing canonical sender ownership', () {
    final message = ChatMessage.fromJson(<String, dynamic>{
      'id': 'MSG-STAR',
      'sender': 'ACC-CURRENT',
      'message_type': 'text',
      'content': 'Keep me',
      'created_at': '2026-01-12T09:00:00Z',
      'viewer_state': <String, dynamic>{'is_starred': false},
    });

    final starred = message.copyWith(
      viewerState: message.viewerState.copyWith(isStarred: true),
    );

    expect(starred.isStarred, isTrue);
    expect(starred.senderCanonicalId, 'ACC-CURRENT');
    expect(starred.content, 'Keep me');
  });
}
