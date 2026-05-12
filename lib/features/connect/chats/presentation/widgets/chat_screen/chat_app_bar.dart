import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/presence_label.dart';

import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ChatAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.conversationId,
    required this.displayName,
    required this.otherUserId,
    this.imageUrl,
    this.lastSeen,
    this.backgroundColor,
    this.textColor,
  });

  final String conversationId;
  final String displayName;
  final String otherUserId;
  final String? imageUrl;
  final DateTime? lastSeen;
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
      ShowSnack(context, 'User might be offline').error();
    }

    setState(() => _isCalling = true);

    try {
      await HapticFeedback.mediumImpact();

      final success = await manager.startOutgoingCall(
        userId: widget.otherUserId,
        callType: type,
        receiver: CallParticipant(
          userId: widget.otherUserId,
          displayName: widget.displayName,
          avatarUrl: widget.imageUrl,
        ),
      );

      if (!success && mounted) {
        ShowSnack(context, 'Failed to start call').error();
      }
    } catch (_) {
      if (mounted) {
        ShowSnack(context, 'Failed to start call').error();
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

    final presence = ref.watch(
      chatPresenceControllerProvider.select((map) => map[widget.otherUserId]),
    );

    final isTyping = ref.watch(
      chatTypingControllerProvider.select(
        (map) => map[widget.conversationId] == true,
      ),
    );

    final isOnline = ref
        .read(chatPresenceControllerProvider.notifier)
        .isUserOnline(widget.otherUserId);

    final lastSeen = presence?.lastSeen ?? widget.lastSeen;

    final fg = widget.textColor ?? colors.textPrimary;
    final bg = widget.backgroundColor ?? colors.surface;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      leading: BackButton(color: fg),
      centerTitle: false,
      titleSpacing: 0,

      // -----------------------------
      // TITLE
      // -----------------------------
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

                PresenceLabel(
                  isTyping: isTyping,
                  isOnline: isOnline,
                  lastSeen: lastSeen,
                ),
              ],
            ),
          ),
        ],
      ),

      // -----------------------------
      // ACTIONS
      // -----------------------------
      actions: [
        /// 📞 AUDIO CALL
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

        /// 🎥 VIDEO CALL
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

        /// ⋮ MENU
        PopupMenuButton<int>(
          color: colors.surface,
          surfaceTintColor: colors.surface,
          shadowColor: colors.black.withOpacity(0.12),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border, width: 1),
          ),
          icon: Icon(Icons.more_vert, color: fg),
          onSelected: (index) => AppNavigation.goTo(context, ref, index),
          itemBuilder: (context) {
            final items = AppNavConfig.items(context);
            final location = GoRouterState.of(context).matchedLocation;

            return List.generate(items.length, (i) {
              final item = items[i];
              final isActive = location.contains(item.routeName);

              return PopupMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isActive ? colors.primary : colors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: context.p.copyWith(
                        color: isActive ? colors.primary : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ],
    );
  }
}
