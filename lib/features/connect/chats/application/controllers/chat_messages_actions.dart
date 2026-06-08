part of 'chat_messages_controller.dart';

mixin ChatMessagesActions on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_actions
  // ---------------------------------------------------------------------------

  Future<bool> editMessage({
    required String messageId,
    required String content,
  }) async {
    final cleanMessageId = messageId.trim();
    final cleanContent = content.trim();

    if (cleanMessageId.isEmpty || cleanContent.isEmpty) {
      return false;
    }

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.editMessage(
        messageId: cleanMessageId,
        content: cleanContent,
      );

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      final updated = res.rightOrNull;
      if (updated == null || updated.id.trim().isEmpty) {
        _setActionError(StateError('Edit returned an empty message.'));
        return false;
      }

      _applyEditedMessage(updated);
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteScope,
  }) async {
    final ids = messageIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    final scope = deleteScope.trim().toLowerCase();

    if (ids.isEmpty || (scope != 'me' && scope != 'everyone')) {
      return false;
    }

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.deleteMessages(
        messageIds: ids,
        deleteScope: scope,
      );

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      final data = res.rightOrNull ?? <String, dynamic>{};

      final returnedIds = _readMessageIds(data['message_ids']);
      final effectiveIds = returnedIds.isEmpty ? ids : returnedIds;

      final returnedScope = (data['delete_scope']?.toString() ?? scope)
          .trim()
          .toLowerCase();
      final displayText = data['display_text']?.toString();

      if (returnedScope == 'everyone') {
        _markMessagesDeletedForEveryone(effectiveIds, displayText: displayText);
      } else {
        _removeMessages(effectiveIds);
      }

      await ref.read(conversationsControllerProvider.notifier).load();
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  Future<bool> clearChat() async {
    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.clearChat(conversationId);

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      _messages.clear();
      _pendingSends.clear();
      _emitMessages();

      await ref.read(conversationsControllerProvider.notifier).load();
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  Future<bool> toggleMessageStar(String messageId) async {
    final cleanMessageId = messageId.trim();

    if (cleanMessageId.isEmpty) return false;

    if (!_messages.any((message) => message.id == cleanMessageId)) {
      return false;
    }

    try {
      final repo = ref.read(chatRepositoryProvider);
      final res = await repo.toggleMessageStar(cleanMessageId);

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      final index = _messages.indexWhere(
        (message) => message.id == cleanMessageId,
      );

      if (index == -1) return false;

      final current = _messages[index];

      _messages[index] = current.copyWith(
        viewerState: current.viewerState.copyWith(
          isStarred: res.rightOrNull ?? !current.isStarred,
        ),
      );

      _emitMessages();
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  Future<bool> toggleMessageReaction({
    required String messageId,
    required String? emoji,
  }) async {
    final cleanMessageId = messageId.trim();
    final cleanEmoji = emoji?.trim();

    if (cleanMessageId.isEmpty) return false;

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) return false;

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.toggleMessageReaction(
        messageId: cleanMessageId,
        emoji: cleanEmoji == null || cleanEmoji.isEmpty ? null : cleanEmoji,
      );

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      final payload = res.rightOrNull ?? <String, dynamic>{};

      if (payload.isNotEmpty) {
        _applyReactionPayload(payload);
      } else {
        // Keep the UI responsive even if the backend returns only an OK wrapper.
        final currentIndex = _messages.indexWhere(
          (message) => message.id == cleanMessageId,
        );
        if (currentIndex != -1) {
          final current = _messages[currentIndex];
          _messages[currentIndex] = current.copyWith(
            viewerState: current.viewerState.copyWith(myReaction: cleanEmoji),
          );
          _emitMessages();
        }
      }

      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  Future<bool> forwardMessage({
    required String messageId,
    required List<String> targetConversationIds,
  }) async {
    final cleanMessageId = messageId.trim();

    final cleanTargets = targetConversationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && id != conversationId)
        .toSet()
        .toList(growable: false);

    if (cleanMessageId.isEmpty || cleanTargets.isEmpty) {
      return false;
    }

    final source = _messages.cast<ChatMessage?>().firstWhere(
      (message) => message?.id == cleanMessageId,
      orElse: () => null,
    );

    if (source == null ||
        source.id.startsWith('temp-') ||
        source.isLocalFailed ||
        source.isSystemMessage ||
        source.isDeletedType) {
      return false;
    }

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.forwardMessage(
        messageId: cleanMessageId,
        targetConversationIds: cleanTargets,
      );

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      await ref.read(conversationsControllerProvider.notifier).load();
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  void _setActionError(Object error, [StackTrace? stackTrace]) {
    state = state.copyWith(
      actionError: error,
      actionStackTrace: stackTrace ?? StackTrace.current,
    );
  }

  void _clearActionError() {
    if (!state.hasActionError) return;
    state = state.copyWith(clearActionError: true);
  }
}
