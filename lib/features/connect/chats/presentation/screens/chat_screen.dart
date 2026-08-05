import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_throttle.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/translation_language.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/active_call_chat_banner.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_app_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_composer_area.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_edit_message_dialog.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_forward_conversation_picker.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_emoji_panel.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_messages_view.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_wallpaper_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_actions_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/translation_language_picker.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _isStartingCall = false;
  ProviderSubscription<String?>? _accountSubscription;
  String _activeAccountId = '';
  bool _accountInitialized = false;
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
    _accountSubscription = ref.listenManual<String?>(
      currentCanonicalAccountIdProvider,
      _handleAccountChanged,
      fireImmediately: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onChatOpened();
    });
  }

  void _onChatOpened() {
    _loadInitialMessageIntoInput();
  }

  void _handleAccountChanged(String? previous, String? next) {
    final accountId = normalizeCanonicalUserId(next);
    if (_accountInitialized && accountId == _activeAccountId) return;

    final isAccountChange = _accountInitialized;
    _accountInitialized = true;
    _activeAccountId = accountId;
    if (!isAccountChange) return;

    _typingThrottle.update(false);
    _inputController.clear();
    if (!mounted) return;
    setState(() {
      _replyingTo = null;
      _showAdPreview = false;
      _isSending = false;
    });
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

  void _handleTyping(bool hasText) {
    _typingThrottle.update(hasText);
  }

  Future<bool> _sendMessage({
    String? text,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    if (_isSending) return false;

    final messageText = text?.trim();
    final hasText = _hasText(messageText);
    final hasAttachments = attachments.isNotEmpty;
    final hasAdContext = _showAdPreview && _hasText(widget.adId);

    if (!hasText && !hasAttachments && !hasAdContext) return false;

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

      final sent = await notifier.sendTempMessage(
        text: hasText ? messageText : null,
        attachments: effectiveAttachments,
        adId: attachedAdId,
        adTitle: attachedAdTitle,
        adPrice: attachedAdPrice,
        adImage: attachedAdImage,
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
        return false;
      }

      _scrollToBottom();
      return true;
    } catch (e) {
      appLogger.e('Send message failed: $e');
      _restoreFailedMessage(
        messageText: messageText,
        attachedAdId: attachedAdId,
        replyTarget: replyTarget,
      );
      return false;
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
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_message_still_failed,
      ).error();
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
          ? AppLocalizations.of(context).chat_send_ad_failed
          : AppLocalizations.of(context).chat_send_failed,
    ).error();
  }

  void _openMessageActions(ChatMessage message, bool isMe, Offset anchor) {
    if (message.isSystemMessage) return;

    final l10n = AppLocalizations.of(context);
    unawaited(
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: l10n.chat_more_options,
        barrierColor: Colors.black.withValues(alpha: 0.26),
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (dialogContext, _, _) {
          void closeThen(VoidCallback action) {
            Navigator.of(dialogContext).pop();
            action();
          }

          return MessageActionsSheet(
            anchor: anchor,
            message: message,
            isMe: isMe,
            canEdit: _canEdit(message),
            onReply: () => closeThen(() => _startReply(message)),
            onEdit: () => closeThen(() => unawaited(_showEditDialog(message))),
            onCopy: () => closeThen(() => unawaited(_copyMessage(message))),
            onToggleStar: () =>
                closeThen(() => unawaited(_toggleStar(message))),
            onToggleReaction: (emoji) =>
                closeThen(() => unawaited(_toggleReaction(message, emoji))),
            onChooseReaction: () =>
                closeThen(() => unawaited(_chooseReaction(message))),
            onTranslate: () => closeThen(
              () => unawaited(_translateMessageWithPicker(message)),
            ),
            onForward: () =>
                closeThen(() => unawaited(_forwardMessage(message))),
            onDelete: () => closeThen(
              () => unawaited(_handleDeleteFromActions(message, isMe)),
            ),
          );
        },
        transitionBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _copyMessage(ChatMessage message) async {
    final text = message.visibleText.trim();
    if (text.isEmpty || message.isDeletedType) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    final colors = context.appColors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Semantics(
            liveRegion: true,
            label: AppLocalizations.of(context).chat_copied_to_clipboard,
            child: Text(AppLocalizations.of(context).chat_copied_to_clipboard),
          ),
        ),
      );
  }

  Future<void> _toggleStar(ChatMessage message) async {
    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .toggleMessageStar(message.id);

    if (!mounted) return;
    if (!ok) {
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_star_update_failed,
      ).error();
    }
  }

  Future<void> _chooseReaction(ChatMessage message) async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return ChatEmojiPanel(
          onEmojiSelected: (selected) {
            Navigator.of(sheetContext).pop(selected);
          },
          onClose: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
    if (!mounted || emoji == null || emoji.trim().isEmpty) return;
    await _toggleReaction(message, emoji);
  }

  Future<void> _toggleReaction(ChatMessage message, String emoji) async {
    final selectedEmoji = message.myReaction == emoji ? null : emoji;

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .toggleMessageReaction(messageId: message.id, emoji: selectedEmoji);

    if (!mounted) return;
    if (!ok) {
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_reaction_update_failed,
      ).error();
    }
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
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_forward_failed,
      ).error();
      return;
    }

    await ref.read(conversationsControllerProvider.notifier).refresh();

    if (!mounted) return;

    final count = targetConversationIds.length;
    ShowSnack(
      context,
      count == 1
          ? AppLocalizations.of(context).chat_forwarded
          : AppLocalizations.of(context).chat_forwarded_to_chats(count),
    ).success();
  }

  Future<void> _translateMessageWithPicker(ChatMessage message) async {
    final language = await showModalBottomSheet<TranslationLanguage>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TranslationLanguagePicker(
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
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_translate_failed,
      ).error();
    }
  }

  Future<void> _handleDeleteFromActions(ChatMessage message, bool isMe) async {
    if (!isMe) {
      await _deleteMessage(message, deleteScope: 'me');
      return;
    }

    final l10n = AppLocalizations.of(context);
    final deleteScope = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;
        return AlertDialog(
          backgroundColor: colors.elevated,
          title: Text(l10n.chat_delete),
          contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: colors.red),
                title: Text(l10n.chat_delete_for_me),
                onTap: () => Navigator.of(dialogContext).pop('me'),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: colors.red),
                title: Text(l10n.chat_delete_for_everyone),
                onTap: () => Navigator.of(dialogContext).pop('everyone'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || deleteScope == null) return;
    await _deleteMessage(message, deleteScope: deleteScope);
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
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_delete_failed,
      ).error();
      return;
    }

    ShowSnack(
      context,
      deleteScope == 'everyone'
          ? AppLocalizations.of(context).chat_deleted_for_everyone
          : AppLocalizations.of(context).chat_deleted_for_you,
    ).success();
  }

  Future<void> _showEditDialog(ChatMessage message) async {
    final updated = await showChatEditMessageDialog(context, message);

    if (!mounted || !_hasText(updated) || updated == message.content?.trim()) {
      return;
    }

    final ok = await ref
        .read(chatMessagesControllerProvider(widget.conversationId).notifier)
        .editMessage(messageId: message.id, content: updated!);

    if (!mounted) return;
    if (!ok) {
      ShowSnack(context, AppLocalizations.of(context).chat_edit_failed).error();
    }
  }

  void _closeChat() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.goNamed(AppRoutes.nConnect);
  }

  void _openWallpaperSheet() {
    unawaited(
      showChatWallpaperSheet(
        context: context,
        conversationId: widget.conversationId,
      ),
    );
  }

  Future<void> _startCall(AOSCallType type) async {
    if (_isStartingCall) return;

    _isStartingCall = true;
    try {
      final success = await ref
          .read(callStarterServiceProvider)
          .startOutgoingCall(
            userId: widget.otherUser,
            callType: type,
            receiver: CallParticipant(
              userId: widget.otherUser,
              displayName: widget.displayName,
              avatarUrl: widget.otherUserAvatar,
            ),
          );

      if (!mounted) return;
      if (!success) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_call,
        ).error();
      }
    } catch (e) {
      appLogger.e('Failed to start chat call: $e');
      if (mounted) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_call,
        ).error();
      }
    } finally {
      _isStartingCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(
      chatMessagesControllerProvider(widget.conversationId),
    );
    final typingMap = ref.watch(chatTypingControllerProvider);
    final currentUserId = normalizeCanonicalUserId(
      ref.watch(currentCanonicalAccountIdProvider),
    );
    final isTyping = typingMap[widget.conversationId] ?? false;
    final colors = context.appColors;
    final preferences = ref.watch(
      chatLocalPreferencesControllerProvider(widget.conversationId),
    );

    return Scaffold(
      backgroundColor: colors.surface.withValues(alpha: .55),
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
        onChangeWallpaper: _openWallpaperSheet,
        onBack: _closeChat,
      ),
      body: SafeArea(
        top: false,
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
                preferences: preferences,
                onReply: _startReply,
                onLongPress: _openMessageActions,
                onRetry: _retryMessage,
                onRetryInitial: () {
                  unawaited(
                    ref
                        .read(
                          chatMessagesControllerProvider(
                            widget.conversationId,
                          ).notifier,
                        )
                        .loadInitial(),
                  );
                },
                onRetryOlder: () {
                  unawaited(
                    ref
                        .read(
                          chatMessagesControllerProvider(
                            widget.conversationId,
                          ).notifier,
                        )
                        .loadMore(),
                  );
                },
              ),
            ),
            ChatComposerArea(
              key: ValueKey('chat-composer-$currentUserId'),
              isTyping: isTyping,
              showAdPreview: _showAdPreview,
              adId: widget.adId,
              adTitle: widget.adTitle,
              adPrice: widget.adPrice,
              adImage: widget.adImage,
              replyingTo: _replyingTo,
              inputController: _inputController,
              preferences: preferences,
              onCloseAdPreview: () => setState(() => _showAdPreview = false),
              onCloseReplyPreview: () => setState(() => _replyingTo = null),
              onTyping: _handleTyping,
              onAudioCall: () => unawaited(_startCall(AOSCallType.audio)),
              onVideoCall: () => unawaited(_startCall(AOSCallType.video)),
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
      sender: message.senderCanonicalId,
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

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
      );
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
    _accountSubscription?.close();
    _typingThrottle.dispose();
    _scrollController.removeListener(_onScroll);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
