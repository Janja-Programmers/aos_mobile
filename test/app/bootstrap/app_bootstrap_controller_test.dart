import 'dart:async';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'process restoration loads persisted onboarding and starts media recovery',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboarding_completed': true,
        'pref_country_code': 'KE',
        'pref_language_code': 'en',
        'pref_currency_code': 'KES',
      });
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final media = _FakeMediaLifecycle();
      final AppBootstrapController controller = AppBootstrapController(
        OnboardingStorage(preferences),
        media,
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
      await media.initialized;

      expect(controller.state.isReady, isTrue);
      expect(controller.state.onboardingCompleted, isTrue);
      expect(states, hasLength(1));
      expect(media.initializeCalls, 1);
    },
  );

  test(
    'missing persisted onboarding state resolves to ready and incomplete',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final media = _FakeMediaLifecycle();
      final AppBootstrapController controller = AppBootstrapController(
        OnboardingStorage(preferences),
        media,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await media.initialized;

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
      expect(media.initializeCalls, 1);
    },
  );
}

final class _FakeMediaLifecycle implements MediaLifecycleInitializable {
  final Completer<void> _initialized = Completer<void>();
  int initializeCalls = 0;

  Future<void> get initialized => _initialized.future;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
    if (!_initialized.isCompleted) _initialized.complete();
  }
}
