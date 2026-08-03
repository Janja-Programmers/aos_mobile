import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/translation_language.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class TranslationLanguagePicker extends StatelessWidget {
  const TranslationLanguagePicker({
    super.key,
    required this.initialLanguage,
  });

  final TranslationLanguage initialLanguage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.78),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.chat_translate_to,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: chatTranslationLanguages.length,
                itemBuilder: (context, index) {
                  final language = chatTranslationLanguages[index];
                  final languageLabel = _languageLabel(l10n, language.code);
                  final selected = language.code == initialLanguage.code;

                  return Semantics(
                    button: true,
                    selected: selected,
                    label: l10n.chat_translate_to_language(languageLabel),
                    child: ListTile(
                      minTileHeight: 58,
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 30),
                      ),
                      title: Text(
                        languageLabel,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 17,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check_rounded, color: colors.primary)
                          : null,
                      onTap: () => Navigator.of(context).pop(language),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, String code) {
    return switch (code) {
      'eng_Latn' => l10n.chat_language_english,
      'swh_Latn' => l10n.chat_language_swahili,
      'fra_Latn' => l10n.chat_language_french,
      'spa_Latn' => l10n.chat_language_spanish,
      'deu_Latn' => l10n.chat_language_german,
      'por_Latn' => l10n.chat_language_portuguese,
      'arb_Arab' => l10n.chat_language_arabic,
      'hau_Latn' => l10n.chat_language_hausa,
      'yor_Latn' => l10n.chat_language_yoruba,
      'ibo_Latn' => l10n.chat_language_igbo,
      'amh_Ethi' => l10n.chat_language_amharic,
      'som_Latn' => l10n.chat_language_somali,
      'kin_Latn' => l10n.chat_language_kinyarwanda,
      'lug_Latn' => l10n.chat_language_luganda,
      'zul_Latn' => l10n.chat_language_zulu,
      'xho_Latn' => l10n.chat_language_xhosa,
      _ => code,
    };
  }
}
