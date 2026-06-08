part of 'chat_messages_controller.dart';

mixin ChatMessagesHelpers on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_helpers
  // ---------------------------------------------------------------------------

  @override
  void _syncConversationPreview({
    required ChatMessage message,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  }) {
    ref
        .read(conversationsControllerProvider.notifier)
        .syncConversationWithMessage(
          conversationId: conversationId,
          message: message,
          fallbackUser: fallbackUser,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
          incrementUnread: false,
        );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  @override
  List<String> _readMessageIds(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }

  @override
  bool _isSameTemp(ChatMessage temp, ChatMessage real) {
    if (!temp.id.startsWith('temp-')) return false;
    if (temp.sender != real.sender) return false;

    final sameText = temp.content == real.content;
    final sameReply = temp.replyToMessage == real.replyToMessage;
    final sameAttachments = temp.attachments.length == real.attachments.length;

    return sameText && sameReply && sameAttachments;
  }

  @override
  void _applyEditedMessage(ChatMessage updated) {
    final index = _messages.indexWhere((message) => message.id == updated.id);

    if (index == -1) {
      _upsertMessage(updated);
      return;
    }

    final current = _messages[index];

    _messages[index] = current.copyWith(
      content: updated.content,
      messageType: updated.messageType,
      originalMessageType: updated.originalMessageType,
      isEdited: true,
      editedAt: updated.editedAt ?? DateTime.now(),

      // Keep stable UI fields from current message.
      senderDisplayName: updated.senderDisplayName ?? current.senderDisplayName,
      senderAvatar: updated.senderAvatar ?? current.senderAvatar,
      ad: updated.ad ?? current.ad,
      adPreview: updated.adPreview ?? current.adPreview,
      replyToMessage: updated.replyToMessage ?? current.replyToMessage,
      replyTo: updated.replyTo ?? current.replyTo,

      hasAttachments: updated.hasAttachments || current.hasAttachments,
      attachments: updated.attachments.isNotEmpty
          ? updated.attachments
          : current.attachments,

      reactions: updated.reactions.isNotEmpty
          ? updated.reactions
          : current.reactions,

      viewerState: updated.viewerState,

      clearTranslation: true,
    );

    _emitMessages();
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _readSyncDebounce?.cancel();

    _messageSub?.cancel();
    _messageStatusSub?.cancel();
    _messageEditedSub?.cancel();
    _messagesDeletedSub?.cancel();
    _messageReactionSub?.cancel();

    super.dispose();
  }
}
