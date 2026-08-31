import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses backend Activity page and canonical target fields', () {
    final ActivityPage page = ActivityPage.fromJson(<String, dynamic>{
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'ACT-1',
          'activity_group': 'Ads',
          'activity_type': 'ad_view',
          'count': 2,
          'occurred_at': '2026-08-31T09:00:00Z',
          'last_occurrence_at': '2026-08-31T10:00:00Z',
          'target': <String, dynamic>{
            'doctype': 'AOS Ad',
            'name': 'AD-1',
            'title': 'Listing',
            'route_type': 'ad',
            'route_id': 'AD-1',
          },
        },
      ],
      'total': 3,
      'start': 0,
      'limit': 20,
      'has_more': true,
    });

    expect(page.total, 3);
    expect(page.start, 0);
    expect(page.limit, 20);
    expect(page.hasMore, isTrue);
    expect(page.items.single.id, 'ACT-1');
    expect(page.items.single.group, 'Ads');
    expect(page.items.single.type, 'ad_view');
    expect(page.items.single.count, 2);
    expect(page.items.single.target.routeType, 'ad');
    expect(page.items.single.target.routeId, 'AD-1');
  });

  test('drops malformed Activity rows with no canonical ID', () {
    final ActivityPage page = ActivityPage.fromJson(<String, dynamic>{
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'activity_group': 'Ads',
          'activity_type': 'ad_view',
          'target': <String, dynamic>{'route_type': 'ad'},
        },
      ],
      'total': 1,
      'start': 0,
      'limit': 20,
      'has_more': false,
    });

    expect(page.items, isEmpty);
  });
}
