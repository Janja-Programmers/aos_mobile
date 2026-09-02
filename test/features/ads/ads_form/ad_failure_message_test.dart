import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/ads/shared/utils/ad_failure_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stable backend state error becomes an actionable listing message', () {
    const failure = Failure(
      'The ad is not in a valid state for this action.',
      error: 'INVALID_AD_STATE',
    );

    expect(adFailureMessage(failure, adStatus: 'Expired'), contains('Renew'));
  });

  test('backend price-required ID is explained to the user', () {
    const failure = Failure('Invalid ad input.', error: 'AD_PRICE_REQUIRED');
    expect(adFailureMessage(failure), contains('valid price'));
  });
}
