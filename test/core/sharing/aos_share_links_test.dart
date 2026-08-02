import 'package:africaonlinestores/core/sharing/aos_share_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AosShareLinks.live', () {
    test('builds the canonical app deep link', () {
      final link = AosShareLinks.live(' LIVE-2026-00042 ');

      expect(link.scheme, 'aos');
      expect(link.host, 'open');
      expect(link.path, '/live/room');
      expect(link.queryParameters, <String, String>{
        'live_id': 'LIVE-2026-00042',
      });
      expect(link.toString(), 'aos://open/live/room?live_id=LIVE-2026-00042');
    });

    test('rejects an empty live ID', () {
      expect(() => AosShareLinks.live('  '), throwsArgumentError);
    });
  });
}
