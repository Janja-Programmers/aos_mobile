class TranslationLanguage {
  final String code;
  final String label;

  const TranslationLanguage({required this.code, required this.label});
}

const List<TranslationLanguage> chatTranslationLanguages = [
  TranslationLanguage(code: 'eng_Latn', label: 'English'),
  TranslationLanguage(code: 'swh_Latn', label: 'Swahili'),
  TranslationLanguage(code: 'fra_Latn', label: 'French'),
  TranslationLanguage(code: 'spa_Latn', label: 'Spanish'),
  TranslationLanguage(code: 'por_Latn', label: 'Portuguese'),
  TranslationLanguage(code: 'arb_Arab', label: 'Arabic'),
  TranslationLanguage(code: 'hau_Latn', label: 'Hausa'),
  TranslationLanguage(code: 'yor_Latn', label: 'Yoruba'),
  TranslationLanguage(code: 'ibo_Latn', label: 'Igbo'),
  TranslationLanguage(code: 'amh_Ethi', label: 'Amharic'),
  TranslationLanguage(code: 'som_Latn', label: 'Somali'),
  TranslationLanguage(code: 'kin_Latn', label: 'Kinyarwanda'),
  TranslationLanguage(code: 'lug_Latn', label: 'Luganda'),
  TranslationLanguage(code: 'zul_Latn', label: 'Zulu'),
  TranslationLanguage(code: 'xho_Latn', label: 'Xhosa'),
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
