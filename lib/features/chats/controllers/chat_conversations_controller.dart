import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';
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
    appLogger.w('[ChatController] Current user: $_currentUser');

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
      appLogger.w(
        '[ChatController] Failed to load conversations: ${res.leftOrNull}',
      );
    } else {
      state = AsyncData(res.rightOrNull!);
      appLogger.w(
        '[ChatController] Loaded ${res.rightOrNull?.length ?? 0} conversations',
      );
    }
  }

  Future<void> refresh() async {
    appLogger.w('[ChatController] Refreshing conversations...');
    state = const AsyncLoading();
    await load();
    appLogger.w('[ChatController] Refreshing conversations...');
    appLogger.w('[ChatController] Current user: $_currentUser');
  }

  // -----------------------------
  // Local Updates
  // -----------------------------
  void markConversationAsReadLocally(String conversationId) {
    state = state.whenData((conversations) {
      return conversations.map((c) {
        if (c.id == conversationId) {
          appLogger.w(
            '[ChatController] Marking conversation $conversationId as read locally',
          );
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

    // Wait only for socket to connect
    while (!realtime.isConnected) {
      appLogger.w('Not connected');

      await Future.delayed(const Duration(milliseconds: 100));
    }
    appLogger.w('[ChatController] Realtime connected, subscribing to messages');

    _messageSub = realtime.messages.listen((data) {
      final convId = data['conversation_id'];
      final messageData = data['message'];

      if (convId == null || messageData == null) return;

      final message = messageData['content'] ?? '';
      final sender = messageData['sender'];
      final shouldIncrement = sender != _currentUser;

      appLogger.w(
        '[ChatController] Received message in conversation $convId from $sender: $message',
      );

      // Use centralized function
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
      appLogger.w(
        '[ChatController] State is not ready, skipping update for $conversationId',
      );
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
      appLogger.w(
        '[ChatController] Updated existing conversation $conversationId',
      );
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
      appLogger.w('[ChatController] Added new conversation $conversationId');
    }
  }

  // -----------------------------
  // Dispose
  // -----------------------------
  @override
  void dispose() {
    appLogger.w('[ChatController] Disposing, cancelling subscription');
    _messageSub?.cancel();
    super.dispose();
  }
}
