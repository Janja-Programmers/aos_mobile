part of 'chat_messages_controller.dart';

mixin ChatMessagesActions on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_actions
  // ---------------------------------------------------------------------------

  Future<bool> editMessage({
    required String messageId,
    required String content,
  }) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final cleanMessageId = messageId.trim();
    final cleanContent = content.trim();

    if (cleanMessageId.isEmpty ||
        cleanContent.isEmpty ||
        _editingMessageIds.contains(cleanMessageId)) {
      return false;
    }

    _editingMessageIds.add(cleanMessageId);
    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.editMessage(
        messageId: cleanMessageId,
        content: cleanContent,
      );
      if (!_isCurrentSession(generation)) return false;

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
    } finally {
      _editingMessageIds.remove(cleanMessageId);
    }
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteScope,
  }) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final ids = messageIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    final scope = deleteScope.trim().toLowerCase();

    if (ids.isEmpty || (scope != 'me' && scope != 'everyone')) {
      return false;
    }

    final actionKey = '$scope:${ids.join(',')}';
    if (!_deletingMessageKeys.add(actionKey)) return false;

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.deleteMessages(
        messageIds: ids,
        deleteScope: scope,
      );
      if (!_isCurrentSession(generation)) return false;

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
      if (!_isCurrentSession(generation)) return false;
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    } finally {
      _deletingMessageKeys.remove(actionKey);
    }
  }

  Future<bool> clearChat() async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.clearChat(conversationId);
      if (!_isCurrentSession(generation)) return false;

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      _messages.clear();
      _pendingSends.clear();
      _emitMessages();

      await ref.read(conversationsControllerProvider.notifier).load();
      if (!_isCurrentSession(generation)) return false;
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    }
  }

  Future<bool> toggleMessageStar(String messageId) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final cleanMessageId = messageId.trim();

    if (cleanMessageId.isEmpty ||
        _starringMessageIds.contains(cleanMessageId)) {
      return false;
    }

    if (!_messages.any((message) => message.id == cleanMessageId)) {
      return false;
    }

    _starringMessageIds.add(cleanMessageId);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final res = await repo.toggleMessageStar(cleanMessageId);
      if (!_isCurrentSession(generation)) return false;

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
    } finally {
      _starringMessageIds.remove(cleanMessageId);
    }
  }

  Future<bool> toggleMessageReaction({
    required String messageId,
    required String? emoji,
  }) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final cleanMessageId = messageId.trim();
    final cleanEmoji = emoji?.trim();

    if (cleanMessageId.isEmpty ||
        _reactingMessageIds.contains(cleanMessageId)) {
      return false;
    }

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) return false;

    _reactingMessageIds.add(cleanMessageId);
    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.toggleMessageReaction(
        messageId: cleanMessageId,
        emoji: cleanEmoji == null || cleanEmoji.isEmpty ? null : cleanEmoji,
      );
      if (!_isCurrentSession(generation)) return false;

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      final payload = res.rightOrNull ?? <String, dynamic>{};
      if (payload.isEmpty || payload['message_id'] == null) {
        _setActionError(
          const Failure(
            'Invalid reaction response from chat API',
            type: FailureType.parse,
          ),
        );
        return false;
      }

      _applyReactionPayload(payload);
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    } finally {
      _reactingMessageIds.remove(cleanMessageId);
    }
  }

  Future<bool> forwardMessage({
    required String messageId,
    required List<String> targetConversationIds,
  }) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final cleanMessageId = messageId.trim();

    final cleanTargets = targetConversationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && id != conversationId)
        .toSet()
        .toList(growable: false);

    if (cleanMessageId.isEmpty || cleanTargets.isEmpty) {
      return false;
    }
    if (!_forwardingMessageIds.add(cleanMessageId)) return false;

    final source = _messages.cast<ChatMessage?>().firstWhere(
      (message) => message?.id == cleanMessageId,
      orElse: () => null,
    );

    if (source == null ||
        source.id.startsWith('temp-') ||
        source.isLocalFailed ||
        source.isSystemMessage ||
        source.isDeletedType) {
      _forwardingMessageIds.remove(cleanMessageId);
      return false;
    }

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.forwardMessage(
        messageId: cleanMessageId,
        targetConversationIds: cleanTargets,
      );
      if (!_isCurrentSession(generation)) return false;

      if (res.isLeft) {
        _setActionError(res.leftOrNull ?? const Object());
        return false;
      }

      await ref.read(conversationsControllerProvider.notifier).load();
      if (!_isCurrentSession(generation)) return false;
      _clearActionError();
      return true;
    } catch (error, stackTrace) {
      _setActionError(error, stackTrace);
      return false;
    } finally {
      _forwardingMessageIds.remove(cleanMessageId);
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
