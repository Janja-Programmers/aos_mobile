import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/presence_label.dart';

import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ChatAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.displayName,
    required this.otherUserId,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
  });

  final String displayName;
  final String otherUserId;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  ConsumerState<ChatAppBar> createState() => _ChatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatAppBarState extends ConsumerState<ChatAppBar> {
  bool _isCalling = false;

  Future<void> _startCall(AOSCallType type) async {
    if (_isCalling) return;

    final manager = ref.read(callManagerProvider.notifier);

    final presenceMap = ref.read(chatPresenceControllerProvider);
    final presence = presenceMap[widget.otherUserId];

    if (presence?.isOnline == false) {
      ShowSnack(context, 'User might be offline');
    }

    setState(() => _isCalling = true);

    try {
      await HapticFeedback.mediumImpact();

      await manager.startOutgoingCall(
        userId: widget.otherUserId,
        callType: type,
      );
    } catch (e) {
      if (mounted) {
        ShowSnack(context, 'Failed to start call');
      }
    } finally {
      if (mounted) {
        setState(() => _isCalling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final presenceMap = ref.watch(chatPresenceControllerProvider);
    final presence = presenceMap[widget.otherUserId];

    final fg = widget.textColor ?? colors.textPrimary;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: BackButton(color: fg),
      centerTitle: false,
      titleSpacing: 0,

      // 🔥 ACTIONS
      actions: [
        IconButton(
          icon: _isCalling
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.call),
          color: fg,
          onPressed: _isCalling ? null : () => _startCall(AOSCallType.audio),
        ),

        IconButton(
          icon: _isCalling
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.videocam),
          color: fg,
          onPressed: _isCalling ? null : () => _startCall(AOSCallType.video),
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
            name: widget.displayName,
            imageUrl: widget.imageUrl,
            radius: 18,
            backgroundColor: colors.border,
            textColor: fg,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.displayName,
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
}
