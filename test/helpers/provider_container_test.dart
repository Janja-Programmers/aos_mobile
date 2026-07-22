import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'provider_container.dart';

void main() {
  test('createTestContainer applies provider overrides', () {
    final Provider<int> valueProvider = Provider<int>((Ref ref) => 1);
    final ProviderContainer container = createTestContainer(
      overrides: <Override>[valueProvider.overrideWithValue(7)],
    );

    expect(container.read(valueProvider), 7);
  });
}
