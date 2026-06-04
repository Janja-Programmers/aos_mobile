import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_background.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble.dart';

class ChatMessagesView extends StatelessWidget {
  final ChatMessagesState messagesState;
  final ScrollController scrollController;
  final String currentUserId;
  final String conversationId;
  final String otherUserId;
  final String otherDisplayName;
  final String? otherAvatarUrl;
  final ValueChanged<ChatMessage> onReply;
  final void Function(ChatMessage message, bool isMe) onLongPress;
  final ValueChanged<ChatMessage> onRetry;

  const ChatMessagesView({
    super.key,
    required this.messagesState,
    required this.scrollController,
    required this.currentUserId,
    required this.conversationId,
    required this.otherUserId,
    required this.otherDisplayName,
    required this.otherAvatarUrl,
    required this.onReply,
    required this.onLongPress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ChatBackground(
      patternAssetPath: 'assets/images/chat_pattern.png',
      child: _buildContent(context, colors),
    );
  }

  Widget _buildContent(BuildContext context, dynamic colors) {
    if (messagesState.isInitialLoading && messagesState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState.hasError && messagesState.messages.isEmpty) {
      return Center(child: Text(messagesState.error.toString()));
    }

    final messages = messagesState.messages;

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Backend is the message order SSOT and returns newest -> oldest.
            // With reverse:true, index 0 is visually at the bottom.
            final msg = messages[index];
            final isSystem = msg.isSystemMessage;
            final isMe = _isOwnMessage(
              sender: msg.sender,
              currentUserId: currentUserId,
              isSystem: isSystem,
            );

            return Dismissible(
              key: ValueKey(
                'reply-${msg.id}-${msg.createdAt.microsecondsSinceEpoch}',
              ),
              direction: isSystem || msg.isDeletedType
                  ? DismissDirection.none
                  : DismissDirection.startToEnd,
              confirmDismiss: (_) async {
                onReply(msg);
                return false;
              },
              background: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Icon(Icons.reply_rounded, color: colors.primary),
                ),
              ),
              child: MessageBubble(
                message: msg,
                isMe: isMe,
                isSystem: isSystem,
                conversationId: conversationId,
                otherUserId: otherUserId,
                otherDisplayName: otherDisplayName,
                otherAvatarUrl: otherAvatarUrl,
                onLongPress: () => onLongPress(msg, isMe),
                onRetry: msg.isLocalFailed ? () => onRetry(msg) : null,
                onAdTap: (adId) {
                  AdNavigation.toDetail(context, adId);
                },
              ),
            );
          },
        ),
        if (messagesState.isLoadingMore)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
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
}
