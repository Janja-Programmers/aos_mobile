import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'independent guest changes preserve the other two preferences',
    () async {
      final shared = await SharedPreferences.getInstance();
      final controller = UserPreferenceController(OnboardingStorage(shared));
      final resolved = ResolvedLocaleContext.fromJson(<String, dynamic>{
        'country': <String, dynamic>{
          'id': 'Kenya',
          'name': 'Kenya',
          'code': 'KE',
        },
        'currency': <String, dynamic>{
          'id': 'KES',
          'code': 'KES',
          'name': 'Kenyan Shilling',
        },
        'language': <String, dynamic>{
          'id': 'en',
          'code': 'en',
          'name': 'English',
        },
        'sources': <String, dynamic>{
          'country': 'geoip',
          'currency': 'default',
          'language': 'default',
        },
      });
      await controller.initializeGuestFromResolution(resolved);

      await controller.updateLanguage(
        LanguageOption.fromJson(<String, dynamic>{
          'id': 'sw',
          'code': 'sw',
          'name': 'Kiswahili',
        }),
      );

      expect(controller.state.languageId, 'sw');
      expect(controller.state.countryId, 'Kenya');
      expect(controller.state.currencyId, 'KES');
    },
  );
}
