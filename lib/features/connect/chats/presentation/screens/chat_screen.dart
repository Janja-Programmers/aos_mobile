import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/message_bubble.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_input_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/typing_indicator.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/presence_label.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUser;
  final String displayName;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
    required this.displayName,
    this.initialMessage,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _sentInitial = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onChatOpened();
    });
  }

  Future<void> _onChatOpened() async {
    await _markAsRead();
    await _handleInitialMessage();
  }

  Future<void> _markAsRead() async {
    final messagesState = ref.read(
      chatMessagesControllerProvider(widget.conversationId),
    );

    final hasUnread = messagesState.maybeWhen(
      data: (messages) => messages.any((m) => m.readAt == null),
      orElse: () => true,
    );

    if (!hasUnread) return;

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.markRead(widget.conversationId);

    if (res.isRight) {
      await ref.read(chatConversationsControllerProvider.notifier).refresh();
    }
  }

  Future<void> _handleInitialMessage() async {
    if (_sentInitial) return;

    final text = widget.initialMessage;
    if (text == null || text.trim().isEmpty) return;

    final messagesState = ref.read(
      chatMessagesControllerProvider(widget.conversationId),
    );

    final alreadyHasMessage = messagesState.maybeWhen(
      data: (messages) => messages.any((m) => m.content == text),
      orElse: () => false,
    );

    if (alreadyHasMessage) return;

    _sentInitial = true;

    final controller = ref.read(
      chatMessagesControllerProvider(widget.conversationId).notifier,
    );

    await controller.sendTempMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(
      chatMessagesControllerProvider(widget.conversationId),
    );

    final typingMap = ref.watch(chatTypingControllerProvider);
    final presenceMap = ref.watch(chatPresenceControllerProvider);
    final currentUser = ref.watch(currentUserProvider);

    final isTyping = typingMap[widget.conversationId] ?? false;
    final presence = presenceMap[widget.otherUser];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.displayName),
            if (presence != null)
              PresenceLabel(
                isOnline: presence.isOnline,
                lastSeen: presence.lastSeen,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // -------------------------
          // Messages
          // -------------------------
          Expanded(
            child: messagesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (messages) {
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe = msg.sender == currentUser;
                    return MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // -------------------------
          // Typing indicator
          // -------------------------
          if (isTyping) const TypingIndicator(isTyping: true),

          // -------------------------
          // Input
          // -------------------------
          ChatInputBar(
            initialText: widget.initialMessage,
            onSend: (text) async {
              final notifier = ref.read(
                chatMessagesControllerProvider(widget.conversationId).notifier,
              );
              await notifier.sendTempMessage(text);
              _scrollToBottom();
            },
            onTyping: (_) {
              // cancel previous timer
              _typingTimer?.cancel();

              // start a new debounce timer
              _typingTimer = Timer(const Duration(seconds: 5), () {
                // 🔥 ONLY fires if user stopped typing for 5 sec
                ref
                    .read(chatRepositoryProvider)
                    .sendTyping(
                      conversationId: widget.conversationId,
                      isTyping: true,
                    );

                // optional: auto-stop typing after some time
                Timer(const Duration(seconds: 3), () {
                  ref
                      .read(chatRepositoryProvider)
                      .sendTyping(
                        conversationId: widget.conversationId,
                        isTyping: false,
                      );
                });
              });
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}
