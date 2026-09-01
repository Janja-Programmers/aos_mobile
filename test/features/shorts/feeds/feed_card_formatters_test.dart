import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_card_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatFeedDuration', () {
    test('formats sub-hour durations as minutes and seconds', () {
      expect(formatFeedDuration(22), '00:22');
      expect(formatFeedDuration(65.9), '01:05');
    });

    test('formats long durations without fabricating a value', () {
      expect(formatFeedDuration(3661), '1:01:01');
      expect(formatFeedDuration(0), isEmpty);
      expect(formatFeedDuration(-1), isEmpty);
      expect(formatFeedDuration(double.nan), isEmpty);
    });
  });

  group('formatFeedCount', () {
    test('keeps small counts exact', () {
      expect(formatFeedCount(0), '0');
      expect(formatFeedCount(999), '999');
      expect(formatFeedCount(-5), '0');
    });

    test('compacts larger authoritative counts for cards', () {
      expect(formatFeedCount(1800), '1.8K');
      expect(formatFeedCount(10000), '10K');
      expect(formatFeedCount(2500000), '2.5M');
      expect(formatFeedCount(1200000000), '1.2B');
    });
  });
}
