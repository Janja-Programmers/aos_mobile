import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter/material.dart';

class MessageAdPreview extends StatelessWidget {
  const MessageAdPreview({
    super.key,
    required this.message,
    required this.isMe,
    required this.onTap,
  });

  final ChatMessage message;
  final bool isMe;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final preview = message.adPreview ?? {};

    final adId = _resolveAdId(message, preview);

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

    final fallbackTitle = adId ?? 'Ad';

    final card = Container(
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
          if (adId != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isMe ? colors.white : colors.textMuted,
            ),
          ],
        ],
      ),
    );

    if (adId == null || onTap == null) {
      return card;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTap!(adId),
      child: card,
    );
  }

  static String? _resolveAdId(
    ChatMessage message,
    Map<String, dynamic> preview,
  ) {
    final fromMessage = message.ad?.trim();

    if (fromMessage != null &&
        fromMessage.isNotEmpty &&
        fromMessage.toLowerCase() != 'null') {
      return fromMessage;
    }

    return _readString(preview, const ['ad', 'ad_id', 'id', 'name']);
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
