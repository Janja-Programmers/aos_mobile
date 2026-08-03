import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';

/// Removes duplicate backend/realtime message IDs without reordering messages.
List<ChatMessage> dedupeChatMessagesPreservingOrder(
  Iterable<ChatMessage> messages,
) {
  final seen = <String>{};
  final result = <ChatMessage>[];

  for (final message in messages) {
    final id = message.id.trim();
    if (id.isEmpty || !seen.add(id)) continue;
    result.add(message);
  }

  return List<ChatMessage>.unmodifiable(result);
}

/// Appends an older pagination page while preserving the current newest-first
/// order and ignoring messages already delivered by initial load or realtime.
List<ChatMessage> appendUniqueOlderChatMessages({
  required Iterable<ChatMessage> existing,
  required Iterable<ChatMessage> older,
}) {
  final result = dedupeChatMessagesPreservingOrder(existing).toList();
  final seen = result.map((message) => message.id).toSet();

  for (final message in older) {
    final id = message.id.trim();
    if (id.isEmpty || !seen.add(id)) continue;
    result.add(message);
  }

  return List<ChatMessage>.unmodifiable(result);
}
