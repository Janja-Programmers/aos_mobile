import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_grid.dart';

import 'package:africaonlinestores/shared/utils/format_time.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSystem = false,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final bgColor = isMe ? colors.chatCardColor : colors.surface;
    final textColor = isMe ? colors.white : colors.textPrimary;

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
            message.content ?? '',
            textAlign: TextAlign.center,
            style: context.p.copyWith(color: colors.textMuted, fontSize: 12),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message.content != null && message.content!.trim().isNotEmpty)
              Text(message.content!, style: TextStyle(color: textColor)),

            if (message.hasAd) ...[
              if (message.content != null && message.content!.trim().isNotEmpty)
                const SizedBox(height: 8),
              _MessageAdPreview(message: message, isMe: isMe),
            ],

            if (message.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              AttachmentGrid(attachments: message.attachments),
            ],

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.createdAt),
                  style: context.p.copyWith(
                    fontSize: 10,
                    color: isMe ? colors.white : colors.textPrimary,
                  ),
                ),
                if (isMe) const SizedBox(width: 4),
                if (isMe) _buildStatusIcon(context),
              ],
            ),
          ],
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
        color: isMe ? colors.white.withValues(alpha: 0.12) : colors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? colors.white.withValues(alpha: 0.18) : colors.border,
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
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
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
