import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showChatWallpaperSheet({
  required BuildContext context,
  required String conversationId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ChatWallpaperSheet(conversationId: conversationId),
  );
}

class ChatWallpaperSheet extends ConsumerWidget {
  const ChatWallpaperSheet({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final preferences = ref.watch(
      chatLocalPreferencesControllerProvider(conversationId),
    );
    final controller = ref.read(
      chatLocalPreferencesControllerProvider(conversationId).notifier,
    );

    void applyDefaultWallpaper() {
      unawaited(() async {
        await controller.resetWallpaper();
        if (!context.mounted) return;
        ShowSnack(context, l10n.chat_default_wallpaper_applied).success();
      }());
    }

    void chooseGalleryWallpaper() {
      unawaited(() async {
        final changed = await controller.chooseGalleryWallpaper();
        if (!context.mounted || !changed) return;
        ShowSnack(context, l10n.chat_wallpaper_updated).success();
      }());
    }

    void applySolidWallpaper(ChatWallpaperOption option) {
      unawaited(() async {
        await controller.setWallpaper(option.id);
        if (!context.mounted) return;
        final label = _wallpaperLabel(l10n, option.id);
        ShowSnack(
          context,
          l10n.chat_named_wallpaper_applied(label),
        ).success();
      }());
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.44,
      maxChildSize: 0.84,
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
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
              const SizedBox(height: 28),
              Text(l10n.chat_wallpaper, style: context.h5),
              const SizedBox(height: 6),
              Text(
                l10n.chat_choose_conversation_background,
                style: context.pMuted,
              ),
              const SizedBox(height: 22),
              _WallpaperActionTile(
                icon: Icons.refresh_rounded,
                title: l10n.chat_default,
                selected: preferences.wallpaperId == chatWallpaperDefaultId,
                onTap: applyDefaultWallpaper,
              ),
              const SizedBox(height: 12),
              _WallpaperActionTile(
                icon: Icons.photo_library_outlined,
                title: l10n.chat_choose_from_gallery,
                selected: preferences.wallpaperId == chatWallpaperGalleryId,
                onTap: chooseGalleryWallpaper,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.chat_solid_colors,
                style: context.pStrong.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 18,
                runSpacing: 20,
                children: [
                  for (final option in chatSolidWallpaperOptions)
                    _WallpaperColorButton(
                      option: option,
                      label: _wallpaperLabel(l10n, option.id),
                      selected: preferences.wallpaperId == option.id,
                      onTap: () => applySolidWallpaper(option),
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

String _wallpaperLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'midnight' => l10n.chat_wallpaper_midnight,
    'navy' => l10n.chat_wallpaper_navy,
    'forest' => l10n.chat_wallpaper_forest,
    'plum' => l10n.chat_wallpaper_plum,
    'charcoal' => l10n.chat_wallpaper_charcoal,
    'maroon' => l10n.chat_wallpaper_maroon,
    'teal' => l10n.chat_wallpaper_teal,
    'coffee' => l10n.chat_wallpaper_coffee,
    _ => id,
  };
}

class _WallpaperActionTile extends StatelessWidget {
  const _WallpaperActionTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.elevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? colors.primary : colors.textMuted),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: context.pStrong)),
              if (selected)
                Icon(Icons.check_circle_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _WallpaperColorButton extends StatelessWidget {
  const _WallpaperColorButton({
    required this.option,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ChatWallpaperOption option;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 74,
          height: 74,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 3 : 1,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
              border: Border.all(color: option.borderColor ?? colors.border),
            ),
            child: selected
                ? Icon(Icons.check_rounded, color: colors.white, size: 28)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
