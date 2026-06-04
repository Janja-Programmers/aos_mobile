part of 'chat_messages_controller.dart';

mixin ChatMessagesTranslation on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_translation
  // ---------------------------------------------------------------------------

  bool isTranslatingMessage(String messageId) {
    return _translatingMessageIds.contains(messageId.trim());
  }

  String? translationErrorFor(String messageId) {
    return _translationErrors[messageId.trim()];
  }

  Future<bool> translateMessage({
    required String messageId,
    required String targetLanguage,
  }) async {
    final cleanMessageId = messageId.trim();
    final cleanTargetLanguage = targetLanguage.trim();

    if (cleanMessageId.isEmpty || cleanTargetLanguage.isEmpty) {
      return false;
    }

    if (_translatingMessageIds.contains(cleanMessageId)) {
      return false;
    }

    _translatingMessageIds.add(cleanMessageId);
    _translationErrors.remove(cleanMessageId);
    _setMessageTranslationState(
      cleanMessageId,
      isTranslating: true,
      clearError: true,
    );

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.translateMessage(
      messageId: cleanMessageId,
      targetLanguage: cleanTargetLanguage,
    );

    _translatingMessageIds.remove(cleanMessageId);

    if (res.isLeft) {
      _translationErrors[cleanMessageId] = 'Failed to translate message.';
      _setMessageTranslationState(
        cleanMessageId,
        isTranslating: false,
        error: 'Failed to translate message.',
      );
      return false;
    }

    final data = res.rightOrNull ?? <String, dynamic>{};

    final translatedContent = data['translated_content']?.toString().trim();
    final translationLanguage =
        data['target_language_label']?.toString().trim() ??
        data['target_language']?.toString().trim();

    if (translatedContent == null || translatedContent.isEmpty) {
      _translationErrors[cleanMessageId] = 'No translation returned.';
      _setMessageTranslationState(
        cleanMessageId,
        isTranslating: false,
        error: 'No translation returned.',
      );
      return false;
    }

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) {
      _emitMessages();
      return false;
    }

    final current = _messages[index];

    _messages[index] = current.copyWith(
      translatedContent: translatedContent,
      translationLanguage: translationLanguage,
      isTranslating: false,
      clearTranslationError: true,
    );

    _translationErrors.remove(cleanMessageId);
    _emitMessages();

    return true;
  }

  void clearMessageTranslation(String messageId) {
    final cleanMessageId = messageId.trim();

    if (cleanMessageId.isEmpty) return;

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) return;

    _messages[index] = _messages[index].copyWith(
      clearTranslation: true,
      isTranslating: false,
      clearTranslationError: true,
    );

    _translationErrors.remove(cleanMessageId);
    _emitMessages();
  }

  void _setMessageTranslationState(
    String messageId, {
    required bool isTranslating,
    String? error,
    bool clearError = false,
  }) {
    final index = _messages.indexWhere((message) => message.id == messageId);

    if (index == -1) {
      _emitMessages();
      return;
    }

    _messages[index] = _messages[index].copyWith(
      isTranslating: isTranslating,
      translationError: error,
      clearTranslationError: clearError,
    );

    _emitMessages();
  }
}
