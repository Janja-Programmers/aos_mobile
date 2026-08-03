part of 'chat_messages_controller.dart';

mixin ChatMessagesSending on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_sending
  // ---------------------------------------------------------------------------

  Future<bool> sendTempMessage({
    String? text,
    String? adId,
    String? adTitle,
    String? adPrice,
    String? adImage,
    String? adImageFileId,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
    String? replyToMessage,
    ChatReplyPreview? replyTo,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final safeSenderId = _activeCanonicalAccountId;

    if (safeSenderId.isEmpty) {
      return false;
    }

    final trimmedText = text?.trim();
    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = adId != null && adId.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) {
      return false;
    }

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';

    final validAttachments = attachments.where((attachment) {
      return attachment.fileId.trim().isNotEmpty &&
          attachment.type.trim().isNotEmpty;
    }).toList();

    final apiAttachments = validAttachments
        .map((attachment) => attachment.toApi())
        .toList();

    _pendingSends[tempId] = PendingSendPayload(
      tempId: tempId,
      text: trimmedText,
      ad: hasAd ? adId.trim() : null,
      replyToMessage: replyToMessage,
      replyTo: replyTo,
      attachments: apiAttachments,
      fallbackUser: fallbackUser,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );

    final tempMessage = _buildTempMessage(
      tempId: tempId,
      senderCanonicalId: safeSenderId,
      text: trimmedText,
      adId: hasAd ? adId : null,
      adTitle: adTitle,
      adPrice: adPrice,
      adImage: adImage,
      attachments: validAttachments,
      replyToMessage: replyToMessage,
      replyTo: replyTo,
    );

    _upsertMessage(tempMessage);

    final realMsg = await sendMessage(
      text: trimmedText,
      ad: hasAd ? adId : null,
      replyToMessage: replyToMessage,
      attachments: apiAttachments,
    );

    if (!_isCurrentSession(generation)) return true;

    if (realMsg == null) {
      _markTempMessageFailed(tempId, error: 'Failed to send. Tap to retry.');
      return true;
    }

    _upsertMessage(realMsg);
    _pendingSends.remove(tempId);

    _syncConversationPreview(
      message: realMsg,
      fallbackUser: fallbackUser,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );

    return true;
  }

  Future<ChatMessage?> sendMessage({
    String? text,
    String? ad,
    String? replyToMessage,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return null;

    final trimmedText = text?.trim();

    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = ad != null && ad.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) {
      return null;
    }

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: hasText ? trimmedText : null,
      ad: hasAd ? ad.trim() : null,
      replyToMessage: replyToMessage,
      attachments: List<Map<String, dynamic>>.from(attachments),
    );

    if (!_isCurrentSession(generation) || res.isLeft) return null;

    return res.rightOrNull;
  }

  Future<bool> retryMessage(String tempId) async {
    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return false;

    final payload = _pendingSends[tempId];

    if (payload == null) {
      _markTempMessageFailed(tempId, error: 'Could not retry this message.');
      return false;
    }

    final index = _messages.indexWhere((message) => message.id == tempId);

    if (index == -1) {
      return false;
    }

    _messages[index] = _messages[index].copyWith(
      localStatus: ChatLocalMessageStatus.sending,
      clearLocalError: true,
    );

    _emitMessages();

    final realMsg = await sendMessage(
      text: payload.text,
      ad: payload.ad,
      replyToMessage: payload.replyToMessage,
      attachments: payload.attachments,
    );

    if (!_isCurrentSession(generation)) return true;

    if (realMsg == null) {
      _markTempMessageFailed(tempId, error: 'Still failed. Tap to retry.');
      return false;
    }

    _upsertMessage(realMsg);
    _pendingSends.remove(tempId);

    _syncConversationPreview(
      message: realMsg,
      fallbackUser: payload.fallbackUser,
      fallbackDisplayName: payload.fallbackDisplayName,
      fallbackAvatar: payload.fallbackAvatar,
    );

    return true;
  }

  ChatMessage _buildTempMessage({
    required String tempId,
    required String senderCanonicalId,
    required String? text,
    required String? adId,
    required String? adTitle,
    required String? adPrice,
    required String? adImage,
    required List<ChatInputAttachment> attachments,
    String? replyToMessage,
    ChatReplyPreview? replyTo,
  }) {
    final tempAttachments = attachments.asMap().entries.map((entry) {
      final index = entry.key;
      final attachment = entry.value;

      return ChatAttachment(
        url: attachment.previewUrl.trim().isNotEmpty
            ? attachment.previewUrl.trim()
            : attachment.fileId.trim(),
        type: attachment.type.trim(),
        sortOrder: index,
      );
    }).toList();

    final tempAdPreview = adId != null
        ? {'title': adTitle, 'price': adPrice, 'image': adImage}
        : null;

    return ChatMessage.temp(
      id: tempId,
      senderCanonicalId: senderCanonicalId,
      content: text,
      attachments: tempAttachments,
      ad: adId,
      adPreview: tempAdPreview,
      replyToMessage: replyToMessage,
      replyTo: replyTo,
    ).copyWith(
      localStatus: ChatLocalMessageStatus.sending,
      clearLocalError: true,
    );
  }

  void _markTempMessageFailed(String tempId, {required String error}) {
    final index = _messages.indexWhere((message) => message.id == tempId);

    if (index == -1) return;

    _messages[index] = _messages[index].copyWith(
      localStatus: ChatLocalMessageStatus.failed,
      localError: error,
    );

    _emitMessages();
  }
}
