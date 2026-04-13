import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_service_providers.dart';
import 'package:africaonlinestores/features/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/chats/domain/chat_conversation.dart';

final chatConversationsControllerProvider =
    StateNotifierProvider<
      ChatConversationsController,
      AsyncValue<List<ChatConversation>>
    >((ref) => ChatConversationsController(ref));

class ChatConversationsController
    extends StateNotifier<AsyncValue<List<ChatConversation>>> {
  final Ref ref;
  late final String _currentUser;
  StreamSubscription? _messageSub;

  ChatConversationsController(this.ref) : super(const AsyncData([])) {
    _init();
  }

  // -----------------------------
  // Init
  // -----------------------------
  Future<void> _init() async {
    _currentUser = ref.read(currentUserProvider) ?? "";

    await load();
    await _subscribeToRealtime();
  }

  // -----------------------------
  // Load conversations
  // -----------------------------
  Future<void> load() async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.getConversations();

    if (res.isLeft) {
      state = AsyncError(res.leftOrNull!, StackTrace.current);
    } else {
      state = AsyncData(res.rightOrNull!);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await load();
  }

  //
  // DELETE Conversation
  //

  Future<void> deleteConversation(String conversationId) async {
    final repo = ref.read(chatRepositoryProvider);

    // 🔥 Optimistic update (remove immediately from UI)
    final previousState = state;

    state = state.whenData((conversations) {
      return conversations.where((c) => c.id != conversationId).toList();
    });

    // 🔥 Call repository
    final res = await repo.deleteConversation(conversationId);

    if (res.isLeft) {
      // ❌ If delete fails → rollback UI
      state = previousState;

      appLogger.w('[ChatController] Failed to delete: ${res.leftOrNull}');
    } else {
      appLogger.w('[ChatController] Conversation deleted successfully');
    }
  }

  // -----------------------------
  // Local Updates
  // -----------------------------
  void markConversationAsReadLocally(String conversationId) {
    state = state.whenData((conversations) {
      return conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();
    });
  }

  // -----------------------------
  // Realtime subscription
  // -----------------------------

  Future<void> _subscribeToRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    _messageSub = realtime.messages.listen((data) {
      final convId = data['conversation_id'];
      final messageData = data['message'];

      if (convId == null || messageData == null) return;

      final message = messageData['content'] ?? '';
      final sender = messageData['sender'];
      final shouldIncrement = sender != _currentUser;

      _updateConversationPreview(
        conversationId: convId,
        lastMessage: message,
        incrementUnread: shouldIncrement,
      );
    });
  }

  // -----------------------------
  // Update conversation preview
  // -----------------------------
  void _updateConversationPreview({
    required String conversationId,
    required String lastMessage,
    bool incrementUnread = false,
  }) {
    final current = state.value ?? [];

    if (state is! AsyncData) {
      return;
    }

    final index = current.indexWhere((c) => c.id == conversationId);

    ChatConversation updatedConversation;

    if (index != -1) {
      // existing conversation → update
      updatedConversation = current[index].copyWith(
        lastMessage: lastMessage,
        lastMessageAt: DateTime.now(),
        unreadCount: incrementUnread
            ? current[index].unreadCount + 1
            : current[index].unreadCount,
      );

      final updatedList = [...current]
        ..removeAt(index)
        ..insert(0, updatedConversation);
      state = AsyncData(updatedList);
    } else {
      // new conversation → insert at top
      updatedConversation = ChatConversation(
        id: conversationId,
        user: '', // fetch participants if needed
        displayName: 'New Chat',
        lastMessage: lastMessage,
        lastMessageAt: DateTime.now(),
        unreadCount: incrementUnread ? 1 : 0,
      );

      state = AsyncData([updatedConversation, ...current]);
    }
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
