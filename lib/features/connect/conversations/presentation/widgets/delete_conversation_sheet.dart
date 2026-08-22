import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class DeleteConversationSheet extends StatelessWidget {
  final String? displayName;
  final int selectedCount;

  const DeleteConversationSheet({
    super.key,
    this.displayName,
    this.selectedCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    final normalizedCount = selectedCount < 1 ? 1 : selectedCount;
    final cleanDisplayName = displayName?.trim();
    final name = cleanDisplayName != null && cleanDisplayName.isNotEmpty
        ? cleanDisplayName
        : l10n.chat_this_user;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: colors.white,
                size: 30,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              normalizedCount == 1
                  ? l10n.chat_delete_chat_title
                  : l10n.chat_delete_conversations_title,
              textAlign: TextAlign.center,
              style: context.h4.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              normalizedCount == 1
                  ? l10n.chat_delete_chat_description(name)
                  : l10n.chat_delete_selected_conversations_description(
                      normalizedCount,
                    ),
              textAlign: TextAlign.center,
              style: context.pMuted.copyWith(height: 1.4),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.chat_cancel),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.chat_delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
