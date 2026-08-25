import 'dart:math' as math;

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/payloads/chat_shared_payload.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_grid.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_message_status_icon.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/call_message_tile.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/message_ad_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/reaction_chips.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/shared_contact_bubble.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble/shared_location_bubble.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';
import 'package:flutter/material.dart';

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
    this.onReplyTap,
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
  final ValueChanged<Rect>? onLongPress;
  final VoidCallback? onReplyTap;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onAdTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = math.min(336.0, screenWidth * 0.78);

    if (message.isCallType) {
      return CallMessageTile(
        message: message,
        isMe: isMe,
        conversationId: conversationId ?? '',
        otherUserId: otherUserId ?? '',
        otherDisplayName: otherDisplayName ?? l10n.chat_aos_user,
        otherAvatarUrl: otherAvatarUrl,
      );
    }

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: colors.elevated.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            message.visibleText,
            textAlign: TextAlign.center,
            style: context.p.copyWith(color: colors.textMuted, fontSize: 11.5),
          ),
        ),
      );
    }

    final isDeleted = message.isDeletedType;
    final locationPayload = isDeleted
        ? null
        : ChatLocationPayload.tryParse(message.content);
    final contactPayload = isDeleted
        ? null
        : ChatContactPayload.tryParse(message.content);
    final hasRichPayload = locationPayload != null || contactPayload != null;
    final bgColor = isMe ? colors.primary : colors.elevated;
    final textColor = isMe ? colors.white : colors.textPrimary;
    final mutedTextColor = isMe
        ? colors.white.withValues(alpha: 0.78)
        : colors.textMuted;

    return Semantics(
      container: true,
      label: _semanticLabel(l10n),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Builder(
          builder: (bubbleContext) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: onLongPress == null
                ? null
                : (_) {
                    final renderBox =
                        bubbleContext.findRenderObject() as RenderBox?;
                    if (renderBox == null || !renderBox.attached) return;
                    final origin = renderBox.localToGlobal(Offset.zero);
                    final bounds = origin & renderBox.size;
                    onLongPress!(
                      Rect.fromLTRB(
                        bounds.left,
                        bounds.top + 4,
                        bounds.right,
                        bounds.bottom - 4,
                      ),
                    );
                  },
            child: Container(
              margin: EdgeInsets.only(
                left: isMe ? 46 : 14,
                right: isMe ? 14 : 46,
                top: 4,
                bottom: 4,
              ),
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              decoration: BoxDecoration(
                color: isDeleted ? colors.elevated : bgColor,
                borderRadius: _bubbleRadius(isMe),
                border: Border.all(
                  color: isMe
                      ? colors.primaryHover.withValues(alpha: 0.22)
                      : colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(hasRichPayload ? 7 : 9),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.isForwarded && !isDeleted) ...[
                      _ForwardedLabel(isMe: isMe),
                      const SizedBox(height: 6),
                    ],

                    if (message.replyTo != null && !isDeleted) ...[
                      ReplyPreview(
                        reply: message.replyTo!,
                        isMe: isMe,
                        onTap: onReplyTap,
                      ),
                      const SizedBox(height: 6),
                    ],

                    if (isDeleted)
                      _DeletedMessage(message: message, isMe: isMe)
                    else ...[
                      if (contactPayload != null)
                        SharedContactBubble(payload: contactPayload, isMe: isMe)
                      else if (locationPayload != null)
                        SharedLocationBubble(
                          payload: locationPayload,
                          isMe: isMe,
                        )
                      else
                        _MessageTextBlock(
                          message: message,
                          isMe: isMe,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                        ),

                      if (message.isTranslating) ...[
                        if (message.hasText || message.hasTranslation)
                          const SizedBox(height: 6),
                        _TranslationLoading(color: mutedTextColor),
                      ],

                      if ((message.translationError ?? '')
                          .trim()
                          .isNotEmpty) ...[
                        if (message.hasText ||
                            message.hasTranslation ||
                            message.isTranslating)
                          const SizedBox(height: 6),
                        _TranslationError(message: message, isMe: isMe),
                      ],

                      if (message.hasAd) ...[
                        if (message.hasText || message.hasTranslation)
                          const SizedBox(height: 6),
                        MessageAdPreview(
                          message: message,
                          isMe: isMe,
                          onTap: onAdTap,
                        ),
                      ],

                      if (message.attachments.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        AttachmentGrid(attachments: message.attachments),
                      ],
                    ],

                    if (message.reactions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ReactionChips(message: message, isMe: isMe),
                    ],

                    const SizedBox(height: 4),
                    _MessageMeta(message: message, isMe: isMe),

                    if (message.isLocalSending)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          l10n.chat_sending,
                          style: TextStyle(fontSize: 11, color: mutedTextColor),
                        ),
                      ),

                    if (message.isLocalFailed) _RetryRow(onRetry: onRetry),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(AppLocalizations l10n) {
    final sender = isMe
        ? l10n.chat_you
        : (message.senderDisplayName ??
              otherDisplayName ??
              l10n.chat_other_user);
    final parts = <String>[sender];
    final text = message.visibleText.trim();
    if (text.isNotEmpty) parts.add(text);
    if (message.isEdited) parts.add(l10n.chat_edited);
    if (message.isStarred) parts.add(l10n.chat_starred);
    if (message.hasTranslation) parts.add(l10n.chat_translated);
    if (message.isLocalSending) {
      parts.add(l10n.chat_sending);
    } else if (message.isLocalFailed) {
      parts.add(l10n.chat_failed_to_send);
    } else if (isMe && message.readAt != null) {
      parts.add(l10n.chat_read);
    } else if (isMe && message.deliveredAt != null) {
      parts.add(l10n.chat_delivered);
    } else if (isMe) {
      parts.add(l10n.chat_sent);
    }
    return parts.join('. ');
  }

  BorderRadius _bubbleRadius(bool ownMessage) {
    return BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(ownMessage ? 16 : 5),
      bottomRight: Radius.circular(ownMessage ? 5 : 16),
    );
  }
}

class _ForwardedLabel extends StatelessWidget {
  const _ForwardedLabel({required this.isMe});

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isMe ? colors.white : colors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shortcut_rounded, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context).chat_forwarded_label,
          style: context.p.copyWith(
            fontSize: 11,
            color: color,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _DeletedMessage extends StatelessWidget {
  const _DeletedMessage({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block_rounded, size: 16, color: colors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            (message.displayText?.trim().isNotEmpty ?? false)
                ? message.displayText!.trim()
                : AppLocalizations.of(context).chat_deleted_message,
            style: context.p.copyWith(
              color: colors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageTextBlock extends StatelessWidget {
  const _MessageTextBlock({
    required this.message,
    required this.isMe,
    required this.textColor,
    required this.mutedTextColor,
  });

  final ChatMessage message;
  final bool isMe;
  final Color textColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    if (message.hasTranslation) {
      final l10n = AppLocalizations.of(context);
      final language = message.translationLanguage?.trim();
      final translationLabel = language == null || language.isEmpty
          ? l10n.chat_translated
          : '${l10n.chat_translated} · $language';

      return Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.hasText) ...[
            Text(
              message.visibleText,
              style: context.p.copyWith(
                color: mutedTextColor,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 7),
          ],
          DecoratedBox(
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                translationLabel,
                style: context.small.copyWith(
                  color: mutedTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message.translatedText,
            style: context.p.copyWith(
              color: textColor,
              fontSize: 13.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (!message.hasText) return const SizedBox.shrink();

    return Text(
      message.visibleText,
      style: context.p.copyWith(color: textColor, fontSize: 13.5, height: 1.3),
    );
  }
}

class _TranslationLoading extends StatelessWidget {
  const _TranslationLoading({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          AppLocalizations.of(context).chat_translating,
          style: context.p.copyWith(
            color: color,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _TranslationError extends StatelessWidget {
  const _TranslationError({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isMe ? colors.white.withValues(alpha: 0.85) : colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            message.translationError!,
            style: context.p.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageMeta extends StatelessWidget {
  const _MessageMeta({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDeleted = message.isDeletedType;
    final color = isMe && !isDeleted ? colors.white : colors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isStarred) ...[
          Icon(Icons.star_rounded, size: 13, color: color),
          const SizedBox(width: 3),
        ],
        Text(
          formatMessageTime(message.createdAt),
          style: context.p.copyWith(fontSize: 10, color: color),
        ),
        if (message.isEdited && !isDeleted) ...[
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).chat_edited,
            style: context.p.copyWith(fontSize: 10, color: color),
          ),
        ],
        if (isMe) const SizedBox(width: 4),
        if (isMe)
          ChatMessageStatusIcon(
            deliveredAt: message.deliveredAt,
            readAt: message.readAt,
            sentColor: colors.white,
            deliveredColor: colors.white,
            readColor: colors.blue,
          ),
      ],
    );
  }
}

class _RetryRow extends StatelessWidget {
  const _RetryRow({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRetry,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 14, color: colors.red),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).chat_tap_to_retry,
              style: TextStyle(
                fontSize: 11,
                color: colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
