import 'dart:async';

import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_background.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_ad_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_app_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_quick_replies.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/typing_indicator.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/connect/converaation/application/providers/conversation_provider.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

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
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _showAdPreview = _hasText(widget.adId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onChatOpened();
    });
  }

  Future<void> _onChatOpened() async {
    await _markAsRead();
    _loadInitialMessageIntoInput();
  }

  Future<void> _markAsRead() async {
    final currentUserId = _normalizeUser(ref.read(currentUserProvider));

    final messagesState = ref.read(
      chatMessagesControllerProvider(widget.conversationId),
    );

    final hasUnreadIncoming = messagesState.maybeWhen(
      data: (messages) {
        return messages.any((m) {
          final sender = _normalizeUser(m.sender);

          final isOwnMessage =
              currentUserId.isNotEmpty && sender == currentUserId;
          return !isOwnMessage && m.readAt == null;
        });
      },
      orElse: () => true,
    );

    if (!hasUnreadIncoming) return;

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.markRead(widget.conversationId);

    if (res.isRight) {
      ref
          .read(conversationsControllerProvider.notifier)
          .markConversationAsReadLocally(widget.conversationId);
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

    final repo = ref.read(chatRepositoryProvider);

    Future<void> sendTypingSafe(bool value) async {
      final res = await repo.sendTyping(
        conversationId: widget.conversationId,
        isTyping: value,
      );

      if (res.isLeft) {
        debugPrint('Typing status failed: ${res.leftOrNull}');
      }
    }

    if (!hasText) {
      unawaited(sendTypingSafe(false));
      return;
    }

    unawaited(sendTypingSafe(true));

    _typingTimer = Timer(const Duration(seconds: 3), () {
      unawaited(sendTypingSafe(false));
    });
  }

  Future<void> _sendMessage({
    String? text,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    if (_isSending) return;

    final messageText = text?.trim();

    final hasText = _hasText(messageText);
    final hasAttachments = attachments.isNotEmpty;
    final hasAdContext = _showAdPreview && _hasText(widget.adId);

    if (!hasText && !hasAttachments && !hasAdContext) return;

    final attachedAdId = hasAdContext ? widget.adId?.trim() : null;
    final attachedAdTitle = hasAdContext ? widget.adTitle : null;
    final attachedAdPrice = hasAdContext ? widget.adPrice : null;
    final attachedAdImage = hasAdContext ? widget.adImage : null;

    final effectiveAttachments = List<ChatInputAttachment>.from(attachments);

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
        fallbackUser: widget.otherUser,
        fallbackDisplayName: widget.displayName,
        fallbackAvatar: widget.otherUserAvatar,
      );

      if (!sent) {
        _restoreFailedMessage(
          messageText: messageText,
          attachedAdId: attachedAdId,
        );

        return;
      }

      _scrollToBottom();
    } catch (e) {
      appLogger.e('Send message failed: $e');

      _restoreFailedMessage(
        messageText: messageText,
        attachedAdId: attachedAdId,
      );
    } finally {
      _isSending = false;
    }
  }

  void _restoreFailedMessage({
    required String? messageText,
    required String? attachedAdId,
  }) {
    if (!mounted) return;

    _inputController.text = messageText ?? '';
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );

    setState(() {
      _showAdPreview = _hasText(attachedAdId);
    });

    ShowSnack(
      context,
      _hasText(attachedAdId)
          ? 'Failed to send ad message. Please try again.'
          : 'Failed to send message. Please try again.',
    ).error();
  }

  void _showDeleteMessagesInfo() {
    ShowSnack(
      context,
      'Message selection will be enabled when message delete API is ready.',
    ).info();
  }

  Future<void> _confirmDeleteAllMessages() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;

        return AlertDialog(
          backgroundColor: colors.elevated,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete all messages?',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            'This action will delete all messages in this chat for you when the backend endpoint is connected.',
            style: TextStyle(color: colors.textMuted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (!mounted) return;

    ShowSnack(context, 'Delete all messages API is not connected yet.').info();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(
      chatMessagesControllerProvider(widget.conversationId),
    );

    final typingMap = ref.watch(chatTypingControllerProvider);
    final currentUserId = _normalizeUser(ref.watch(currentUserProvider));

    final isTyping = typingMap[widget.conversationId] ?? false;

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface.withOpacity(.55),

      appBar: ChatAppBar(
        conversationId: widget.conversationId,
        displayName: widget.displayName,
        otherUserId: widget.otherUser,
        imageUrl: widget.otherUserAvatar,
        lastSeen: widget.lastSeen,
        onHeaderTap: () {
          SocialNavigation.toProfileScreen(context, user: widget.otherUser);
        },
        onDeleteMessages: _showDeleteMessagesInfo,
        onDeleteAllMessages: _confirmDeleteAllMessages,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatBackground(
                assetPath: 'assets/images/logo_redone.png',
                child: messagesState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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

                        final isMe = _isOwnMessage(
                          sender: msg.sender,
                          currentUserId: currentUserId,
                          isSystem: isSystem,
                        );

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

  bool _isOwnMessage({
    required String sender,
    required String currentUserId,
    required bool isSystem,
  }) {
    if (isSystem) return false;
    if (currentUserId.isEmpty) return false;

    return _normalizeUser(sender) == currentUserId;
  }

  static String _normalizeUser(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
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
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
