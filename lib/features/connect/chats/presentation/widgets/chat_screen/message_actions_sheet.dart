import 'dart:math' as math;

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class MessageActionsSheet extends StatelessWidget {
  const MessageActionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    required this.canEdit,
    required this.onReply,
    required this.onEdit,
    required this.onCopy,
    required this.onToggleStar,
    required this.onToggleReaction,
    required this.onChooseReaction,
    required this.onTranslate,
    required this.onForward,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
  });

  final ChatMessage message;
  final bool isMe;
  final bool canEdit;

  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onToggleStar;
  final ValueChanged<String> onToggleReaction;
  final VoidCallback onChooseReaction;
  final VoidCallback onTranslate;
  final VoidCallback onForward;
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForEveryone;

  static const List<String> _reactions = <String>[
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
    '👍',
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDeleted = message.isDeletedType;
    final isServerBacked = !message.isLocalOnly &&
        !message.isLocalSending &&
        !message.isLocalFailed;
    final availableHeight = media.size.height -
        media.padding.top -
        media.viewInsets.bottom -
        24;
    final maxHeight = math.max(
      180.0,
      math.min(media.size.height * 0.82, availableHeight),
    );

    final actions = <_MessageAction>[
      if (!isDeleted && isServerBacked)
        _MessageAction(
          icon: Icons.reply_rounded,
          label: l10n.chat_reply,
          onTap: onReply,
        ),
      if (isMe && !isDeleted && isServerBacked && canEdit)
        _MessageAction(
          icon: Icons.edit_outlined,
          label: l10n.chat_edit,
          onTap: onEdit,
        ),
      if (!isDeleted && message.visibleText.trim().isNotEmpty)
        _MessageAction(
          icon: Icons.content_copy_rounded,
          label: l10n.chat_copy,
          onTap: onCopy,
        ),
      if (!isDeleted && isServerBacked)
        _MessageAction(
          icon: Icons.shortcut_rounded,
          label: l10n.chat_forward,
          onTap: onForward,
        ),
      if (!isDeleted && isServerBacked)
        _MessageAction(
          icon: Icons.translate_rounded,
          label: message.hasTranslation
              ? l10n.chat_translate_again
              : l10n.chat_translate,
          onTap: onTranslate,
        ),
      if (!isDeleted && isServerBacked)
        _MessageAction(
          icon: message.isStarred
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          label: message.isStarred ? l10n.chat_unstar : l10n.chat_star,
          onTap: onToggleStar,
        ),
      if (isServerBacked)
        _MessageAction(
          icon: Icons.delete_outline_rounded,
          label: l10n.chat_delete_for_me,
          onTap: onDeleteForMe,
          destructive: true,
        ),
      if (isMe && !isDeleted && isServerBacked)
        _MessageAction(
          icon: Icons.delete_forever_outlined,
          label: l10n.chat_delete_for_everyone,
          onTap: onDeleteForEveryone,
          destructive: true,
        ),
    ];

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          math.max(12, media.viewInsets.bottom + 12),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 620, maxHeight: maxHeight),
            child: Material(
              color: colors.elevated,
              elevation: 12,
              shadowColor: colors.black.withValues(alpha: 0.24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isDeleted && isServerBacked) ...[
                      Semantics(
                        label: l10n.chat_message_reactions,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 8,
                          children: [
                            ..._reactions.map((emoji) {
                              final selected = message.myReaction == emoji;
                              return Semantics(
                                button: true,
                                selected: selected,
                                label: selected
                                    ? l10n.chat_remove_reaction(emoji)
                                    : l10n.chat_react_with(emoji),
                                child: InkResponse(
                                  radius: 28,
                                  onTap: () => onToggleReaction(emoji),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? colors.primary.withValues(
                                              alpha: 0.12,
                                            )
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            Semantics(
                              button: true,
                              label: l10n.chat_choose_another_reaction,
                              child: InkResponse(
                                radius: 28,
                                onTap: onChooseReaction,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: colors.border),
                    ],
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth >= 480
                            ? (constraints.maxWidth - 32) / 4
                            : (constraints.maxWidth - 24) / 3;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: actions
                              .map(
                                (action) => SizedBox(
                                  width: itemWidth,
                                  child: _ActionButton(action: action),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageAction {
  const _MessageAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final _MessageAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = action.destructive ? colors.red : colors.textPrimary;

    return Semantics(
      button: true,
      label: action.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, color: foreground, size: 28),
              const SizedBox(height: 7),
              Text(
                action.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
