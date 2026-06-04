import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_throttle.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/translation_language.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/active_call_chat_banner.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_app_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_clear_chat_dialog.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_composer_area.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_edit_message_dialog.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_forward_conversation_picker.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_messages_view.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_actions_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/translation_language_picker.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
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
  late final ChatTypingThrottle _typingThrottle;
  bool _isSending = false;
  bool _isLoadingMoreMessages = false;
  ChatMessage? _replyingTo;
  TranslationLanguage _selectedTranslationLanguage =
      chatTranslationLanguages.first;

  @override
  void initState() {
    super.initState();
    _showAdPreview = _hasText(widget.adId);
    _scrollController.addListener(_onScroll);
    _typingThrottle = ChatTypingThrottle(
      conversationId: widget.conversationId,
      sendTyping: ref.read(chatRepositoryProvider).sendTyping,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onChatOpened();
    });
  }

  Future<void> _onChatOpened() async {
    _loadInitialMessageIntoInput();
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
    _typingThrottle.update(hasText);
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
    final replyTarget = _replyingTo;
    final replyPreview = replyTarget == null
        ? null
        : _buildReplyPreview(replyTarget);

    final effectiveAttachments = List<ChatInputAttachment>.from(attachments);

    _isSending = true;
    _inputController.clear();
    _handleTyping(false);

    if (mounted) {
      setState(() {
        _showAdPreview = false;
        _replyingTo = null;
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
        replyToMessage: replyTarget?.id,
        replyTo: replyPreview,
      );

      if (!sent) {
        _restoreFailedMessage(
          messageText: messageText,
          attachedAdId: attachedAdId,
          replyTarget: replyTarget,
        );
        return;
      }

      _scrollToBottom();
    } catch (e) {
      appLogger.e('Send message failed: $e');
      _restoreFailedMessage(
        messageText: messageText,
        attachedAdId: attachedAdId,
        replyTarget: replyTarget,
      );
    } finally {
      _isSending = false;
    }
  }

  Future<void> _loadMoreMessagesIfNeeded() async {
    if (_isLoadingMoreMessages || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isNearOldestMessage =
        position.pixels >= position.maxScrollExtent - 260;

    if (!isNearOldestMessage) return;

    _isLoadingMoreMessages = true;
    try {
      await ref
          .read(chatMessagesControllerProvider(widget.conversationId).notifier)
          .loadMore();
    } finally {
      _isLoadingMoreMessages = false;
    }
  }

  void _onScroll() {
    unawaited(_loadMoreMessagesIfNeeded());
  }

  Future<void> _retryMessage(ChatMessage message) async {
    if (!message.isLocalFailed) return;

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .retryMessage(message.id);

    if (!mounted) return;

    if (!ok) {
      ShowSnack(context, 'Message still failed. Try again.').error();
    }
  }

  void _restoreFailedMessage({
    required String? messageText,
    required String? attachedAdId,
    ChatMessage? replyTarget,
  }) {
    if (!mounted) return;

    _inputController.text = messageText ?? '';
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );

    setState(() {
      _showAdPreview = _hasText(attachedAdId);
      _replyingTo = replyTarget;
    });

    ShowSnack(
      context,
      _hasText(attachedAdId)
          ? 'Failed to send ad message. Please try again.'
          : 'Failed to send message. Please try again.',
    ).error();
  }

  void _showDeleteMessagesInfo() {
    ShowSnack(context, 'Long-press a message to delete it.').info();
  }

  Future<void> _confirmDeleteAllMessages() async {
    final shouldDelete = await showChatClearChatDialog(context);

    if (shouldDelete != true) return;

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .clearChat();

    if (!mounted) return;

    if (ok) {
      ShowSnack(context, 'Chat cleared.').success();
    } else {
      ShowSnack(context, 'Failed to clear chat.').error();
    }
  }

  void _openMessageActions(ChatMessage message, bool isMe) {
    if (message.isSystemMessage) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return MessageActionsSheet(
          message: message,
          isMe: isMe,
          canEdit: _canEdit(message),

          onReply: () {
            Navigator.pop(sheetContext);
            _startReply(message);
          },

          onEdit: () {
            Navigator.pop(sheetContext);
            _showEditDialog(message);
          },

          onToggleStar: () async {
            Navigator.pop(sheetContext);
            await _toggleStar(message);
          },

          onToggleReaction: (emoji) {
            Navigator.pop(sheetContext);
            _toggleReaction(message, emoji);
          },

          onTranslate: () async {
            Navigator.pop(sheetContext);
            await _translateMessageWithPicker(message);
          },

          onForward: () {
            Navigator.pop(sheetContext);
            _forwardMessage(message);
          },

          onDeleteForMe: () {
            Navigator.pop(sheetContext);
            _deleteMessage(message, deleteScope: 'me');
          },

          onDeleteForEveryone: () {
            Navigator.pop(sheetContext);
            _deleteMessage(message, deleteScope: 'everyone');
          },
        );
      },
    );
  }

  Future<void> _toggleStar(ChatMessage message) async {
    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .toggleMessageStar(message.id);

    if (!mounted) return;
    if (!ok) ShowSnack(context, 'Failed to update star.').error();
  }

  Future<void> _toggleReaction(ChatMessage message, String emoji) async {
    final selectedEmoji = message.myReaction == emoji ? null : emoji;

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .toggleMessageReaction(messageId: message.id, emoji: selectedEmoji);

    if (!mounted) return;
    if (!ok) ShowSnack(context, 'Failed to update reaction.').error();
  }

  Future<void> _forwardMessage(ChatMessage message) async {
    final selectedConversations = await showChatForwardConversationPicker(
      context: context,
      currentConversationId: widget.conversationId,
    );

    if (!mounted ||
        selectedConversations == null ||
        selectedConversations.isEmpty) {
      return;
    }

    final targetConversationIds = selectedConversations
        .map((conversation) => conversation.id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (targetConversationIds.isEmpty) return;

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .forwardMessage(
          messageId: message.id,
          targetConversationIds: targetConversationIds,
        );

    if (!mounted) return;

    if (!ok) {
      ShowSnack(context, 'Failed to forward message.').error();
      return;
    }

    await ref.read(conversationsControllerProvider.notifier).refresh();

    if (!mounted) return;

    final count = targetConversationIds.length;
    ShowSnack(
      context,
      count == 1 ? 'Message forwarded.' : 'Message forwarded to $count chats.',
    ).success();
  }

  Future<void> _translateMessageWithPicker(ChatMessage message) async {
    final language = await showModalBottomSheet<TranslationLanguage>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TranslationLanguagePicker(
        initialLanguage: _selectedTranslationLanguage,
      ),
    );

    if (language == null || !mounted) return;

    setState(() {
      _selectedTranslationLanguage = language;
    });

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .translateMessage(messageId: message.id, targetLanguage: language.code);

    if (!mounted) return;

    if (!ok) {
      ShowSnack(context, 'Failed to translate message.').error();
    }
  }

  Future<void> _deleteMessage(
    ChatMessage message, {
    required String deleteScope,
  }) async {
    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .deleteMessages(messageIds: [message.id], deleteScope: deleteScope);

    if (!mounted) return;
    if (!ok) {
      ShowSnack(context, 'Failed to delete message.').error();
      return;
    }

    ShowSnack(
      context,
      deleteScope == 'everyone'
          ? 'Message deleted for everyone.'
          : 'Message deleted for you.',
    ).success();
  }

  Future<void> _showEditDialog(ChatMessage message) async {
    final updated = await showChatEditMessageDialog(context, message);

    if (!_hasText(updated) || updated == message.content?.trim()) return;

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .editMessage(messageId: message.id, content: updated!);

    if (!mounted) return;
    if (!ok) ShowSnack(context, 'Failed to edit message.').error();
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
          SocialNavigation.toProfileScreen(
            context,
            user: widget.otherUser,
            displayName: widget.displayName,
            avatar: widget.otherUserAvatar,
          );
        },
        onDeleteMessages: _showDeleteMessagesInfo,
        onDeleteAllMessages: _confirmDeleteAllMessages,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ActiveCallChatBanner(
              conversationId: widget.conversationId,
              otherUserId: widget.otherUser,
              fallbackDisplayName: widget.displayName,
              fallbackAvatarUrl: widget.otherUserAvatar,
            ),
            Expanded(
              child: ChatMessagesView(
                messagesState: messagesState,
                scrollController: _scrollController,
                currentUserId: currentUserId,
                conversationId: widget.conversationId,
                otherUserId: widget.otherUser,
                otherDisplayName: widget.displayName,
                otherAvatarUrl: widget.otherUserAvatar,
                onReply: _startReply,
                onLongPress: _openMessageActions,
                onRetry: _retryMessage,
              ),
            ),
            ChatComposerArea(
              isTyping: isTyping,
              showAdPreview: _showAdPreview,
              adId: widget.adId,
              adTitle: widget.adTitle,
              adPrice: widget.adPrice,
              adImage: widget.adImage,
              replyingTo: _replyingTo,
              inputController: _inputController,
              onQuickReplyTap: _appendQuickReply,
              onCloseAdPreview: () => setState(() => _showAdPreview = false),
              onCloseReplyPreview: () => setState(() => _replyingTo = null),
              onTyping: _handleTyping,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  bool _canEdit(ChatMessage message) {
    return message.hasText &&
        (message.messageType == 'text' ||
            message.messageType == 'mixed' ||
            message.messageType == 'ad');
  }

  ChatReplyPreview _buildReplyPreview(ChatMessage message) {
    return ChatReplyPreview(
      id: message.id,
      sender: message.sender,
      senderDisplayName: message.senderDisplayName,
      senderAvatar: message.senderAvatar,
      content: message.content,
      messageType: message.messageType,
      originalMessageType: message.originalMessageType,
      ad: message.ad,
      adPreview: message.adPreview,
      hasAttachments: message.hasAttachments,
      isForwarded: message.isForwarded,
      isEdited: message.isEdited,
      editedAt: message.editedAt,
      isDeletedForEveryone: message.isDeletedForEveryone,
      deletedForEveryoneAt: message.deletedForEveryoneAt,
      displayText: message.displayText,
      createdAt: message.createdAt,
    );
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

  void _startReply(ChatMessage message) {
    if (message.isSystemMessage || message.isDeletedType) return;

    setState(() {
      _replyingTo = message;
    });
  }

  @override
  void dispose() {
    _typingThrottle.dispose();
    _scrollController.removeListener(_onScroll);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
