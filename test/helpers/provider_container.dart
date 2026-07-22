import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates an isolated Riverpod container and disposes it after the test.
ProviderContainer createTestContainer({
  List<Override> overrides = const <Override>[],
}) {
  final ProviderContainer container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}
