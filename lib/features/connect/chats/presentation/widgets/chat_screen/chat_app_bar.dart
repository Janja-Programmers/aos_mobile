import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/presence_label.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChatMenuAction { deleteAllMessages }

class ChatAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.conversationId,
    required this.displayName,
    required this.otherUserId,
    this.imageUrl,
    this.lastSeen,
    this.textColor,
    this.onHeaderTap,
    this.onDeleteMessages,
    this.onDeleteAllMessages,
  });

  final String conversationId;
  final String displayName;
  final String otherUserId;
  final String? imageUrl;
  final DateTime? lastSeen;
  final Color? textColor;
  final VoidCallback? onDeleteMessages;
  final VoidCallback? onDeleteAllMessages;
  final VoidCallback? onHeaderTap;

  @override
  ConsumerState<ChatAppBar> createState() => _ChatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatAppBarState extends ConsumerState<ChatAppBar> {
  bool _isCalling = false;

  Future<void> _startCall(AOSCallType type) async {
    if (_isCalling) return;

    final presenceMap = ref.read(chatPresenceControllerProvider);
    final presence = presenceMap[widget.otherUserId];

    if (presence?.isOnline == false) {
      ShowSnack(context, 'User might be offline').error();
    }

    setState(() => _isCalling = true);

    try {
      await HapticFeedback.mediumImpact();

      final success = await ref
          .read(callStarterServiceProvider)
          .startOutgoingCall(
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
        (map) => map[widget.conversationId] ?? false,
      ),
    );

    final isOnline = ref
        .read(chatPresenceControllerProvider.notifier)
        .isUserOnline(widget.otherUserId);

    final lastSeen = presence?.lastSeen ?? widget.lastSeen;

    final fg = widget.textColor ?? colors.textPrimary;
    final bg = colors.surface;

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

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onHeaderTap,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: AppCircularAvatar(
                name: widget.displayName,
                imageUrl: widget.imageUrl,
                radius: 18,
                backgroundColor: colors.border,
                textColor: fg,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onHeaderTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      widget.displayName,
                      style: context.h5.copyWith(color: fg),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
        /// 📞 CALL MENU
        PopupMenuButton<AOSCallType>(
          enabled: !_isCalling,
          color: colors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: colors.black.withValues(alpha: 0.12),
          elevation: 8,
          offset: const Offset(0, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          icon: _isCalling
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.call_outlined, color: fg),
          onSelected: _startCall,
          itemBuilder: (context) {
            return [
              PopupMenuItem<AOSCallType>(
                value: AOSCallType.audio,
                child: Row(
                  children: [
                    Icon(Icons.call_outlined, color: colors.textPrimary),
                    const SizedBox(width: 10),
                    Text(
                      'Audio call',
                      style: context.p.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<AOSCallType>(
                value: AOSCallType.video,
                child: Row(
                  children: [
                    Icon(Icons.videocam_outlined, color: colors.textPrimary),
                    const SizedBox(width: 10),
                    Text(
                      'Video call',
                      style: context.p.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),

        /// ⋮ MENU
        PopupMenuButton<ChatMenuAction>(
          color: colors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: colors.black.withValues(alpha: 0.12),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          icon: Icon(Icons.more_vert, color: fg),
          onSelected: (action) {
            switch (action) {
              case ChatMenuAction.deleteAllMessages:
                widget.onDeleteAllMessages?.call();
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem<ChatMenuAction>(
                value: ChatMenuAction.deleteAllMessages,
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, color: colors.red),
                    const SizedBox(width: 10),
                    Text(
                      'Clear chats',
                      style: context.p.copyWith(color: colors.red),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
