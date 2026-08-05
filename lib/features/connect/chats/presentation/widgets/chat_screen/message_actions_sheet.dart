import 'dart:math' as math;

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class MessageActionsSheet extends StatelessWidget {
  const MessageActionsSheet({
    super.key,
    required this.anchor,
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
    required this.onDelete,
  });

  final Offset anchor;
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
  final VoidCallback onDelete;

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
    final isServerBacked =
        !message.isLocalOnly &&
        !message.isLocalSending &&
        !message.isLocalFailed;

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
          label: l10n.chat_delete,
          onTap: onDelete,
          destructive: true,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalMargin = 16.0;
        const pointerHeight = 12.0;
        final cardWidth = math.min(
          320.0,
          math.max(0.0, constraints.maxWidth - (horizontalMargin * 2)),
        );
        final safeTop = media.padding.top + 10;
        final safeBottom =
            constraints.maxHeight -
            media.padding.bottom -
            media.viewInsets.bottom -
            10;
        final availableHeight = math.max(180.0, safeBottom - safeTop);
        final showAbove = anchor.dy > (safeTop + safeBottom) / 2;
        final left = (anchor.dx - cardWidth / 2)
            .clamp(
              horizontalMargin,
              math.max(
                horizontalMargin,
                constraints.maxWidth - cardWidth - horizontalMargin,
              ),
            )
            .toDouble();
        final pointerCenter = (anchor.dx - left)
            .clamp(28.0, math.max(28.0, cardWidth - 28.0))
            .toDouble();

        return CustomSingleChildLayout(
          delegate: _AnchoredActionsLayoutDelegate(
            left: left,
            anchorY: anchor.dy,
            showAbove: showAbove,
            safeTop: safeTop,
            safeBottom: safeBottom,
            gap: 8,
          ),
          child: SizedBox(
            width: cardWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!showAbove)
                  _MessageActionsPointer(
                    width: cardWidth,
                    centerX: pointerCenter,
                    pointsUp: true,
                    fillColor: colors.elevated,
                    borderColor: colors.border,
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: availableHeight - pointerHeight,
                  ),
                  child: Material(
                    color: colors.elevated,
                    elevation: 12,
                    shadowColor: colors.black.withValues(alpha: 0.22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: colors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isDeleted && isServerBacked) ...[
                            _ReactionRow(
                              reactions: _reactions,
                              selectedReaction: message.myReaction,
                              onToggleReaction: onToggleReaction,
                              onChooseReaction: onChooseReaction,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Divider(height: 1, color: colors.border),
                            ),
                          ],
                          _ActionGrid(actions: actions),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showAbove)
                  _MessageActionsPointer(
                    width: cardWidth,
                    centerX: pointerCenter,
                    pointsUp: false,
                    fillColor: colors.elevated,
                    borderColor: colors.border,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnchoredActionsLayoutDelegate extends SingleChildLayoutDelegate {
  const _AnchoredActionsLayoutDelegate({
    required this.left,
    required this.anchorY,
    required this.showAbove,
    required this.safeTop,
    required this.safeBottom,
    required this.gap,
  });

  final double left;
  final double anchorY;
  final bool showAbove;
  final double safeTop;
  final double safeBottom;
  final double gap;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxTop = math.max(safeTop, safeBottom - childSize.height);
    final preferredTop = showAbove
        ? anchorY - childSize.height - gap
        : anchorY + gap;
    final top = preferredTop.clamp(safeTop, maxTop).toDouble();
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _AnchoredActionsLayoutDelegate oldDelegate) {
    return left != oldDelegate.left ||
        anchorY != oldDelegate.anchorY ||
        showAbove != oldDelegate.showAbove ||
        safeTop != oldDelegate.safeTop ||
        safeBottom != oldDelegate.safeBottom ||
        gap != oldDelegate.gap;
  }
}

class _ReactionRow extends StatelessWidget {
  const _ReactionRow({
    required this.reactions,
    required this.selectedReaction,
    required this.onToggleReaction,
    required this.onChooseReaction,
  });

  final List<String> reactions;
  final String? selectedReaction;
  final ValueChanged<String> onToggleReaction;
  final VoidCallback onChooseReaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.chat_message_reactions,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemSize = ((constraints.maxWidth - 12) / 7)
              .clamp(36.0, 42.0)
              .toDouble();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...reactions.map((emoji) {
                final selected = selectedReaction == emoji;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: selected
                      ? l10n.chat_remove_reaction(emoji)
                      : l10n.chat_react_with(emoji),
                  child: InkResponse(
                    radius: itemSize / 2 + 4,
                    onTap: () => onToggleReaction(emoji),
                    child: Container(
                      width: itemSize,
                      height: itemSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }),
              Semantics(
                button: true,
                label: l10n.chat_choose_another_reaction,
                child: InkResponse(
                  radius: itemSize / 2 + 4,
                  onTap: onChooseReaction,
                  child: Container(
                    width: itemSize,
                    height: itemSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<_MessageAction> actions;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledLabelHeight = textScaler.scale(13.0);
    final columns = scaledLabelHeight > 21
        ? 2
        : scaledLabelHeight > 17
        ? 3
        : 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / columns;
        return Wrap(
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
        borderRadius: BorderRadius.circular(12),
        onTap: action.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: foreground, size: 27),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageActionsPointer extends StatelessWidget {
  const _MessageActionsPointer({
    required this.width,
    required this.centerX,
    required this.pointsUp,
    required this.fillColor,
    required this.borderColor,
  });

  final double width;
  final double centerX;
  final bool pointsUp;
  final Color fillColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    const pointerWidth = 26.0;
    const pointerHeight = 12.0;
    final left = (centerX - pointerWidth / 2)
        .clamp(8.0, math.max(8.0, width - pointerWidth - 8))
        .toDouble();

    return SizedBox(
      width: width,
      height: pointerHeight,
      child: Stack(
        children: [
          Positioned(
            left: left,
            child: CustomPaint(
              size: const Size(pointerWidth, pointerHeight),
              painter: _TrianglePainter(
                pointsUp: pointsUp,
                fillColor: fillColor,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({
    required this.pointsUp,
    required this.fillColor,
    required this.borderColor,
  });

  final bool pointsUp;
  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return pointsUp != oldDelegate.pointsUp ||
        fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor;
  }
}
