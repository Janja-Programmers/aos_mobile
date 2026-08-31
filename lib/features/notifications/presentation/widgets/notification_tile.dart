import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/presentation/utils/helpers.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.onLongPress,
  });

  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _hasTriggeredHaptic = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isUnread = !widget.notification.isRead;

    return Dismissible(
      key: ValueKey<String>(widget.notification.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const <DismissDirection, double>{
        DismissDirection.endToStart: 0.35,
      },
      resizeDuration: const Duration(milliseconds: 220),
      movementDuration: const Duration(milliseconds: 220),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.surface),
      ),
      onUpdate: (DismissUpdateDetails details) {
        if (details.progress >= 0.35 && !_hasTriggeredHaptic) {
          _hasTriggeredHaptic = true;
          unawaited(HapticFeedback.mediumImpact());
        } else if (details.progress < 0.35 && _hasTriggeredHaptic) {
          _hasTriggeredHaptic = false;
        }
      },
      confirmDismiss: (_) async {
        await HapticFeedback.selectionClick();
        return true;
      },
      onDismissed: (_) => widget.onDelete(),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnread
                  ? colors.primary.withValues(alpha: .05)
                  : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnread
                    ? colors.primary.withValues(alpha: .2)
                    : colors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildAvatarOrIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.notification.title,
                              style: context.p.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isUnread) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.notification.body,
                        style: context.p,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatTime(widget.notification.createdAt),
                        style: context.smallMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOrIcon(BuildContext context) {
    final colors = context.appColors;
    final String? avatar = widget.notification.actorAvatar;
    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: AppImageDecode.networkProvider(
          context,
          avatar,
          logicalWidth: 40,
          logicalHeight: 40,
        ),
      );
    }

    final IconData iconData = iconForType(widget.notification.type);
    final Color bgColor = colorForType(widget.notification.type, colors);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: bgColor),
    );
  }
}
