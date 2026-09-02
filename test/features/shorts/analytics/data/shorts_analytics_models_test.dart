import 'package:africaonlinestores/features/shorts/analytics/data/shorts_analytics_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'per-short analytics parses period and current totals independently',
    () {
      final result = ShortAnalyticsResult.fromJson(<String, dynamic>{
        'short': <String, dynamic>{'id': 'SHORT-1', 'caption': 'Example'},
        'date_from': '2026-08-04',
        'date_to': '2026-09-02',
        'totals': <String, dynamic>{
          'impressions': 20,
          'views': 10,
          'watch_time_ms': 50000,
          'avg_watch_time_ms': 5000,
          'likes': 3,
          'comments': 2,
          'shares': 1,
          'saves': 1,
          'downloads': 1,
          'reposts': 1,
          'engagements': 9,
          'completion_rate': .42,
          'engagement_rate': .45,
        },
        'current_totals': <String, dynamic>{
          'impressions': 24,
          'views': 12,
          'likes': 4,
          'comments': 3,
          'shares': 2,
          'saves': 2,
          'downloads': 1,
          'reposts': 1,
          'engagements': 13,
        },
        'daily': <Map<String, dynamic>>[
          <String, dynamic>{'date': '2026-09-02', 'views': 2},
        ],
      });

      expect(result.short['id'], 'SHORT-1');
      expect(result.totals.views, 10);
      expect(result.totals.avgWatchTimeMs, 5000);
      expect(result.totals.completionRate, .42);
      expect(result.currentTotals.views, 12);
      expect(result.currentTotals.comments, 3);
      expect(result.daily, hasLength(1));
    },
  );

  test('missing analytics metrics are safely zeroed', () {
    final result = ShortAnalyticsResult.fromJson(<String, dynamic>{
      'short': <String, dynamic>{'id': 'SHORT-2'},
      'totals': <String, dynamic>{},
      'current_totals': <String, dynamic>{'views': '2'},
    });

    expect(result.totals.impressions, 0);
    expect(result.currentTotals.views, 2);
    expect(result.currentTotals.likes, 0);
  });
}
