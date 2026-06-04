import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

Future<bool?> showChatClearChatDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = dialogContext.appColors;

      return AlertDialog(
        backgroundColor: colors.elevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear chat?', style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'This clears all visible messages in this chat for you only. The other participant will still keep their copy.',
          style: TextStyle(color: colors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Clear',
              style: TextStyle(color: colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );
}
