import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('humanizeCount', () {
    test('keeps small values exact', () {
      expect(humanizeCount(0), '0');
      expect(humanizeCount(1), '1');
      expect(humanizeCount(999), '999');
    });

    test('humanizes thousands consistently', () {
      expect(humanizeCount(1000), '1K');
      expect(humanizeCount(1200), '1.2K');
      expect(humanizeCount(999999), '1000K');
    });

    test('humanizes millions consistently', () {
      expect(humanizeCount(1000000), '1M');
      expect(humanizeCount(2500000), '2.5M');
    });
  });
}
