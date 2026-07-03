import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> showChatSettingsSheet({
  required BuildContext context,
  required String conversationId,
  required VoidCallback onAudioCall,
  required VoidCallback onVideoCall,
  required VoidCallback onChangeWallpaper,
  required VoidCallback onClearChat,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ChatSettingsSheet(
      conversationId: conversationId,
      onAudioCall: onAudioCall,
      onVideoCall: onVideoCall,
      onChangeWallpaper: onChangeWallpaper,
      onClearChat: onClearChat,
    ),
  );
}

class ChatSettingsSheet extends ConsumerWidget {
  const ChatSettingsSheet({
    super.key,
    required this.conversationId,
    required this.onAudioCall,
    required this.onVideoCall,
    required this.onChangeWallpaper,
    required this.onClearChat,
  });

  final String conversationId;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback onChangeWallpaper;
  final VoidCallback onClearChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final preferences = ref.watch(
      chatLocalPreferencesControllerProvider(conversationId),
    );
    final controller = ref.read(
      chatLocalPreferencesControllerProvider(conversationId).notifier,
    );

    void updateEnterToSend(bool value) {
      unawaited(controller.setEnterToSend(value));
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.52,
      maxChildSize: 0.90,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: Text('Chat Settings', style: context.h4)),
              const SizedBox(height: 28),
              _SettingsSection(
                title: 'Calls',
                children: [
                  _SettingsTile(
                    icon: Icons.call_outlined,
                    title: 'Call',
                    subtitle: 'Start an audio call',
                    onTap: onAudioCall,
                  ),
                  _SettingsTile(
                    icon: Icons.videocam_outlined,
                    title: 'Video call',
                    subtitle: 'Start a video call',
                    onTap: onVideoCall,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SettingsSection(
                title: 'Chats',
                children: [
                  _SettingsTile(
                    icon: Icons.wallpaper_rounded,
                    title: 'Chat wallpaper',
                    subtitle: 'Set a background for this chat',
                    onTap: onChangeWallpaper,
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.keyboard_return_rounded,
                    title: 'Enter is send',
                    subtitle: 'Enter key sends your message',
                    value: preferences.enterToSend,
                    onChanged: updateEnterToSend,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SettingsSection(
                title: 'Privacy',
                children: [
                  _SettingsTile(
                    icon: Icons.block_rounded,
                    title: 'Blocked contacts',
                    subtitle: 'Review people you have blocked',
                    onTap: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context).pop();
                      unawaited(router.pushNamed(AppRoutes.nBlockedUsers));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SettingsSection(
                title: 'Danger zone',
                children: [
                  _SettingsTile(
                    icon: Icons.delete_sweep_outlined,
                    title: 'Clear chat',
                    subtitle: 'Delete this conversation from your view',
                    destructive: true,
                    onTap: onClearChat,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(
            title,
            style: context.sectionHeaderTinted.copyWith(fontSize: 16),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = destructive ? colors.red : colors.textPrimary;

    return ListTile(
      minLeadingWidth: 30,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: destructive ? colors.red : colors.textMuted),
      title: Text(title, style: context.pStrong.copyWith(color: foreground)),
      subtitle: Text(
        subtitle,
        style: context.small.copyWith(color: colors.textMuted),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 16),
      secondary: Icon(icon, color: colors.textMuted),
      title: Text(title, style: context.pStrong),
      subtitle: Text(
        subtitle,
        style: context.small.copyWith(color: colors.textMuted),
      ),
      value: value,
      activeThumbColor: colors.white,
      activeTrackColor: colors.primary,
      onChanged: onChanged,
    );
  }
}
