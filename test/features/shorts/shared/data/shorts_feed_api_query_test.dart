import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShortsFeedApi.buildFeedQueryParameters', () {
    test('sends an explicit blank content mode for All', () {
      final query = ShortsFeedApi.buildFeedQueryParameters(
        limit: 10,
        contentMode: '',
      );

      expect(query, <String, dynamic>{'limit': 10, 'content_mode': ''});
    });

    test('normalizes category, cursor, and search values', () {
      final query = ShortsFeedApi.buildFeedQueryParameters(
        limit: 20,
        cursor: ' cursor-token ',
        contentMode: ' vibes ',
        search: ' creator ',
      );

      expect(query, <String, dynamic>{
        'limit': 20,
        'cursor': 'cursor-token',
        'search': 'creator',
        'content_mode': 'vibes',
      });
    });
  });
}
