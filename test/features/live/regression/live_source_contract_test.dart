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
      expect(
        File(path).existsSync(),
        isFalse,
        reason: '$path must stay retired',
      );
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

  test('Feed Live is listing-only until a Live card is tapped', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/'
      'shorts_feed_tab.dart',
    ).readAsStringSync();

    expect(source, contains('MasonryGridView.count'));
    expect(source, contains('LiveNavigation.toLiveRoom'));
    expect(source, isNot(contains('showLiveUi: false')));
    expect(source, isNot(contains('leaveBackgroundLive')));
  });

  test('Live room exposes backend-count viewer sheet using LiveKit roster', () {
    final screen = File(
      'lib/features/live/presentation/screens/live_screen.dart',
    ).readAsStringSync();
    final media = File(
      'lib/core/media/livekit_service.dart',
    ).readAsStringSync();

    expect(screen, contains('showLiveViewersSheet'));
    expect(screen, contains('viewerCount: state.viewerCount'));
    expect(screen, contains('audienceParticipants'));
    expect(media, contains('LiveKitAudienceParticipant'));
    expect(media, contains('ParticipantMetadataUpdatedEvent'));
    expect(media, contains("role == 'host'"));
  });

  test('Live comments recover replies with cursor and recursive deletes', () {
    final api = File(
      'lib/features/live/comments/live_comments_api.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/features/live/comments/live_comments_controller.dart',
    ).readAsStringSync();

    expect(api, contains("'include_replies': includeReplies ? 1 : 0"));
    expect(api, contains("'cursor': cursor!.trim()"));
    expect(api, contains("'idempotency_key': idempotencyKey!.trim()"));
    expect(api, contains('deleted_message_ids'));
    expect(controller, contains('Future<void> loadMore()'));
    expect(controller, contains('_knownBranchIds'));
    expect(controller, contains('_rememberDeleted'));
  });

  test('owner end preserves canonical analytics snapshot', () {
    final api = File('lib/features/live/data/live_api.dart').readAsStringSync();
    final manager = File(
      'lib/features/live/application/managers/live_manager.dart',
    ).readAsStringSync();
    final screen = File(
      'lib/features/live/presentation/screens/live_screen.dart',
    ).readAsStringSync();
    final analytics = File(
      'lib/features/live/presentation/widgets/live_ended_analytics_dialog.dart',
    ).readAsStringSync();

    expect(api, contains('Future<Either<Failure, LiveStream>> endLive'));
    expect(manager, contains('Future<LiveStream?> endLive()'));
    expect(screen, contains('showLiveEndedAnalyticsDialog'));
    expect(analytics, contains('live.peakViewers'));
    expect(analytics, contains('live.uniqueViewers'));
    expect(analytics, contains('live.reactionCount'));
    expect(
      analytics,
      contains('barrierColor: Colors.black.withValues(alpha: .88)'),
    );
    expect(analytics, contains('backgroundColor: const Color(0xFF1D1D1D)'));
    expect(analytics, contains('side: const BorderSide(color: Colors.white24'));
  });

  test(
    'LiveScreen defers provider mutations and keeps dispose side-effect free',
    () {
      final screen = File(
        'lib/features/live/presentation/screens/live_screen.dart',
      ).readAsStringSync();
      final disposeStart = screen.indexOf('void dispose()');
      final disposeEnd = screen.indexOf('\n  }\n}', disposeStart);
      expect(disposeStart, greaterThanOrEqualTo(0));
      expect(disposeEnd, greaterThan(disposeStart));
      final disposeSource = screen.substring(disposeStart, disposeEnd);

      expect(screen, contains('void _scheduleInitialize()'));
      expect(screen, contains('WidgetsBinding.instance.addPostFrameCallback'));
      expect(
        screen,
        contains('_liveManager.openLive(liveId: requestedLiveId)'),
      );
      expect(disposeSource, isNot(contains('ref.read')));
      expect(disposeSource, isNot(contains('.clear()')));
      expect(disposeSource, isNot(contains('hideLiveUi')));
      expect(disposeSource, isNot(contains('leaveLive')));
    },
  );

  test('Live chat keeps contrast over video and follows the keyboard', () {
    final overlay = File(
      'lib/features/live/presentation/widgets/live_chat_overlay.dart',
    ).readAsStringSync();
    final input = File(
      'lib/features/live/presentation/widgets/live_input_bar.dart',
    ).readAsStringSync();

    expect(overlay, contains('colors.black.withValues(alpha: .52)'));
    expect(overlay, contains('context.p.copyWith(color: colors.white)'));
    expect(overlay, contains('fontSize: 11'));
    expect(input, contains('AnimatedPositionedDirectional'));
    expect(input, contains('bottom: keyboardInset'));
  });

  test('prepared camera uses sender-free fast switch before publication', () {
    final source = File(
      'lib/features/live/application/services/live_media_service.dart',
    ).readAsStringSync();

    expect(source, contains('if (!_videoTrackPublished)'));
    expect(source, contains('fastSwitch: true'));
    expect(source, contains('_cameraPosition = nextPosition'));
    expect(source, contains('setCameraPosition(nextPosition)'));
  });

  test(
    'Live exit navigation is screen-owned and notification route joins once',
    () {
      final listener = File(
        'lib/features/live/application/listeners/live_navigation_listeners.dart',
      ).readAsStringSync();
      final screen = File(
        'lib/features/live/presentation/screens/live_screen.dart',
      ).readAsStringSync();
      final notificationExecutor = File(
        'lib/features/notifications/application/services/'
        'go_router_protected_navigation_executor.dart',
      ).readAsStringSync();

      expect(listener, contains('if (previous == next || !next) return;'));
      expect(listener, isNot(contains('router.goNamed(AppRoutes.nHome)')));
      expect(screen, contains('showLiveEndedAnalyticsDialog'));
      expect(screen, contains('await _closeAsync();'));
      expect(
        notificationExecutor,
        contains('_openLiveRoute(destination.canonicalId!)'),
      );
      expect(notificationExecutor, isNot(contains('_joinLiveWithFallback')));
      expect(notificationExecutor, isNot(contains('.joinLive(')));
    },
  );

  test(
    'Go Live details use account profile defaults and backend title bound',
    () {
      final screen = File(
        'lib/features/live/presentation/screens/go_live_screen.dart',
      ).readAsStringSync();
      final details = File(
        'lib/features/live/presentation/widgets/go_live_details_sheet.dart',
      ).readAsStringSync();

      expect(screen, contains('accountsControllerProvider'));
      expect(screen, contains('AccountProfileSnapshot.fromJson'));
      expect(screen, contains('_titleWasEdited'));
      expect(screen, contains('_effectiveCoverImageUrl'));
      expect(details, contains('goLiveTitleMaxLength = 140'));
      expect(details, contains("Key('go_live_change_cover')"));
    },
  );

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
