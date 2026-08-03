import 'package:africaonlinestores/features/connect/chats/domain/translation_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('German uses the backend-supported NLLB language code', () {
    final german = chatTranslationLanguages.singleWhere(
      (language) => language.label == 'German',
    );

    expect(german.code, 'deu_Latn');
    expect(german.flag, '🇩🇪');
    expect(chatTranslationLanguageByCode('deu_Latn'), same(german));
  });
}
