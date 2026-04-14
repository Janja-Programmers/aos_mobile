import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/presence_label.dart';

import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.displayName,
    required this.otherUser,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
  });

  final String displayName;
  final String otherUser;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final presenceMap = ref.watch(chatPresenceControllerProvider);
    final presence = presenceMap[otherUser];

    final bg = backgroundColor ?? colors.surface;
    final fg = colors.textPrimary;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      leading: BackButton(color: fg),

      centerTitle: false,
      titleSpacing: 0,

      // 🔥 ACTIONS
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          color: fg,
          onPressed: () {
            // TODO: audio call
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: fg,
          onPressed: () {
            // TODO: video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: fg,
          onPressed: () {
            // TODO: menu
          },
        ),
      ],

      title: Row(
        children: [
          const SizedBox(width: 4),

          AppCircularAvatar(
            name: displayName,
            imageUrl: imageUrl,
            radius: 18,
            backgroundColor: bg,
            textColor: fg,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: context.h5.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),

                if (presence != null)
                  PresenceLabel(
                    isOnline: presence.isOnline,
                    lastSeen: presence.lastSeen,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
