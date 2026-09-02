import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('image search sends only backend-supported multipart fields', () {
    final source = File(
      'lib/core/media/data/media_upload_api.dart',
    ).readAsStringSync();

    final start = source.indexOf('searchAdByImage({');
    final end = source.indexOf('\n  }\n}', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final searchMethod = source.substring(start, end);

    expect(searchMethod, contains("'image':"));
    expect(searchMethod, contains("'limit': limit"));
    expect(searchMethod, isNot(contains("'is_private'")));
    expect(searchMethod, contains('ApiEndpoints.searchAdByImageEndpoint'));
  });
}
