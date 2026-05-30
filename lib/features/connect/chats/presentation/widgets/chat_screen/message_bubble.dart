import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_grid.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSystem = false,
    this.onLongPress,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isSystem;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
            border: isDeleted ? Border.all(color: colors.border) : null,
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
                _ReplyPreview(reply: message.replyTo!, isMe: isMe),
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
                        message.displayText ?? 'This message was deleted',
                        style: context.p.copyWith(
                          color: colors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                if (message.hasText)
                  Text(message.content!, style: TextStyle(color: textColor)),

                if (message.hasAd) ...[
                  if (message.hasText) const SizedBox(height: 8),
                  _MessageAdPreview(message: message, isMe: isMe),
                ],

                if (message.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AttachmentGrid(attachments: message.attachments),
                ],
              ],

              if (message.reactions.isNotEmpty) ...[
                const SizedBox(height: 6),
                _ReactionChips(message: message, isMe: isMe),
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
                    formatTime(message.createdAt),
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

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.reply, required this.isMe});

  final ChatReplyPreview reply;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: isMe ? colors.white.withOpacity(0.12) : colors.elevated,
        borderRadius: BorderRadius.circular(9),
        border: Border(
          left: BorderSide(
            color: isMe ? colors.white : colors.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.senderDisplayName ?? reply.sender,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isMe ? colors.white : colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reply.previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              fontSize: 12,
              color: isMe ? colors.white : colors.textMuted,
              fontStyle: reply.isDeleted ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionChips extends StatelessWidget {
  const _ReactionChips({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: isMe ? WrapAlignment.end : WrapAlignment.start,
      children: message.reactions.map((reaction) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: reaction.reactedByMe
                ? colors.primary.withOpacity(0.16)
                : colors.elevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: reaction.reactedByMe ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            '${reaction.emoji} ${reaction.count}',
            style: context.p.copyWith(
              fontSize: 12,
              color: isMe ? colors.white : colors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MessageAdPreview extends StatelessWidget {
  const _MessageAdPreview({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final preview = message.adPreview ?? {};

    final title = _readString(preview, const ['title', 'ad_title', 'name']);
    final price = _readString(preview, const [
      'price',
      'current_price',
      'formatted_price',
    ]);
    final image = _readString(preview, const [
      'image',
      'thumbnail',
      'thumbnail_url',
      'primary_image',
    ]);

    final fallbackTitle = message.ad ?? 'Ad';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? colors.white.withOpacity(0.12) : colors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? colors.white.withOpacity(0.18) : colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _AdImage(imageUrl: image),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? fallbackTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.p.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isMe ? colors.white : colors.textPrimary,
                  ),
                ),
                if (price != null && price.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.p.copyWith(
                      fontSize: 12,
                      color: isMe ? colors.white : colors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }

    return null;
  }
}

class _AdImage extends StatelessWidget {
  const _AdImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return Container(
        width: 52,
        height: 52,
        color: colors.border,
        child: Icon(Icons.image_outlined, size: 22, color: colors.textMuted),
      );
    }

    return Image.network(
      url,
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          width: 52,
          height: 52,
          color: colors.border,
          child: Icon(
            Icons.broken_image_outlined,
            size: 22,
            color: colors.textMuted,
          ),
        );
      },
    );
  }
}
