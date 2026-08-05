import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/presence_label.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _chatAppBarHeight = 64;

enum ChatMenuAction { audioCall, videoCall, changeWallpaper }

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
    this.onChangeWallpaper,
    this.onBack,
  });

  final String conversationId;
  final String displayName;
  final String otherUserId;
  final String? imageUrl;
  final DateTime? lastSeen;
  final Color? textColor;
  final VoidCallback? onChangeWallpaper;
  final VoidCallback? onBack;
  final VoidCallback? onHeaderTap;

  @override
  ConsumerState<ChatAppBar> createState() => _ChatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(_chatAppBarHeight);
}

class _ChatAppBarState extends ConsumerState<ChatAppBar> {
  bool _isCalling = false;

  Future<void> _startCall(AOSCallType type) async {
    if (_isCalling) return;

    final presenceMap = ref.read(chatPresenceControllerProvider);
    final presence = presenceMap[widget.otherUserId];

    if (presence?.isOnline == false) {
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_user_might_be_offline,
      ).error();
    }

    setState(() => _isCalling = true);

    try {
      await HapticFeedback.mediumImpact();
      if (!mounted) return;

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

      if (!mounted) return;

      if (!success) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_call,
        ).error();
      }
    } on Object {
      if (mounted) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_call,
        ).error();
      }
    } finally {
      if (mounted) {
        setState(() => _isCalling = false);
      }
    }
  }

  void _handleMenuAction(ChatMenuAction action) {
    switch (action) {
      case ChatMenuAction.audioCall:
        unawaited(_startCall(AOSCallType.audio));
        break;
      case ChatMenuAction.videoCall:
        unawaited(_startCall(AOSCallType.video));
        break;
      case ChatMenuAction.changeWallpaper:
        widget.onChangeWallpaper?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
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
    final foreground = widget.textColor ?? colors.textPrimary;

    return AppBar(
      toolbarHeight: _chatAppBarHeight,
      backgroundColor: colors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 54,
      leading: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Center(
          child: _RoundIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: l10n.chat_back,
            color: foreground,
            onTap: widget.onBack,
          ),
        ),
      ),
      centerTitle: false,
      titleSpacing: 2,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onHeaderTap,
        child: Row(
          children: [
            AppCircularAvatar(
              name: widget.displayName,
              imageUrl: widget.imageUrl,
              radius: 22,
              backgroundColor: colors.primary.withValues(alpha: 0.18),
              textColor: colors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.displayName,
                    style: context.h5.copyWith(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
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
      ),
      actions: [
        PopupMenuButton<ChatMenuAction>(
          enabled: !_isCalling,
          color: colors.elevated,
          surfaceTintColor: Colors.transparent,
          shadowColor: colors.black.withValues(alpha: 0.20),
          elevation: 12,
          offset: const Offset(-6, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          icon: _isCalling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.more_vert_rounded, color: foreground, size: 26),
          onSelected: _handleMenuAction,
          itemBuilder: (context) {
            return [
              _menuItem(
                context,
                value: ChatMenuAction.audioCall,
                icon: Icons.call_outlined,
                label: l10n.chat_call,
              ),
              _menuItem(
                context,
                value: ChatMenuAction.videoCall,
                icon: Icons.videocam_outlined,
                label: l10n.chat_video_call,
              ),
              _menuItem(
                context,
                value: ChatMenuAction.changeWallpaper,
                icon: Icons.wallpaper_rounded,
                label: l10n.chat_change_wallpaper,
              ),
            ];
          },
        ),
        const SizedBox(width: 2),
      ],
    );
  }

  PopupMenuItem<ChatMenuAction> _menuItem(
    BuildContext context, {
    required ChatMenuAction value,
    required IconData icon,
    required String label,
    bool destructive = false,
  }) {
    final colors = context.appColors;
    final color = destructive ? colors.red : colors.textPrimary;

    return PopupMenuItem<ChatMenuAction>(
      value: value,
      child: SizedBox(
        width: 190,
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.pStrong.copyWith(color: color, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}
