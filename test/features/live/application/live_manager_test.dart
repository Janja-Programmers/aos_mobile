import 'dart:async';

import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/domain/live_bootstrap.dart';
import 'package:africaonlinestores/features/live/domain/live_list_page.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../helpers/live_fixtures.dart';

void main() {
  late _ScriptedLiveRepository repository;
  late _FakeLiveKitService liveKit;
  late _TestRealtimeService realtime;
  late LiveManager manager;

  setUp(() {
    repository = _ScriptedLiveRepository();
    liveKit = _FakeLiveKitService();
    realtime = _TestRealtimeService();
    manager = LiveManager(
      repository: repository,
      mediaService: LiveMediaService(liveKit),
      realtimeService: realtime,
    );
  });

  tearDown(() async {
    manager.dispose();
    await Future<void>.delayed(Duration.zero);
    await liveKit.dispose();
    await realtime.close();
  });

  test('duplicate joins for the same Live share one backend operation', () async {
    final response = Completer<LiveBootstrap>();
    repository.joinResponses[testLiveId] = response;

    final first = manager.joinLive(liveId: testLiveId);
    final second = manager.joinLive(liveId: testLiveId);
    await Future<void>.delayed(Duration.zero);

    expect(repository.joinRequests, <String>[testLiveId]);

    response.complete(testBootstrap());
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(repository.joinRequests, hasLength(1));
    expect(repository.trackJoinRequests, hasLength(1));
    expect(liveKit.connectCalls, 1);
    expect(manager.currentState.session?.liveId, testLiveId);
    expect(manager.currentState.hasActiveRoom, isTrue);
  });

  test('a later Live supersedes an in-flight stale join', () async {
    final firstResponse = Completer<LiveBootstrap>();
    final secondResponse = Completer<LiveBootstrap>();
    repository.joinResponses[testLiveId] = firstResponse;
    repository.joinResponses[secondTestLiveId] = secondResponse;

    final first = manager.joinLive(liveId: testLiveId, showLiveUi: false);
    await Future<void>.delayed(Duration.zero);
    final second = manager.joinLive(
      liveId: secondTestLiveId,
      showLiveUi: false,
    );

    firstResponse.complete(testBootstrap());
    expect(await first, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(repository.joinRequests, <String>[testLiveId, secondTestLiveId]);

    secondResponse.complete(testBootstrap(liveId: secondTestLiveId));
    expect(await second, isTrue);
    expect(manager.currentState.session?.liveId, secondTestLiveId);
    expect(manager.currentState.hasLiveUi, isFalse);
    expect(liveKit.connectCalls, 1);
  });

  test('reaction events are scoped and deduplicated by canonical ID', () async {
    repository.joinResponses[testLiveId] = Completer<LiveBootstrap>()
      ..complete(testBootstrap());
    await manager.joinLive(liveId: testLiveId);

    const reaction = LiveReaction(
      id: 'REACTION-001',
      liveId: testLiveId,
      type: LiveReactionType.fire,
      createdAt: null,
    );
    manager.onLiveReactionEvent(reaction);
    manager.onLiveReactionEvent(reaction);
    manager.onLiveReactionEvent(
      const LiveReaction(
        id: 'REACTION-002',
        liveId: secondTestLiveId,
        type: LiveReactionType.wow,
        createdAt: null,
      ),
    );

    expect(manager.currentState.live?.reactionCount, 5);
    expect(manager.currentState.reactionTrigger, 1);
    expect(manager.currentState.lastReactionType, LiveReactionType.fire);
  });

  test('repeated reaction taps issue one mutation while pending', () async {
    repository.joinResponses[testLiveId] = Completer<LiveBootstrap>()
      ..complete(testBootstrap());
    await manager.joinLive(liveId: testLiveId);
    final reactionResponse = Completer<LiveReaction>();
    repository.reactionResponse = reactionResponse;

    final first = manager.sendReaction(LiveReactionType.love);
    final second = manager.sendReaction(LiveReactionType.love);

    expect(await second, isFalse);
    expect(repository.reactionRequests, hasLength(1));
    reactionResponse.complete(
      const LiveReaction(
        id: 'REACTION-003',
        liveId: testLiveId,
        type: LiveReactionType.love,
        createdAt: null,
      ),
    );
    expect(await first, isTrue);
    expect(manager.currentState.live?.reactionCount, 5);
    expect(manager.currentState.isReacting, isFalse);
  });

  test('ended event tracks leave and releases the active session', () async {
    repository.joinResponses[testLiveId] = Completer<LiveBootstrap>()
      ..complete(testBootstrap());
    await manager.joinLive(liveId: testLiveId);

    await manager.onLiveEndedEvent(liveId: testLiveId);

    expect(repository.trackLeaveRequests, hasLength(1));
    expect(realtime.leftRooms, contains(testLiveId));
    expect(liveKit.disconnectCalls, greaterThanOrEqualTo(1));
    expect(manager.currentState.status, LiveStatus.ended);
    expect(manager.currentState.session, isNull);
    expect(manager.currentState.hasActiveRoom, isFalse);
  });
}

class _ScriptedLiveRepository implements LiveRepository {
  final Map<String, Completer<LiveBootstrap>> joinResponses =
      <String, Completer<LiveBootstrap>>{};
  final List<String> joinRequests = <String>[];
  final List<({String liveId, String sessionId})> trackJoinRequests =
      <({String liveId, String sessionId})>[];
  final List<({String liveId, String sessionId})> trackLeaveRequests =
      <({String liveId, String sessionId})>[];
  final List<({String liveId, LiveReactionType type, String? sessionId})>
  reactionRequests =
      <({String liveId, LiveReactionType type, String? sessionId})>[];
  Completer<LiveReaction>? reactionResponse;

  @override
  Future<LiveBootstrap> joinLive({
    required String liveId,
    String? sessionId,
  }) {
    joinRequests.add(liveId);
    final response = joinResponses[liveId];
    if (response == null) {
      throw StateError('Missing join response for $liveId.');
    }
    return response.future;
  }

  @override
  Future<LiveStream?> trackJoin({
    required String liveId,
    required String sessionId,
  }) async {
    trackJoinRequests.add((liveId: liveId, sessionId: sessionId));
    return testLive(liveId: liveId);
  }

  @override
  Future<LiveStream?> trackLeave({
    required String liveId,
    required String sessionId,
  }) async {
    trackLeaveRequests.add((liveId: liveId, sessionId: sessionId));
    return null;
  }

  @override
  Future<LiveReaction> sendReaction({
    required String liveId,
    required LiveReactionType reactionType,
    String? sessionId,
  }) {
    reactionRequests.add((
      liveId: liveId,
      type: reactionType,
      sessionId: sessionId,
    ));
    final response = reactionResponse;
    if (response == null) throw StateError('Missing reaction response.');
    return response.future;
  }

  @override
  Future<LiveStream> getLive({
    required String liveId,
    String? sessionId,
  }) async {
    return testLive(liveId: liveId);
  }

  @override
  Future<LiveListPage> listLives({int limit = 20, String? cursor}) async {
    return const LiveListPage(
      items: <LiveStream>[],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<void> endLive({required String liveId}) async {}

  @override
  Future<void> shareLiveToChat({
    required String liveId,
    required String conversationId,
    String? message,
    String? idempotencyKey,
  }) async {}

  @override
  Future<LiveBootstrap> startLive({
    required String title,
    String? coverImage,
    String? coverMediaId,
  }) {
    throw UnimplementedError('Host start is outside this test fake.');
  }
}

class _FakeLiveKitService extends LiveKitService {
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  Future<lk.Room> connect({
    required String wsUrl,
    required String token,
  }) async {
    connectCalls++;
    return lk.Room();
  }

  @override
  Future<void> disconnect({bool silent = false}) async {
    disconnectCalls++;
  }

  @override
  Future<void> switchSpeaker(bool enabled) async {}
}

class _TestRealtimeService extends RealtimeService {
  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();
  final StreamController<void> _connections =
      StreamController<void>.broadcast();
  final List<String> joinedRooms = <String>[];
  final List<String> leftRooms = <String>[];

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  @override
  Stream<void> get connections => _connections.stream;

  @override
  Future<void> joinSocketRoom(String liveId) async {
    joinedRooms.add(liveId);
  }

  @override
  Future<void> leaveSocketRoom(String liveId) async {
    leftRooms.add(liveId);
  }

  Future<void> close() async {
    await _events.close();
    await _connections.close();
    super.dispose();
  }
}
