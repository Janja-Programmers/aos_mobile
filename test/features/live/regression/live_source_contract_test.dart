import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retired competing realtime sources stay deleted', () {
    const retiredPaths = <String>[
      'lib/features/live/application/services/live_signaling_handler.dart',
      'lib/features/live/application/services/live_realtime_listeners.dart',
      'lib/features/live/application/services/socket_live_listener.dart',
    ];

    for (final path in retiredPaths) {
      expect(File(path).existsSync(), isFalse, reason: '$path must stay retired');
    }
  });

  test('provider graph owns one Live realtime coordinator', () {
    final source = File(
      'lib/features/live/application/providers/live_providers.dart',
    ).readAsStringSync();

    expect(source, contains('liveRealtimeCoordinatorProvider'));
    expect(source, contains('LiveRealtimeCoordinator('));
    expect(source, contains('coordinator.start()'));
    expect(source, contains('coordinator.dispose()'));
    expect(source, isNot(contains('LiveSignalingHandler')));
    expect(source, isNot(contains('SocketLiveListener')));
    expect(source, isNot(contains('LiveRealtimeListener')));
  });

  test('comments use realtime recovery without periodic polling', () {
    final screen = File(
      'lib/features/live/presentation/screens/live_screen.dart',
    ).readAsStringSync();
    final coordinator = File(
      'lib/features/live/application/services/live_realtime_coordinator.dart',
    ).readAsStringSync();

    expect(screen, isNot(contains('Timer.periodic')));
    expect(coordinator, contains('_commentsController.fetchComments'));
    expect(coordinator, contains('_eventTail'));
    expect(coordinator, contains('_seenEventKeys'));
  });

  test('Feed Live playback joins silently and leaves tracked sessions', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/'
      'shorts_feed_tab.dart',
    ).readAsStringSync();

    expect(source, contains('showLiveUi: false'));
    expect(source, contains('leaveBackgroundLive'));
    expect(source, contains('_activeLiveId != live.id'));
  });

  test('prepared camera flip targets the opposite physical position', () {
    final source = File(
      'lib/features/live/application/services/live_media_service.dart',
    ).readAsStringSync();

    expect(source, contains('setCameraPosition(nextPosition)'));
    expect(source, contains('lk.CameraPosition.back'));
    expect(source, isNot(contains('currentOptions.deviceId')));
  });

  test('Live host follow is explicit, locked, and canonically refreshed', () {
    final source = File(
      'lib/features/live/presentation/screens/live_screen.dart',
    ).readAsStringSync();

    expect(source, contains('_isFollowInFlight'));
    expect(source, contains('.followUser(targetUser: targetUser)'));
    expect(source, contains('refreshActiveLive()'));
    expect(source, contains('_followedHostUser != followTarget'));
  });
}
