import 'dart:async';

import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_service_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';

final chatMessagesControllerProvider =
    StateNotifierProvider.family<
      ChatMessagesController,
      AsyncValue<List<ChatMessage>>,
      String
    >((ref, conversationId) {
      return ChatMessagesController(ref, conversationId);
    });

class ChatMessagesController
    extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref ref;
  final String conversationId;
  late final String currentUser;

  ChatMessagesController(this.ref, this.conversationId)
    : super(const AsyncLoading()) {
    currentUser = ref.read(currentUserProvider) ?? "";

    _init();
  }

  final List<ChatMessage> _messages = [];
  StreamSubscription? _messageSub;

  Future<void> _init() async {
    await loadInitial();
    await _listenRealtime();
  }

  // -----------------------------
  // Initial Load
  // -----------------------------
  Future<void> loadInitial() async {
    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.getMessages(conversationId: conversationId);

    if (res.isLeft) {
      state = AsyncError(res.leftOrNull!, StackTrace.current);
      return;
    }

    _messages
      ..clear()
      ..addAll(res.rightOrNull!.reversed);

    state = AsyncData(List.of(_messages));

    await repo.markRead(conversationId);
  }

  // -----------------------------
  // Pagination
  // -----------------------------
  Future<void> loadMore() async {
    if (_messages.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);
    final oldest = _messages.first;

    final res = await repo.getMessages(
      conversationId: conversationId,
      before: oldest.id,
    );

    if (res.isLeft) return;

    _messages.insertAll(0, res.rightOrNull!.reversed);
    state = AsyncData(List.of(_messages));
  }

  // -----------------------------
  // Optimistic Send
  // -----------------------------
  Future<void> sendTempMessage({
    String? text,
    String? ad,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    final trimmedText = text?.trim();
    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;

    if (!hasText && !hasAttachments) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    // 🔥 Convert to API format
    final apiAttachments = attachments.map((a) => a.toApi(ad: '')).toList();

    final tempMsg = ChatMessage(
      id: tempId,
      sender: currentUser,
      content: hasText ? trimmedText : null,
      messageType: hasText && hasAttachments
          ? 'mixed'
          : hasAttachments
          ? 'attachment'
          : 'text',
      ad: ad,
      hasAttachments: hasAttachments,
      createdAt: DateTime.now(),
      deliveredAt: null,
      readAt: null,

      // 🔥 FIXED: use previewUrl
      attachments: attachments
          .map(
            (a) =>
                ChatAttachment(url: a.previewUrl, type: a.type, sortOrder: 0),
          )
          .toList(),
    );

    // 1. Add temp
    _messages.add(tempMsg);
    state = AsyncData(List.of(_messages));

    // 2. Send
    final realMsg = await sendMessage(
      text: trimmedText,
      ad: ad,
      attachments: apiAttachments,
    );

    // ❌ Only remove temp if send failed
    if (realMsg == null) {
      _messages.removeWhere((m) => m.id == tempId);
      state = AsyncData(List.of(_messages));
      return;
    }
  }

  // -----------------------------
  // Send Message
  // -----------------------------
  Future<ChatMessage?> sendMessage({
    String? text,
    String? ad,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final repo = ref.read(chatRepositoryProvider);

    final trimmedText = text?.trim();
    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;

    if (!hasText && !hasAttachments) return null;

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: hasText ? trimmedText : null,
      attachments: attachments,
    );

    if (res.isLeft) return null;

    return ChatMessage(
      id: 'server-${DateTime.now().millisecondsSinceEpoch}',
      sender: currentUser,
      content: hasText ? trimmedText : null,
      messageType: hasText && hasAttachments
          ? 'mixed'
          : hasAttachments
          ? 'attachment'
          : 'text',
      ad: ad,
      hasAttachments: hasAttachments,
      createdAt: DateTime.now(),
      deliveredAt: DateTime.now(),
      readAt: null,
      attachments: const [],
    );
  }

  // -----------------------------
  // Realtime Listener
  // -----------------------------
  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);
    final repo = ref.read(chatRepositoryProvider);

    await _messageSub?.cancel();

    _messageSub = realtime.messages.listen((data) async {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;

      final msgData = data['message'];
      if (msgData == null) return;

      final newMsg = ChatMessage.fromJson(msgData);

      _messages.removeWhere((m) => _isSameTemp(m, newMsg));

      if (_isDuplicate(newMsg)) return;

      _messages.add(newMsg);
      state = AsyncData(List.of(_messages));

      // Optional ACK to server
      realtime.sendMessageAck({
        'conversation_id': conversationId,
        'message_id': newMsg.id,
      });

      await repo.markDelivered(conversationId);
    });
  }

  bool _isDuplicate(ChatMessage newMsg) {
    return _messages.any((m) => m.id == newMsg.id);
  }

  bool _isSameTemp(ChatMessage temp, ChatMessage real) {
    if (!temp.id.startsWith('temp-')) return false;
    if (temp.sender != real.sender) return false;

    // Text match
    final sameText = temp.content == real.content;

    // Attachment match (count-based, simple but effective)
    final sameAttachments = temp.attachments.length == real.attachments.length;

    return sameText && sameAttachments;
  }

  // -----------------------------
  // Dispose
  // -----------------------------
  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }
}
