import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';
import 'package:africaonlinestores/features/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/chats/repository/chat_repository_impl.dart';

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
    state = AsyncData(_messages);

    // mark delivery + read
    await repo.markDelivered(conversationId);
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
    state = AsyncData(_messages);
  }

  // -----------------------------
  // Send Message
  // -----------------------------
  Future<ChatMessage?> sendMessage(String text) async {
    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: text,
    );

    if (res.isLeft) return null;

    return ChatMessage(
      id: 'server-${DateTime.now().millisecondsSinceEpoch}',
      sender: currentUser,
      content: text,
      messageType: 'text',
      ad: null,
      hasAttachments: false,
      createdAt: DateTime.now(),
      deliveredAt: DateTime.now(),
      readAt: null,
      attachments: [],
    );
  }

  // -----------------------------
  // Optimistic Send
  // -----------------------------
  Future<void> sendTempMessage(String text) async {
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    final tempMsg = ChatMessage(
      id: tempId,
      sender: currentUser,
      content: text,
      messageType: 'text',
      ad: null,
      hasAttachments: false,
      createdAt: DateTime.now(),
      deliveredAt: null,
      readAt: null,
      attachments: [],
    );

    // 1. Add temp
    _messages.add(tempMsg);
    state = AsyncData(_messages);

    // 2. Send
    final realMsg = await sendMessage(text);

    if (realMsg == null) {
      _messages.removeWhere((m) => m.id == tempId);
      state = AsyncData(_messages);
      return;
    }

    // 3. Replace temp safely
    final index = _messages.indexWhere((m) => m.id == tempId);
    if (index != -1) _messages[index] = realMsg;

    state = AsyncData(_messages);
  }

  // -----------------------------
  // Realtime Listener
  // -----------------------------
  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    // Wait until socket is connected
    while (!realtime.isConnected) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _messageSub = realtime.messages.listen((data) {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;

      final msgData = data['message'];
      final newMsg = ChatMessage.fromJson(msgData);

      // Deduplicate
      if (_isDuplicate(newMsg)) return;

      _messages.add(newMsg);
      state = AsyncData(_messages);

      // Fire-and-forget delivery
      ref.read(chatRepositoryProvider).markDelivered(conversationId);
    });
  }

  bool _isDuplicate(ChatMessage newMsg) {
    return _messages.any(
      (m) =>
          m.id == newMsg.id ||
          (m.sender == newMsg.sender &&
              m.content == newMsg.content &&
              (m.createdAt.difference(newMsg.createdAt).inSeconds.abs() < 5)),
    );
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
