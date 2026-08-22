import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

Future<bool?> showChatClearChatDialog(
  BuildContext context, {
  int conversationCount = 1,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = dialogContext.appColors;
      final l10n = AppLocalizations.of(dialogContext);
      final count = conversationCount < 1 ? 1 : conversationCount;

      return AlertDialog(
        backgroundColor: colors.elevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          count == 1
              ? l10n.chat_clear_chat_title
              : l10n.chat_clear_chats_title,
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          count == 1
              ? l10n.chat_clear_chat_description
              : l10n.chat_clear_selected_chats_description(count),
          style: TextStyle(color: colors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.chat_cancel,
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.chat_clear,
              style: TextStyle(color: colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );
}
