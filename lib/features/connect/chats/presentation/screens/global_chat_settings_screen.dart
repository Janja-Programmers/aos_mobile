import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_wallpaper_sheet.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GlobalChatSettingsScreen extends ConsumerWidget {
  const GlobalChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final preferences = ref.watch(
      chatLocalPreferencesControllerProvider(
        chatGlobalPreferencesConversationId,
      ),
    );
    final controller = ref.read(
      chatLocalPreferencesControllerProvider(
        chatGlobalPreferencesConversationId,
      ).notifier,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.chat_settings_title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _SectionTitle(l10n.chat_privacy),
            _SettingsCard(
              children: [
                _ReadOnlySwitchTile(
                  icon: Icons.done_all_rounded,
                  title: l10n.chat_read_receipts,
                  subtitle: l10n.chat_read_receipts_managed,
                  value: true,
                ),
                const _CardDivider(),
                _ReadOnlySwitchTile(
                  icon: Icons.visibility_outlined,
                  title: l10n.chat_last_seen_online,
                  subtitle: l10n.chat_no_backend_preference,
                  value: true,
                ),
                const _CardDivider(),
                ListTile(
                  leading: const Icon(Icons.block_rounded),
                  title: Text(l10n.chat_blocked_contacts),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.pushNamed(AppRoutes.nBlockedUsers),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionTitle(l10n.chat_chats_section),
            _SettingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.wallpaper_outlined),
                  title: Text(l10n.chat_wallpaper),
                  subtitle: Text(l10n.chat_wallpaper_description),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => unawaited(
                    showChatWallpaperSheet(
                      context: context,
                      conversationId: chatGlobalPreferencesConversationId,
                    ),
                  ),
                ),
                const _CardDivider(),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.keyboard_return_rounded),
                  title: Text(l10n.chat_enter_is_send),
                  subtitle: Text(l10n.chat_enter_is_send_description),
                  value: preferences.enterToSend,
                  onChanged: preferences.saving
                      ? null
                      : (value) => unawaited(controller.setEnterToSend(value)),
                ),
                const _CardDivider(),
                _ReadOnlySwitchTile(
                  icon: Icons.download_rounded,
                  title: l10n.chat_media_auto_download,
                  subtitle: l10n.chat_unavailable_backend,
                  value: false,
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionTitle(l10n.chat_notifications),
            _SettingsCard(
              children: [
                _ReadOnlySwitchTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l10n.chat_message_notifications,
                  subtitle: l10n.chat_system_notification_settings,
                  value: true,
                ),
                const _CardDivider(),
                _ReadOnlySwitchTile(
                  icon: Icons.call_outlined,
                  title: l10n.chat_call_notifications,
                  subtitle: l10n.chat_system_notification_settings,
                  value: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Text(label, style: context.h5.copyWith(color: colors.primary)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.elevated,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.border),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 64, color: context.appColors.border);
  }
}

class _ReadOnlySwitchTile extends StatelessWidget {
  const _ReadOnlySwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: false,
      value: value
          ? AppLocalizations.of(context).chat_on
          : AppLocalizations.of(context).chat_off,
      hint: subtitle,
      child: SwitchListTile.adaptive(
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: null,
      ),
    );
  }
}
