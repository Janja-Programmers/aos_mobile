part of 'chat_messages_controller.dart';

mixin ChatMessagesRealtime on ChatMessagesControllerBase {
  // ---------------------------------------------------------------------------
  // chat_messages_realtime
  // ---------------------------------------------------------------------------

  @override
  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    await _cancelRealtimeSubscriptions();

    _messageSub = realtime.messages.listen((data) {
      _handleRealtimeMessage(asJsonMap(data));
    });

    _messageStatusSub = realtime.messageStatus.listen((data) {
      _handleRealtimeMessageStatus(asJsonMap(data));
    });

    _messageEditedSub = realtime.messageEdited.listen((data) {
      _handleRealtimeMessageEdited(asJsonMap(data));
    });

    _messagesDeletedSub = realtime.messagesDeleted.listen((data) async {
      await _handleRealtimeMessagesDeleted(asJsonMap(data));
    });

    _messageReactionSub = realtime.messageReactionUpdated.listen((data) {
      _handleRealtimeReactionUpdated(asJsonMap(data));
    });
  }

  Future<void> _cancelRealtimeSubscriptions() async {
    await _messageSub?.cancel();
    await _messageStatusSub?.cancel();
    await _messageEditedSub?.cancel();
    await _messagesDeletedSub?.cancel();
    await _messageReactionSub?.cancel();

    _messageSub = null;
    _messageStatusSub = null;
    _messageEditedSub = null;
    _messagesDeletedSub = null;
    _messageReactionSub = null;
  }

  void _handleRealtimeMessage(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    final msgData = data['message'];

    if (msgData is! Map) return;

    final newMsg = ChatMessage.fromJson(asJsonMap(msgData));

    _upsertMessage(newMsg);

    if (_isIncomingMessage(newMsg)) {
      _scheduleIncomingReadSync();
    }
  }

  void _handleRealtimeMessageStatus(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    _applyMessageStatus(data);
  }

  void _handleRealtimeMessageEdited(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    final msgData = data['message'];

    if (msgData is! Map) return;

    final message = ChatMessage.fromJson(asJsonMap(msgData));

    _applyEditedMessage(message);
  }

  Future<void> _handleRealtimeMessagesDeleted(Map<String, dynamic> data) async {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    final ids = _readMessageIds(data['message_ids']);
    final displayText = data['display_text']?.toString();

    _markMessagesDeletedForEveryone(ids, displayText: displayText);

    await ref.read(conversationsControllerProvider.notifier).load();
  }

  void _handleRealtimeReactionUpdated(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    _applyReactionPayload(data);
  }

  // ---------------------------------------------------------------------------
  // Realtime payload appliers
  // ---------------------------------------------------------------------------

  void _applyMessageStatus(Map<String, dynamic> data) {
    final status = data['status']?.toString();
    final messageIds = asJsonList(
      data['message_ids'],
    ).map((Object? id) => id.toString()).toSet();

    if (status == null || messageIds.isEmpty) {
      return;
    }

    final deliveredAt = DateTime.tryParse(
      data['delivered_at']?.toString() ?? '',
    );

    final readAt = DateTime.tryParse(data['read_at']?.toString() ?? '');

    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];

      if (!messageIds.contains(message.id)) continue;

      if (status == 'delivered' && message.deliveredAt == null) {
        _messages[i] = message.copyWith(
          deliveredAt: deliveredAt ?? DateTime.now(),
        );

        changed = true;
      }

      if (status == 'read' && message.readAt == null) {
        final effectiveReadAt = readAt ?? DateTime.now();

        _messages[i] = message.copyWith(
          deliveredAt: message.deliveredAt ?? effectiveReadAt,
          readAt: effectiveReadAt,
        );

        changed = true;
      }
    }

    if (changed) {
      _emitMessages();
    }
  }

  @override
  void _applyReactionPayload(Map<String, dynamic> data) {
    final messageId = data['message_id']?.toString();

    if (messageId == null || messageId.isEmpty) return;

    final index = _messages.indexWhere((message) => message.id == messageId);

    if (index == -1) return;

    final current = _messages[index];

    final rawReactions = data['reactions'];

    final reactions = asJsonMapList(rawReactions)
        .map(ChatMessageReaction.fromJson)
        .where((reaction) => reaction.emoji.trim().isNotEmpty)
        .toList();

    final rawViewerState = data['viewer_state'];

    final viewerState = rawViewerState is Map
        ? ChatMessageViewerState.fromJson(asJsonMap(rawViewerState))
        : current.viewerState.copyWith(myReaction: data['emoji']?.toString());

    _messages[index] = current.copyWith(
      reactions: reactions,
      viewerState: current.viewerState.copyWith(
        myReaction: viewerState.myReaction,
      ),
    );

    _emitMessages();
  }
}
