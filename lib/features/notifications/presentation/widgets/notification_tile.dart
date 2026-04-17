import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/utils/format_time.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/presentation/utils/helpers.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/primary_action_button.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/secondary_action_button.dart';

class NotificationTile extends StatefulWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

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
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isUnread = !widget.notification.isRead;
    final action = _buildAction(context);

    return Dismissible(
      key: ValueKey(widget.notification.id),
      direction: DismissDirection.endToStart,

      // 👉 Swipe action
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: colors.primary.withOpacity(.1),
        child: Icon(Icons.mark_email_read, color: colors.primary),
      ),

      onDismissed: (_) {
        widget.onMarkRead();
      },

      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnread ? colors.primary.withOpacity(.05) : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread ? colors.primary.withOpacity(.2) : colors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text(widget.notification.body, style: context.p),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatTime(widget.notification.createdAt),
                        style: const TextStyle(fontSize: 12),
                      ),

                      // 🔴 Animated unread dot
                      if (isUnread)
                        ScaleTransition(
                          scale: _pulseController,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              if (action != null) ...[const SizedBox(height: 10), action],
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ICON / AVATAR
  // =====================================================
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

  Widget? _buildAction(BuildContext context) {
    final colors = context.appColors;

    switch (widget.notification.type) {
      case NotificationType.liveStarted:
        return PrimaryActionButton(
          label: 'Join Live',
          color: colors.primary,
          onTap: widget.onTap,
        );

      case NotificationType.adApproved:
      case NotificationType.adRejected:
        return SecondaryActionButton(
          label: 'View Details',
          onTap: widget.onTap,
        );

      default:
        return null;
    }
  }
}
