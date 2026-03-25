import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';
import 'package:africaonlinestores/features/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/chats/domain/chat_message.dart';

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
    loadInitial();
    _listenRealtime();
  }

  List<ChatMessage> _messages = [];

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

    _messages = res.rightOrNull!.reversed.toList();
    state = AsyncData(_messages);

    // delivery + read
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

    _messages = [...res.rightOrNull!.reversed, ..._messages];
    state = AsyncData(_messages);
  }

  // -----------------------------
  // Send Message (server)
  // -----------------------------
  Future<ChatMessage?> sendMessage(String text) async {
    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: text,
    );

    if (res.isLeft) {
      return null;
    }

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
  // Send Temp Message (optimistic)
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

    // 1. Add temp message
    _messages = [..._messages, tempMsg];
    state = AsyncData(_messages);

    // 2. Send to server
    final realMsg = await sendMessage(text);

    if (realMsg == null) {
      // ❌ failed → remove temp message
      _messages = _messages.where((m) => m.id != tempId).toList();
      state = AsyncData(_messages);
      return;
    }

    // 3. Replace temp with real
    _messages = _messages.map((m) {
      if (m.id == tempId) {
        return realMsg;
      }
      return m;
    }).toList();
    state = AsyncData(_messages);
  }

  // -----------------------------
  // Realtime listener
  // -----------------------------
  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    realtime.onNewMessage((data) {
      final convId = data['conversation_id'];

      // ✅ Ignore other conversations
      if (convId != conversationId) return;

      final msgData = data['message'];
      final newMsg = ChatMessage.fromJson(msgData);

      // 🔥 Deduplication (CRITICAL)
      if (_isDuplicate(newMsg)) return;

      _messages = [..._messages, newMsg];
      state = AsyncData(_messages);

      // ✅ mark delivered (fire-and-forget)
      ref.read(chatRepositoryProvider).markDelivered(conversationId);
    });
  }

  bool _isDuplicate(ChatMessage newMsg) {
    return _messages.any(
      (m) =>
          m.id == newMsg.id ||
          (m.content == newMsg.content &&
              m.sender == newMsg.sender &&
              (m.createdAt.difference(newMsg.createdAt).inSeconds.abs() < 5)),
    );
  }

  @override
  void dispose() {
    ref.read(chatRealtimeServiceProvider).removeNewMessageListener();
    super.dispose();
  }
}
