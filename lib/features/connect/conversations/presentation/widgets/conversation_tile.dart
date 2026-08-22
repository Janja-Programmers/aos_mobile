import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_message_status_icon.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;
  final String? currentUserCanonicalId;

  final bool isOnline;
  final bool isTyping;
  final DateTime? lastSeen;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.currentUserCanonicalId,
    this.isOnline = false,
    this.isTyping = false,
    this.lastSeen,
    this.onLongPress,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  Color _avatarColor(BuildContext context) {
    final appColors = context.appColors;

    final colors = [
      appColors.red,
      appColors.success,
      appColors.orange,
      appColors.chatCardColor,
    ];

    return colors[conversation.displayName.hashCode % colors.length];
  }

  Widget _buildSubtitle(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    if (isTyping) {
      return Text(
        l10n.chat_typing,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.success,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final message = conversation.lastMessage ?? '';
    final isMine = conversation.isLastMessageMine(currentUserCanonicalId);

    if (!isMine) {
      return Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.textMuted, fontSize: 13),
      );
    }

    return Row(
      children: [
        _buildMessageStatusIcon(context),
        const SizedBox(width: 4),
        Text(
          '${l10n.chat_you}: ',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatusIcon(BuildContext context) {
    return ChatMessageStatusIcon(
      deliveredAt: conversation.lastMessageDeliveredAt,
      readAt: conversation.lastMessageReadAt,
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      selected: selectionMode ? isSelected : null,
      child: ListTile(
        onTap: selectionMode
            ? () => onSelectionChanged?.call(!isSelected)
            : onTap,
        onLongPress: onLongPress,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        horizontalTitleGap: 12,
        minVerticalPadding: 6,
        visualDensity: const VisualDensity(vertical: -1),

        // -------------------------
        // AVATAR
        // -------------------------
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectionMode) ...[
              Semantics(
                button: true,
                checked: isSelected,
                label: conversation.displayName,
                child: IconButton(
                  tooltip: conversation.displayName,
                  onPressed: () => onSelectionChanged?.call(!isSelected),
                  icon: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? colors.primary : colors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Stack(
              children: [
                AppCircularAvatar(
                  name: conversation.displayName,
                  imageUrl: conversation.avatar,
                  radius: 24,
                  backgroundColor: _avatarColor(context),
                  textColor: colors.white,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // -------------------------
        // TITLE
        // -------------------------
        title: Text(
          conversation.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodyStrong.copyWith(fontSize: 14),
        ),

        // -------------------------
        // SUBTITLE
        // -------------------------
        subtitle: _buildSubtitle(context),

        // -------------------------
        // TRAILING (time + unread)
        // -------------------------
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (conversation.lastMessageAt != null)
              Text(
                formatTime(conversation.lastMessageAt!),
                style: context.p.copyWith(
                  fontSize: 11,
                  color: conversation.unreadCount > 0
                      ? colors.primary
                      : colors.textMuted,
                ),
              ),

            if (conversation.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(minWidth: 24),
                child: Text(
                  _formatUnread(conversation.unreadCount),
                  textAlign: TextAlign.center,
                  style: context.p.copyWith(
                    color: colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatUnread(int count) {
    if (count > 99) return '99+';
    return count.toString();
  }
}
