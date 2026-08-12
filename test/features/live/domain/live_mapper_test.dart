import 'package:africaonlinestores/features/live/data/live_mapper.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:africaonlinestores/features/live/domain/live_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/live_fixtures.dart';

void main() {
  group('Live bootstrap mapping', () {
    test('retains canonical metadata, aggregates, and capabilities', () {
      final bootstrap = mapLiveBootstrap(bootstrapData());

      expect(bootstrap.live.id, testLiveId);
      expect(bootstrap.live.status, AOSLiveStatus.live);
      expect(bootstrap.live.host.userId, 'ACC-2026-00001');
      expect(bootstrap.live.host.displayName, 'Test Host');
      expect(bootstrap.live.host.isVerified, isTrue);
      expect(bootstrap.live.viewerCount, 7);
      expect(bootstrap.live.reactionCount, 4);
      expect(bootstrap.live.viewerState.canJoin, isTrue);
      expect(bootstrap.live.viewerState.canWatch, isTrue);
      expect(bootstrap.live.viewerState.canComment, isTrue);
      expect(bootstrap.live.viewerState.canReact, isTrue);
      expect(bootstrap.session.liveId, testLiveId);
      expect(bootstrap.session.role, AOSLiveRole.viewer);
      expect(bootstrap.session.sessionId, testViewerSessionId);
    });

    test('rejects mismatched Live and session identifiers', () {
      final data = bootstrapData();
      final session = data['session']! as Map<String, dynamic>;
      session['live_id'] = secondTestLiveId;

      expect(
        () => mapLiveBootstrap(data),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects incomplete private media credentials', () {
      final data = bootstrapData();
      final session = data['session']! as Map<String, dynamic>;
      session['token'] = '';

      expect(
        () => mapLiveBootstrap(data),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Live scalar mapping', () {
    test('normalizes backend scalar compatibility values', () {
      final json = liveJson()
        ..['viewer_count'] = '12'
        ..['reaction_count'] = 8.9
        ..['is_active'] = 'yes';

      final live = mapLiveStream(json);

      expect(live.viewerCount, 12);
      expect(live.reactionCount, 8);
      expect(live.isActive, isTrue);
    });

    test('unknown role fails closed to viewer', () {
      expect(parseLiveRole('host'), AOSLiveRole.host);
      expect(parseLiveRole('co_host'), AOSLiveRole.cohost);
      expect(parseLiveRole('unexpected'), AOSLiveRole.viewer);
      expect(parseLiveRole(null), AOSLiveRole.viewer);
    });
  });
}
