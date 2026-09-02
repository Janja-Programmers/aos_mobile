import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing/service_pricing_policy.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Fixed is the default when backend category permits it', () {
    const schema = PricingSchema(
      requirement: PricingRequirement.optional,
      allowedTypes: <String>['Fixed', 'Negotiable'],
    );

    expect(resolvedPriceType(null, schema), 'Fixed');
  });

  test('existing backend price type is preserved', () {
    const schema = PricingSchema(
      requirement: PricingRequirement.required,
      allowedTypes: <String>['Fixed', 'Negotiable'],
    );

    expect(resolvedPriceType('Negotiable', schema), 'Negotiable');
  });

  test('Fixed is not fabricated when backend disallows it', () {
    const schema = PricingSchema(
      requirement: PricingRequirement.optional,
      allowedTypes: <String>['Negotiable'],
    );

    expect(resolvedPriceType(null, schema), isNull);
  });

  test('hidden pricing never receives a frontend default', () {
    const schema = PricingSchema(requirement: PricingRequirement.hidden);
    expect(resolvedPriceType(null, schema), isNull);
  });

  test('amount-based service pricing always requires a unit', () {
    const schema = PricingSchema(
      requirement: PricingRequirement.required,
      allowedTypes: <String>['Fixed', 'Negotiable'],
    );
    const draft = AdDraft(source: DraftSource.create, priceType: 'Fixed');

    expect(ServicePricingPolicy().requireUnit(draft, schema), isTrue);
  });
}
