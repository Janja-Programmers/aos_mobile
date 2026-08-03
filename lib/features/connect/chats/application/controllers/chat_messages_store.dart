part of 'chat_messages_controller.dart';

mixin ChatMessagesStore on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_store
  // ---------------------------------------------------------------------------

  @override
  void _replaceWithServerMessages(List<ChatMessage> serverMessages) {
    final authoritative = dedupeChatMessagesPreservingOrder(serverMessages);
    if (_messages.isEmpty) {
      _messages.addAll(authoritative);
      return;
    }

    // Realtime delivery starts before the initial request so no event is lost.
    // Preserve messages received while that request was in flight, while using
    // the server payload for duplicate IDs and reconciling matching optimistic
    // messages in place.
    final remaining = <String, ChatMessage>{
      for (final message in authoritative) message.id: message,
    };
    final merged = <ChatMessage>[];

    for (final existing in _messages) {
      final sameId = remaining.remove(existing.id);
      if (sameId != null) {
        merged.add(sameId);
        continue;
      }

      ChatMessage? matchingServerMessage;
      String? matchingServerId;
      if (existing.isLocalOnly) {
        for (final entry in remaining.entries) {
          if (_isSameTemp(existing, entry.value)) {
            matchingServerId = entry.key;
            matchingServerMessage = entry.value;
            break;
          }
        }
      }

      if (matchingServerMessage != null && matchingServerId != null) {
        remaining.remove(matchingServerId);
        _pendingSends.remove(existing.id);
        merged.add(matchingServerMessage);
      } else {
        merged.add(existing);
      }
    }

    merged.addAll(remaining.values);
    _messages
      ..clear()
      ..addAll(dedupeChatMessagesPreservingOrder(merged));
  }

  @override
  void _appendOlderServerMessages(List<ChatMessage> olderMessages) {
    if (olderMessages.isEmpty) return;

    final merged = appendUniqueOlderChatMessages(
      existing: _messages,
      older: olderMessages,
    );
    _messages
      ..clear()
      ..addAll(merged);
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

    _messages.insert(0, message);

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
}
