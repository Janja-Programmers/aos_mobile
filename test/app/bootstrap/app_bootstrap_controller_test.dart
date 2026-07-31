import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'process restoration loads the persisted onboarding state once',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboarding_completed': true,
        'pref_country_code': 'KE',
        'pref_language_code': 'en',
        'pref_currency_code': 'KES',
      });
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final AppBootstrapController controller = AppBootstrapController(
        OnboardingStorage(preferences),
      );
      addTearDown(controller.dispose);
      final List<AppBootstrapState> states = <AppBootstrapState>[];
      final removeListener = controller.addListener(
        states.add,
        fireImmediately: false,
      );
      addTearDown(removeListener);

      await controller.initialize();
      await controller.initialize();

      expect(controller.state.isReady, isTrue);
      expect(controller.state.onboardingCompleted, isTrue);
      expect(states, hasLength(1));
    },
  );

  test(
    'missing persisted onboarding state resolves to ready and incomplete',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final AppBootstrapController controller = AppBootstrapController(
        OnboardingStorage(preferences),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(
        controller.state,
        isA<AppBootstrapState>()
            .having(
              (AppBootstrapState state) => state.isReady,
              'isReady',
              isTrue,
            )
            .having(
              (AppBootstrapState state) => state.onboardingCompleted,
              'onboardingCompleted',
              isFalse,
            ),
      );
    },
  );
}
