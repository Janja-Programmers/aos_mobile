part of 'chat_messages_controller.dart';

mixin ChatMessagesStore on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_store
  // ---------------------------------------------------------------------------

  @override
  void _replaceWithServerMessages(List<ChatMessage> serverMessages) {
    _messages
      ..clear()
      ..addAll(_dedupePreservingOrder(serverMessages));
  }

  @override
  void _appendOlderServerMessages(List<ChatMessage> olderMessages) {
    if (olderMessages.isEmpty) return;

    final existingIds = _messages.map((message) => message.id).toSet();

    for (final message in olderMessages) {
      if (existingIds.add(message.id)) {
        _messages.add(message);
      }
    }
  }

  @override
  void _upsertMessage(ChatMessage message, {bool emit = true}) {
    final existingIndex = _messages.indexWhere(
      (existing) => existing.id == message.id,
    );

    if (existingIndex != -1) {
      _messages[existingIndex] = message;
      if (emit) _emitMessages();
      return;
    }

    final tempIndex = _messages.indexWhere(
      (existing) => _isSameTemp(existing, message),
    );

    if (tempIndex != -1) {
      final tempId = _messages[tempIndex].id;

      _messages[tempIndex] = message;
      _pendingSends.remove(tempId);

      if (emit) _emitMessages();
      return;
    }

    if (message.id.startsWith('temp-')) {
      _messages.insert(0, message);
    } else {
      _messages.insert(0, message);
    }

    if (emit) _emitMessages();
  }

  @override
  void _removeMessages(List<String> messageIds) {
    if (messageIds.isEmpty) return;

    final ids = messageIds.toSet();

    _messages.removeWhere((message) => ids.contains(message.id));

    for (final id in ids) {
      _pendingSends.remove(id);
    }

    _emitMessages();
  }

  @override
  void _markMessagesDeletedForEveryone(
    List<String> messageIds, {
    String? displayText,
  }) {
    if (messageIds.isEmpty) return;

    final ids = messageIds.toSet();
    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];

      if (!ids.contains(message.id)) continue;

      _messages[i] = message.asDeletedPlaceholder(displayText: displayText);

      changed = true;
    }

    if (changed) {
      _emitMessages();
    }
  }

  @override
  void _emitMessages() {
    state = state
        .asData(_messages)
        .copyWith(
          isLoadingMore: _isLoadingMore,
          hasMoreMessages: _hasMoreMessages,
        );
  }

  List<ChatMessage> _dedupePreservingOrder(List<ChatMessage> messages) {
    final seen = <String>{};
    final result = <ChatMessage>[];

    for (final message in messages) {
      if (seen.add(message.id)) {
        result.add(message);
      }
    }

    return result;
  }
}
