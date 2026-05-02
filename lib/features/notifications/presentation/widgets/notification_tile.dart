import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/utils/format_time.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/presentation/utils/helpers.dart';

class NotificationTile extends StatefulWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    if (!widget.notification.isRead) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant NotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.notification.isRead) {
      _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isUnread = !widget.notification.isRead;

    return Dismissible(
      key: ValueKey(widget.notification.id),
      direction: DismissDirection.endToStart,

      dismissThresholds: const {DismissDirection.endToStart: 0.35},

      resizeDuration: const Duration(milliseconds: 220),
      movementDuration: const Duration(milliseconds: 220),

      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),

      onUpdate: (details) {
        if (details.progress >= 0.35 && !_hasTriggeredHaptic) {
          _hasTriggeredHaptic = true;
          HapticFeedback.mediumImpact();
        }

        if (details.progress < 0.35 && _hasTriggeredHaptic) {
          _hasTriggeredHaptic = false;
        }
      },

      confirmDismiss: (_) async {
        await HapticFeedback.selectionClick();
        return true;
      },

      onDismissed: (_) {
        widget.onDelete();
      },

      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnread ? colors.primary.withOpacity(.05) : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread ? colors.primary.withOpacity(.2) : colors.border,
            ),
          ),
          child: Row(
            children: [
              _buildAvatarOrIcon(context),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notification.title,
                      style: TextStyle(
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.body,
                      style: context.p,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTime(widget.notification.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 6),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: isUnread
                        ? Container(
                            key: const ValueKey('unread-dot'),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('no-dot'),
                            width: 8,
                            height: 8,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOrIcon(BuildContext context) {
    final colors = context.appColors;
    final avatar = widget.notification.actorAvatar;

    if (avatar != null) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar));
    }

    final iconData = iconForType(widget.notification.type);
    final bgColor = colorForType(widget.notification.type, colors);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: bgColor),
    );
  }
}
