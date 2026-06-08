part of 'chat_messages_controller.dart';

mixin ChatMessagesReadSync on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_read_sync
  // ---------------------------------------------------------------------------

  @override
  bool _isIncomingMessage(ChatMessage message) {
    final currentUser =
        ref.read(currentUserProvider)?.trim().toLowerCase() ?? '';

    if (currentUser.isEmpty) {
      return false;
    }

    return message.sender.trim().toLowerCase() != currentUser;
  }

  @override
  void _scheduleIncomingReadSync() {
    _readSyncDebounce?.cancel();

    _readSyncDebounce = Timer(const Duration(milliseconds: 250), () {
      _syncIncomingReadState();
    });
  }

  @override
  Future<void> _syncIncomingReadState() async {
    if (_isSyncingReadState) return;

    final incomingMessages = _messages.where(_isIncomingMessage).toList();

    if (incomingMessages.isEmpty) {
      ref
          .read(conversationsControllerProvider.notifier)
          .markConversationAsReadLocally(conversationId);
      return;
    }

    final hasUndeliveredIncoming = incomingMessages.any(
      (message) => message.deliveredAt == null,
    );

    final hasUnreadIncoming = incomingMessages.any(
      (message) => message.readAt == null,
    );

    if (!hasUndeliveredIncoming && !hasUnreadIncoming) {
      ref
          .read(conversationsControllerProvider.notifier)
          .markConversationAsReadLocally(conversationId);
      return;
    }

    _isSyncingReadState = true;

    try {
      final repo = ref.read(chatRepositoryProvider);

      if (hasUndeliveredIncoming) {
        final deliveredRes = await repo.markDelivered(conversationId);
        if (deliveredRes.isRight) {
          final update = deliveredRes.rightOrNull!;
          _applyDeliveredSyncResult(
            messageIds: update.messageIds,
            deliveredAt: update.deliveredAt,
          );
        }
      }

      if (hasUnreadIncoming) {
        final readRes = await repo.markRead(conversationId);
        if (readRes.isRight) {
          final update = readRes.rightOrNull!;
          _applyReadSyncResult(
            messageIds: update.messageIds,
            readAt: update.readAt,
          );

          ref
              .read(conversationsControllerProvider.notifier)
              .markConversationAsReadLocally(conversationId);
        }
      }
    } finally {
      _isSyncingReadState = false;
    }
  }

  void _applyDeliveredSyncResult({
    required List<String> messageIds,
    required DateTime? deliveredAt,
  }) {
    final fallbackTimestamp = deliveredAt ?? DateTime.now();
    final ids = messageIds.toSet();
    final shouldApplyByIds = ids.isNotEmpty;
    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!_isIncomingMessage(message)) continue;
      if (shouldApplyByIds && !ids.contains(message.id)) continue;
      if (message.deliveredAt != null) continue;

      _messages[i] = message.copyWith(deliveredAt: fallbackTimestamp);
      changed = true;
    }

    if (changed) {
      _emitMessages();
    }
  }

  void _applyReadSyncResult({
    required List<String> messageIds,
    required DateTime? readAt,
  }) {
    final fallbackTimestamp = readAt ?? DateTime.now();
    final ids = messageIds.toSet();
    final shouldApplyByIds = ids.isNotEmpty;
    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!_isIncomingMessage(message)) continue;
      if (shouldApplyByIds && !ids.contains(message.id)) continue;
      if (message.readAt != null && message.deliveredAt != null) continue;

      _messages[i] = message.copyWith(
        deliveredAt: message.deliveredAt ?? fallbackTimestamp,
        readAt: message.readAt ?? fallbackTimestamp,
      );
      changed = true;
    }

    if (changed) {
      _emitMessages();
    }
  }
}
