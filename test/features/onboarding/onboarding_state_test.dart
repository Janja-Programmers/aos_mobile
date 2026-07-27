import 'package:africaonlinestores/features/onboarding/models/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding starts without fabricated preference values', () {
    final state = OnboardingState.initial();

    expect(state.languageId, isNull);
    expect(state.countryId, isNull);
    expect(state.currencyId, isNull);
    expect(state.hasValidSelection, isFalse);
  });
}
