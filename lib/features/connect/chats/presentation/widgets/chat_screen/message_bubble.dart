import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_grid.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/call_message_tile.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/message_ad_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/reaction_chips.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/reply_preview.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSystem = false,
    this.conversationId,
    this.otherUserId,
    this.otherDisplayName,
    this.otherAvatarUrl,
    this.onLongPress,
    this.onRetry,
    this.onAdTap,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isSystem;
  final String? conversationId;
  final String? otherUserId;
  final String? otherDisplayName;
  final String? otherAvatarUrl;
  final VoidCallback? onLongPress;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onAdTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (message.isCallType) {
      return CallMessageTile(
        message: message,
        isMe: isMe,
        conversationId: conversationId ?? '',
        otherUserId: otherUserId ?? '',
        otherDisplayName: otherDisplayName ?? 'AOS user',
        otherAvatarUrl: otherAvatarUrl,
      );
    }

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            message.visibleText,
            textAlign: TextAlign.center,
            style: context.p.copyWith(color: colors.textMuted, fontSize: 12),
          ),
        ),
      );
    }

    final bgColor = isMe ? colors.chatCardColor : colors.surface;
    final textColor = isMe ? colors.white : colors.textPrimary;
    final mutedTextColor = isMe
        ? colors.white.withOpacity(0.78)
        : colors.textMuted;

    final isDeleted = message.isDeletedType;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 292),
          decoration: BoxDecoration(
            color: isDeleted ? colors.elevated : bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isForwarded && !isDeleted) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shortcut_rounded,
                      size: 13,
                      color: isMe ? colors.white : colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Forwarded',
                      style: context.p.copyWith(
                        fontSize: 11,
                        color: isMe ? colors.white : colors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],

              if (message.replyTo != null && !isDeleted) ...[
                ReplyPreview(reply: message.replyTo!, isMe: isMe),
                const SizedBox(height: 7),
              ],

              if (isDeleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block_rounded,
                      size: 16,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isMe
                            ? message.displayText!.trim()
                            : 'You deleted this message',
                        style: context.p.copyWith(
                          color: colors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                if (message.hasTranslation) ...[
                  Text(
                    message.translatedText,
                    style: context.p.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (message.hasText) ...[
                    const SizedBox(height: 4),
                    Text(
                      message.visibleText,
                      style: context.p.copyWith(
                        color: mutedTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ] else if (message.hasText) ...[
                  Text(
                    message.visibleText,
                    style: context.p.copyWith(color: textColor),
                  ),
                ],

                if (message.isTranslating) ...[
                  if (message.hasText || message.hasTranslation)
                    const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: mutedTextColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Translating...',
                        style: context.p.copyWith(
                          color: mutedTextColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],

                if ((message.translationError ?? '').trim().isNotEmpty) ...[
                  if (message.hasText ||
                      message.hasTranslation ||
                      message.isTranslating)
                    const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: isMe
                            ? colors.white.withOpacity(0.85)
                            : colors.red,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          message.translationError!,
                          style: context.p.copyWith(
                            color: isMe
                                ? colors.white.withOpacity(0.85)
                                : colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (message.hasAd) ...[
                  if (message.hasText || message.hasTranslation)
                    const SizedBox(height: 8),
                  MessageAdPreview(
                    message: message,
                    isMe: isMe,
                    onTap: onAdTap,
                  ),
                ],

                if (message.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AttachmentGrid(attachments: message.attachments),
                ],
              ],

              if (message.reactions.isNotEmpty) ...[
                const SizedBox(height: 6),
                ReactionChips(message: message, isMe: isMe),
              ],

              const SizedBox(height: 4),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isStarred) ...[
                    Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: isMe ? colors.white : colors.textMuted,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    formatMessageTime(message.createdAt),
                    style: context.p.copyWith(
                      fontSize: 10,
                      color: isMe && !isDeleted
                          ? colors.white
                          : colors.textMuted,
                    ),
                  ),
                  if (message.isEdited && !isDeleted) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Edited',
                      style: context.p.copyWith(
                        fontSize: 10,
                        color: isMe ? colors.white : colors.textMuted,
                      ),
                    ),
                  ],
                  if (isMe) const SizedBox(width: 4),
                  if (isMe) _buildStatusIcon(context),
                ],
              ),

              if (message.isLocalSending)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Sending...',
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ),

              if (message.isLocalFailed)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRetry,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to retry',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final colors = context.appColors;

    if (message.readAt != null) {
      return Icon(Icons.done_all, size: 14, color: colors.blue);
    }

    if (message.deliveredAt != null) {
      return Icon(Icons.done_all, size: 14, color: colors.white);
    }

    return Icon(Icons.done, size: 14, color: colors.white);
  }
}
