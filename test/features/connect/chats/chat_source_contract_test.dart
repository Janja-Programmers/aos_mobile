import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quick Messages are completely removed from Chat source', () {
    final quickReplies = File(
      'lib/features/connect/chats/presentation/widgets/chat_screen/'
      'chat_quick_replies.dart',
    );
    final chatSource = Directory('lib/features/connect/chats')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(quickReplies.existsSync(), isFalse);
    expect(chatSource, isNot(contains('ChatQuickReplies')));
    expect(chatSource.toLowerCase(), isNot(contains('quick messages')));
  });

  test('message alignment reads canonical account identity only', () {
    final screen = File(
      'lib/features/connect/chats/presentation/screens/chat_screen.dart',
    ).readAsStringSync();
    final messagesView = File(
      'lib/features/connect/chats/presentation/widgets/chat_screen/'
      'chat_messages_view.dart',
    ).readAsStringSync();
    final accountProvider = File(
      'lib/features/account/shared/providers/account_user_provider.dart',
    ).readAsStringSync();

    expect(screen, contains('currentCanonicalAccountIdProvider'));
    expect(messagesView, contains('isMessageOwnedBy'));
    expect(messagesView, isNot(contains('senderDisplayName ==')));
    expect(messagesView, isNot(contains('message.senderCanonicalId == currentUserId')));
    expect(accountProvider, contains("clean.startsWith('ACC-')"));
    expect(accountProvider, contains('auth is! AuthAuthenticated'));
    expect(screen, isNot(contains('currentUserProvider')));
  });

  test('copy action writes clipboard and shows accessible confirmation', () {
    final source = File(
      'lib/features/connect/chats/presentation/screens/chat_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Clipboard.setData'));
    expect(source, contains('chat_copied_to_clipboard'));
    expect(source, contains('liveRegion: true'));
  });

  test('duplicate submits and account switching have explicit guards', () {
    final actions = File(
      'lib/features/connect/chats/application/controllers/'
      'chat_messages_actions.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/features/connect/chats/application/controllers/'
      'chat_messages_controller.dart',
    ).readAsStringSync();

    expect(actions, contains('_editingMessageIds.contains'));
    expect(actions, contains('_reactingMessageIds.contains'));
    expect(actions, contains('_deletingMessageKeys.add'));
    expect(actions, contains('_forwardingMessageIds.add'));
    expect(controller, contains('_sessionGeneration'));
    expect(controller, contains('_clearAccountOwnedState'));
  });
  test('optimistic sender is assigned inside the authenticated controller', () {
    final sending = File(
      'lib/features/connect/chats/application/controllers/'
      'chat_messages_sending.dart',
    ).readAsStringSync();
    final screen = File(
      'lib/features/connect/chats/presentation/screens/chat_screen.dart',
    ).readAsStringSync();

    expect(sending, contains('final safeSenderId = _activeCanonicalAccountId'));
    expect(sending, isNot(contains('String? senderId')));
    expect(screen, isNot(contains('senderId: currentUserId')));
  });

}
