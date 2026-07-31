import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_payload.dart';
import 'package:africaonlinestores/features/ads/domain/ad_attribute.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/domain/category.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const schema = AdCategorySchema(
    category: AdCategory(id: 'CAT-1', name: 'Cars', isService: false),
    attributes: <AdAttribute>[],
    pricing: PricingSchema(requirement: PricingRequirement.required),
  );

  test('create and draft payloads contain only backend-supported fields', () {
    final payload = AdFormPayloadBuilder.build(
      d: AdDraft(
        source: DraftSource.create,
        title: 'Test vehicle',
        countryId: 'KE',
        locationId: 'LOC-1',
        categoryId: 'CAT-1',
        description: 'A complete description for a valid advertisement.',
        images: <AdMediaImage>[
          AdMediaImage(
            url: 'https://files.invalid/image.jpg',
            fileId: 'MEDIA-1',
            isPrimary: true,
          ),
        ],
        priceType: 'Fixed',
        price: 1000,
        offerPrice: 900,
        scheduleOfferDates: true,
        offerStart: DateTime(2026, 8),
        offerEnd: DateTime(2026, 8, 31),
      ),
      schema: schema,
    );

    expect(payload.containsKey('country'), isFalse);
    expect(payload.containsKey('schedule_offer_dates'), isFalse);
    expect(payload['offer_start_date'], '2026-08-01');
    expect(payload['offer_end_date'], '2026-08-31');
    expect(
      <String>{
        'title',
        'location',
        'category',
        'description',
        'details',
        'images',
        'price_type',
        'price',
        'price_unit',
        'offer_price',
        'offer_start_date',
        'offer_end_date',
        'video_media',
        'video_media_id',
        'video',
      }.containsAll(payload.keys.toSet()),
      isTrue,
    );
  });

  test('unscheduled offer does not serialize offer dates or UI flags', () {
    final payload = AdFormPayloadBuilder.build(
      d: const AdDraft(
        source: DraftSource.draft,
        title: 'Draft vehicle',
        countryId: 'KE',
        locationId: 'LOC-1',
        categoryId: 'CAT-1',
        description: 'A draft description that is long enough for testing.',
        priceType: 'Fixed',
        price: 1000,
        offerPrice: 900,
        scheduleOfferDates: false,
      ),
      schema: schema,
    );

    expect(payload.containsKey('country'), isFalse);
    expect(payload.containsKey('schedule_offer_dates'), isFalse);
    expect(payload.containsKey('offer_start_date'), isFalse);
    expect(payload.containsKey('offer_end_date'), isFalse);
  });
}
