part of 'chat_messages_controller.dart';

mixin ChatMessagesLifecycle on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_lifecycle
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    await _listenRealtime();
    await loadInitial();
  }

  Future<void> loadInitial() async {
    final repo = ref.read(chatRepositoryProvider);

    if (_messages.isEmpty) {
      state = state.asLoading();
    }

    final res = await repo.getMessages(conversationId: conversationId);

    if (res.isLeft) {
      if (_messages.isEmpty) {
        state = state.asError(res.leftOrNull!, StackTrace.current);
      }
      return;
    }

    final serverMessages = List<ChatMessage>.from(res.rightOrNull ?? []);

    _replaceWithServerMessages(serverMessages);
    _emitMessages();

    await _syncIncomingReadState();
  }

  Future<void> loadMore() async {
    if (_messages.isEmpty || _isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final repo = ref.read(chatRepositoryProvider);
      final oldest = _messages.last;

      final res = await repo.getMessages(
        conversationId: conversationId,
        before: oldest.id,
      );

      if (res.isLeft) {
        state = state.copyWith(
          isLoadingMore: false,
          error: res.leftOrNull!,
          stackTrace: StackTrace.current,
        );
        return;
      }

      final olderMessages = List<ChatMessage>.from(res.rightOrNull ?? []);

      if (olderMessages.isEmpty) {
        _hasMoreMessages = false;
        state = state.copyWith(
          isLoadingMore: false,
          hasMoreMessages: false,
          clearError: true,
        );
        return;
      }

      _appendOlderServerMessages(olderMessages);
      _emitMessages();
    } finally {
      _isLoadingMore = false;
      if (mounted) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMoreMessages: _hasMoreMessages,
        );
      }
    }
  }
}
