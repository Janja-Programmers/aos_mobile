import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';

class ChatConversationsController
    extends StateNotifier<AsyncValue<List<ChatConversation>>> {
  final Ref ref;

  String _currentUser = '';
  StreamSubscription? _messageSub;

  ChatConversationsController(this.ref) : super(const AsyncData([])) {
    _init();
  }

  // -----------------------------
  // Init
  // -----------------------------
  Future<void> _init() async {
    _currentUser = _normalizeUser(ref.read(currentUserProvider));

    await load();
    await _subscribeToRealtime();
  }

  // -----------------------------
  // Load conversations
  // -----------------------------
  Future<void> load() async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.getConversations();

    if (!mounted) return;

    if (res.isLeft) {
      state = AsyncError(res.leftOrNull!, StackTrace.current);
      return;
    }

    final conversations = List<ChatConversation>.from(res.rightOrNull ?? []);

    conversations.sort((a, b) {
      final aTime = a.lastMessageAt;
      final bTime = b.lastMessageAt;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    state = AsyncData(conversations);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await load();
  }

  // -----------------------------
  // Delete conversation
  // -----------------------------
  Future<void> deleteConversation(String conversationId) async {
    final repo = ref.read(chatRepositoryProvider);

    final previousState = state;

    state = state.whenData((conversations) {
      return conversations.where((c) => c.id != conversationId).toList();
    });

    final res = await repo.deleteConversation(conversationId);

    if (!mounted) return;

    if (res.isLeft) {
      state = previousState;
      appLogger.w('[ChatController] Failed to delete: ${res.leftOrNull}');
      return;
    }

    appLogger.i('[ChatController] Conversation deleted successfully');
  }

  // -----------------------------
  // Local read update
  // -----------------------------
  void markConversationAsReadLocally(String conversationId) {
    state = state.whenData((conversations) {
      return conversations.map((conversation) {
        if (conversation.id != conversationId) return conversation;

        return conversation.copyWith(unreadCount: 0);
      }).toList();
    });
  }

  // -----------------------------
  // Public sync from message screen
  // -----------------------------
  void syncConversationWithMessage({
    required String conversationId,
    required ChatMessage message,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
    bool incrementUnread = false,
  }) {
    final preview = _messagePreview(message);

    _upsertConversationPreview(
      conversationId: conversationId,
      lastMessage: preview,
      lastMessageAt: message.createdAt,
      incrementUnread: incrementUnread,
      fallbackUser: fallbackUser,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );
  }

  // -----------------------------
  // Realtime subscription
  // -----------------------------
  Future<void> _subscribeToRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    await _messageSub?.cancel();

    _messageSub = realtime.messages.listen((data) {
      final conversationId = data['conversation_id']?.toString();
      final rawMessage = data['message'];

      if (conversationId == null || conversationId.trim().isEmpty) return;
      if (rawMessage is! Map) return;

      final message = ChatMessage.fromJson(
        Map<String, dynamic>.from(rawMessage),
      );

      final sender = _normalizeUser(message.sender);
      final shouldIncrement = sender.isNotEmpty && sender != _currentUser;

      syncConversationWithMessage(
        conversationId: conversationId,
        message: message,
        incrementUnread: shouldIncrement,
        fallbackUser: shouldIncrement ? message.sender : null,
        fallbackDisplayName: message.senderDisplayName,
        fallbackAvatar: message.senderAvatar,
      );
    });
  }

  // -----------------------------
  // Internal preview upsert
  // -----------------------------
  void _upsertConversationPreview({
    required String conversationId,
    required String lastMessage,
    required DateTime lastMessageAt,
    bool incrementUnread = false,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  }) {
    final List<ChatConversation> current = state.maybeWhen(
      data: (conversations) => List<ChatConversation>.from(conversations),
      orElse: () => <ChatConversation>[],
    );

    final index = current.indexWhere((c) => c.id == conversationId);

    if (index != -1) {
      final existing = current[index];

      final updatedConversation = existing.copyWith(
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: incrementUnread
            ? existing.unreadCount + 1
            : existing.unreadCount,
      );

      final updatedList = List<ChatConversation>.from(current)
        ..removeAt(index)
        ..insert(0, updatedConversation);

      state = AsyncData(updatedList);
      return;
    }

    final newConversation = ChatConversation(
      id: conversationId,
      user: fallbackUser ?? '',
      displayName: _safeText(fallbackDisplayName) ?? 'New Chat',
      avatar: _safeText(fallbackAvatar),
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: incrementUnread ? 1 : 0,
    );

    state = AsyncData(<ChatConversation>[newConversation, ...current]);
  }

  String _messagePreview(ChatMessage message) {
    final text = message.content?.trim();

    if (text != null && text.isNotEmpty) {
      return text;
    }

    if (message.hasAd || message.hasAdPreview) {
      return 'Ad preview';
    }

    if (message.attachments.isNotEmpty || message.hasAttachments) {
      final firstType = message.attachments.isNotEmpty
          ? message.attachments.first.type.trim().toLowerCase()
          : '';

      if (firstType.contains('image')) return 'Photo';
      if (firstType.contains('video')) return 'Video';
      if (firstType.contains('audio') || firstType.contains('voice')) {
        return 'Voice note';
      }

      return 'Attachment';
    }

    if (message.isSystemMessage) {
      return 'System message';
    }

    return 'Message';
  }

  String _normalizeUser(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }

  String? _safeText(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty || clean.toLowerCase() == 'null') {
      return null;
    }

    return clean;
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
