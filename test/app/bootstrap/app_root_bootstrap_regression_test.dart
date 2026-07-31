import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('root bootstrap dispatches after the first widget frame', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('WidgetsBinding.instance.addPostFrameCallback'));
    expect(
      source,
      isNot(
        contains(
          'super.initState();\n\n    unawaited(ref.read(appBootstrapControllerProvider.notifier).initialize())',
        ),
      ),
    );
  });
}
