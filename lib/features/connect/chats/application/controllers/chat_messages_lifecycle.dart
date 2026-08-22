part of 'chat_messages_controller.dart';

mixin ChatMessagesLifecycle on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> _initializeAuthenticatedSession(int generation) async {
    await _cancelRealtimeSubscriptions();
    if (!_isCurrentSession(generation)) return;

    await _listenRealtime();
    if (!_isCurrentSession(generation)) return;

    await loadInitial(sessionGeneration: generation);
  }

  Future<void> loadInitial({int? sessionGeneration}) async {
    final generation = sessionGeneration ?? _sessionGeneration;
    if (!_isCurrentSession(generation)) return;

    final repo = ref.read(chatRepositoryProvider);

    if (_messages.isEmpty) {
      state = state.asLoading();
    }

    final res = await repo.getMessages(conversationId: conversationId);
    if (!_isCurrentSession(generation)) return;

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

    final generation = _sessionGeneration;
    if (!_isCurrentSession(generation)) return;

    _isLoadingMore = true;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final repo = ref.read(chatRepositoryProvider);
      final oldest = _messages.last;

      final res = await repo.getMessages(
        conversationId: conversationId,
        before: oldest.id,
      );
      if (!_isCurrentSession(generation)) return;

      if (res.isLeft) {
        state = state.copyWith(
          isLoadingMore: false,
          error: res.leftOrNull,
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
      if (_isCurrentSession(generation)) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMoreMessages: _hasMoreMessages,
        );
      }
    }
  }

  Future<bool> ensureMessageLoaded(String messageId) async {
    final targetId = messageId.trim();
    if (targetId.isEmpty) return false;
    if (_messages.any((message) => message.id == targetId)) return true;

    while (_hasMoreMessages) {
      if (_isLoadingMore) return false;
      final previousCount = _messages.length;
      await loadMore();
      if (_messages.any((message) => message.id == targetId)) return true;
      if (state.hasError || _messages.length <= previousCount) break;
    }

    return false;
  }
}
