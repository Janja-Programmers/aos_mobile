class TranslationLanguage {
  const TranslationLanguage({
    required this.code,
    required this.label,
    required this.flag,
  });

  final String code;
  final String label;
  final String flag;
}

const List<TranslationLanguage> chatTranslationLanguages = [
  TranslationLanguage(code: 'eng_Latn', label: 'English', flag: '🇬🇧'),
  TranslationLanguage(code: 'swh_Latn', label: 'Swahili', flag: '🇰🇪'),
  TranslationLanguage(code: 'fra_Latn', label: 'French', flag: '🇫🇷'),
  TranslationLanguage(code: 'spa_Latn', label: 'Spanish', flag: '🇪🇸'),
  TranslationLanguage(code: 'deu_Latn', label: 'German', flag: '🇩🇪'),
  TranslationLanguage(code: 'por_Latn', label: 'Portuguese', flag: '🇵🇹'),
  TranslationLanguage(code: 'arb_Arab', label: 'Arabic', flag: '🇸🇦'),
  TranslationLanguage(code: 'hau_Latn', label: 'Hausa', flag: '🇳🇬'),
  TranslationLanguage(code: 'yor_Latn', label: 'Yoruba', flag: '🇳🇬'),
  TranslationLanguage(code: 'ibo_Latn', label: 'Igbo', flag: '🇳🇬'),
  TranslationLanguage(code: 'amh_Ethi', label: 'Amharic', flag: '🇪🇹'),
  TranslationLanguage(code: 'som_Latn', label: 'Somali', flag: '🇸🇴'),
  TranslationLanguage(code: 'kin_Latn', label: 'Kinyarwanda', flag: '🇷🇼'),
  TranslationLanguage(code: 'lug_Latn', label: 'Luganda', flag: '🇺🇬'),
  TranslationLanguage(code: 'zul_Latn', label: 'Zulu', flag: '🇿🇦'),
  TranslationLanguage(code: 'xho_Latn', label: 'Xhosa', flag: '🇿🇦'),
];

TranslationLanguage chatTranslationLanguageByCode(String? code) {
  final cleanCode = code?.trim();

  if (cleanCode == null || cleanCode.isEmpty) {
    return chatTranslationLanguages.first;
  }

  return chatTranslationLanguages.firstWhere(
    (language) => language.code == cleanCode,
    orElse: () => chatTranslationLanguages.first,
  );
}
