import 'dart:async';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/chats/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_ad_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_app_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_quick_replies.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/typing_indicator.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUser;
  final String displayName;
  final String? otherUserAvatar;
  final DateTime? lastSeen;
  final String? initialMessage;
  final String? adId;
  final String? adTitle;
  final String? adPrice;
  final String? adImage;
  final String? adImageFileId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
    required this.displayName,
    this.otherUserAvatar,
    this.lastSeen,
    this.initialMessage,
    this.adId,
    this.adTitle,
    this.adPrice,
    this.adImage,
    this.adImageFileId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  bool _loadedInitialIntoInput = false;
  bool _showAdPreview = false;
  Timer? _typingTimer;
  Timer? _typingStopTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _showAdPreview = widget.adId != null && widget.adId!.trim().isNotEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onChatOpened();
    });
  }

  Future<void> _onChatOpened() async {
    await _markAsRead();
    _loadInitialMessageIntoInput();
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

  void _loadInitialMessageIntoInput() {
    if (_loadedInitialIntoInput) return;

    final text = widget.initialMessage?.trim();
    if (text == null || text.isEmpty) return;

    _loadedInitialIntoInput = true;
    _inputController.text = text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
  }

  void _appendQuickReply(String text) {
    final current = _inputController.text.trim();

    _inputController.text = current.isEmpty ? text : '$current $text';
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );

    setState(() {});
  }

  void _handleTyping(bool hasText) {
    _typingTimer?.cancel();
    _typingStopTimer?.cancel();

    final repo = ref.read(chatRepositoryProvider);

    if (!hasText) {
      repo.sendTyping(conversationId: widget.conversationId, isTyping: false);
      return;
    }

    repo.sendTyping(conversationId: widget.conversationId, isTyping: true);

    _typingTimer = Timer(const Duration(seconds: 3), () {
      repo.sendTyping(conversationId: widget.conversationId, isTyping: false);
    });
  }

  Future<void> _sendMessage({
    String? text,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    if (_isSending) return;

    final messageText = text?.trim();

    final hasText = messageText != null && messageText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAdContext =
        _showAdPreview && widget.adId != null && widget.adId!.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAdContext) return;

    final attachedAdId = hasAdContext ? widget.adId : null;
    final attachedAdTitle = hasAdContext ? widget.adTitle : null;
    final attachedAdPrice = hasAdContext ? widget.adPrice : null;
    final attachedAdImage = hasAdContext ? widget.adImage : null;
    final attachedAdImageFileId = hasAdContext ? widget.adImageFileId : null;

    final effectiveAttachments = List<ChatInputAttachment>.from(attachments);

    if (hasAdContext &&
        effectiveAttachments.isEmpty &&
        attachedAdImageFileId != null &&
        attachedAdImageFileId.trim().isNotEmpty) {
      effectiveAttachments.add(
        ChatInputAttachment(
          fileId: attachedAdImageFileId.trim(),
          type: 'image',
          previewUrl: attachedAdImage ?? '',
        ),
      );
    }

    _isSending = true;

    _inputController.clear();
    _handleTyping(false);

    if (mounted) {
      setState(() {
        _showAdPreview = false;
      });
    }

    try {
      final notifier = ref.read(
        chatMessagesControllerProvider(widget.conversationId).notifier,
      );

      final currentUserId = ref.read(currentUserProvider);

      final sent = await notifier.sendTempMessage(
        text: hasText ? messageText : null,
        attachments: effectiveAttachments,
        adId: attachedAdId,
        adTitle: attachedAdTitle,
        adPrice: attachedAdPrice,
        adImage: attachedAdImage,
        senderId: currentUserId,
      );

      if (!sent) {
        if (!mounted) return;

        _inputController.text = messageText ?? '';
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );

        setState(() {
          _showAdPreview =
              attachedAdId != null && attachedAdId.trim().isNotEmpty;
        });

        ShowSnack(
          context,
          attachedAdId != null
              ? 'Failed to send ad message. Please try again.'
              : 'Failed to send message. Please try again.',
        ).error();

        return;
      }

      _scrollToBottom();
    } catch (e) {
      debugPrint('Send message failed: $e');

      if (mounted) {
        _inputController.text = messageText ?? '';
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );

        setState(() {
          _showAdPreview =
              attachedAdId != null && attachedAdId.trim().isNotEmpty;
        });

        ShowSnack(context, 'Failed to send message. Please try again.').error();
      }
    } finally {
      _isSending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(
      chatMessagesControllerProvider(widget.conversationId),
    );

    final typingMap = ref.watch(chatTypingControllerProvider);

    final currentUserId = ref.watch(currentUserProvider);

    final isTyping = typingMap[widget.conversationId] ?? false;

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.border,

      appBar: ChatAppBar(
        conversationId: widget.conversationId,
        displayName: widget.displayName,
        otherUserId: widget.otherUser,
        imageUrl: widget.otherUserAvatar,
        lastSeen: widget.lastSeen,
        backgroundColor: colors.border,
      ),

      body: SafeArea(
        child: Column(
          children: [
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
                      final isSystem = msg.isSystemMessage;

                      final isMe =
                          !isSystem &&
                          currentUserId != null &&
                          msg.sender.trim().toLowerCase() ==
                              currentUserId.trim().toLowerCase();

                      return MessageBubble(
                        message: msg,
                        isMe: isMe,
                        isSystem: isSystem,
                      );
                    },
                  );
                },
              ),
            ),

            if (isTyping) const TypingIndicator(isTyping: true),

            ChatQuickReplies(
              replies: const [
                'Is this still available?',
                'What’s your best price?',
                'Can you share your location?',
                'Can I call you about this item?',
              ],
              onTap: _appendQuickReply,
            ),

            if (_showAdPreview)
              ChatAdPreview(
                title: widget.adTitle ?? '',
                price: widget.adPrice ?? '',
                imageUrl: widget.adImage,
                onClose: () {
                  setState(() => _showAdPreview = false);
                },
              ),

            ChatInputBar(
              key: ValueKey(_showAdPreview ? widget.adId : 'no-ad'),
              controller: _inputController,
              onSend: _sendMessage,
              onTyping: _handleTyping,
              adId: _showAdPreview ? widget.adId : null,
            ),
          ],
        ),
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
    _typingTimer?.cancel();
    _typingStopTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
