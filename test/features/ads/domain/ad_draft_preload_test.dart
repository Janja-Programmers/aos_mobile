import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdDraft preload parsing', () {
    test('edit payload uses canonical offer dates and typed detail values', () {
      final draft = AdDraft.fromAd(<String, dynamic>{
        'id': 'AD-0001',
        'title': 'Camera',
        'status': 'Active',
        'country': 'KE',
        'location': 'LOC-1',
        'category': 'CAT-1',
        'description': 'Mirrorless camera',
        'price_type': 'Fixed',
        'price': 50000,
        'offer_price': 45000,
        'offer_start_date': '2026-09-03',
        'offer_end_date': '2026-09-10',
        'images': <Map<String, dynamic>>[
          <String, dynamic>{
            'media_id': 'MEDIA-1',
            'url': 'https://example.test/camera.jpg',
            'is_primary': 1,
            'sort_order': 0,
          },
        ],
        'details': <Map<String, dynamic>>[
          <String, dynamic>{
            'attribute': 'release_date',
            'value_text': null,
            'value_number': null,
            'value_date': '2025-01-15',
            'value_json': null,
            'value_bool': 0,
          },
          <String, dynamic>{
            'attribute': 'features',
            'value_text': null,
            'value_number': null,
            'value_date': null,
            'value_json': <String>['wifi', 'stabilized'],
            'value_bool': 0,
          },
          <String, dynamic>{
            'attribute': 'weather_sealed',
            'value_text': null,
            'value_number': null,
            'value_date': null,
            'value_json': null,
            'value_bool': 0,
          },
        ],
      });

      expect(draft.adId, 'AD-0001');
      expect(draft.status, 'Active');
      expect(draft.offerStart, DateTime(2026, 9, 3));
      expect(draft.offerEnd, DateTime(2026, 9, 10));
      expect(draft.scheduleOfferDates, isTrue);
      expect(draft.attributes['release_date'], '2025-01-15');
      expect(draft.attributes['features'], <String>['wifi', 'stabilized']);
      expect(draft.attributes['weather_sealed'], 0);
      expect(draft.images.single.sortOrder, 0);
    });

    test('draft payload reads data.item shape and item id', () {
      final draft = AdDraft.fromDraft(<String, dynamic>{
        'id': 'DRAFT-0001',
        'status': 'Draft',
        'title': 'Draft camera',
        'category': 'CAT-1',
        'location': 'LOC-1',
        'country': 'KE',
        'description': 'Saved draft',
        'offer_price': 100,
        'offer_start_date': '2026-09-04',
        'offer_end_date': '2026-09-11',
        'images': <Map<String, dynamic>>[
          <String, dynamic>{
            'media_id': 'MEDIA-2',
            'url': 'https://example.test/draft.jpg',
            'is_primary': 1,
            'sort_order': 2,
          },
        ],
        'details': <Map<String, dynamic>>[],
      });

      expect(draft.draftId, 'DRAFT-0001');
      expect(draft.status, 'Draft');
      expect(draft.title, 'Draft camera');
      expect(draft.offerStart, DateTime(2026, 9, 4));
      expect(draft.offerEnd, DateTime(2026, 9, 11));
      expect(draft.scheduleOfferDates, isTrue);
      expect(draft.images.single.sortOrder, 2);
    });

    test('zero persisted offer sentinel preloads as no offer', () {
      final draft = AdDraft.fromAd(<String, dynamic>{
        'id': 'AD-NO-OFFER',
        'offer_price': 0,
        'offer_start_date': '2026-09-03',
        'offer_end_date': '2026-09-10',
        'images': <Map<String, dynamic>>[],
        'details': <Map<String, dynamic>>[],
      });

      expect(draft.offerPrice, isNull);
      expect(draft.offerStart, isNull);
      expect(draft.offerEnd, isNull);
      expect(draft.scheduleOfferDates, isFalse);
    });

    test('zero draft offer sentinel preloads as no offer', () {
      final draft = AdDraft.fromDraft(<String, dynamic>{
        'id': 'DRAFT-NO-OFFER',
        'offer_price': 0,
        'schedule_offer_dates': true,
        'offer_start_date': '2026-09-03',
        'offer_end_date': '2026-09-10',
        'images': <Map<String, dynamic>>[],
        'details': <Map<String, dynamic>>[],
      });

      expect(draft.offerPrice, isNull);
      expect(draft.offerStart, isNull);
      expect(draft.offerEnd, isNull);
      expect(draft.scheduleOfferDates, isFalse);
    });

    test('legacy offer date aliases remain readable for cached payloads', () {
      final draft = AdDraft.fromAd(<String, dynamic>{
        'id': 'AD-LEGACY',
        'offer_price': 100,
        'offer_start': '2026-08-01',
        'offer_end': '2026-08-02',
        'images': <Map<String, dynamic>>[],
        'details': <Map<String, dynamic>>[],
      });

      expect(draft.offerStart, DateTime(2026, 8));
      expect(draft.offerEnd, DateTime(2026, 8, 2));
      expect(draft.scheduleOfferDates, isTrue);
    });
  });
}
