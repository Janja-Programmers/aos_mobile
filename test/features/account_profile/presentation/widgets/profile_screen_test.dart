import 'dart:async';

import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';
import 'package:africaonlinestores/features/social/presentation/screens/profile_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_session_storage.dart';
import '../../../../fakes/recording_http_client_adapter.dart';
import '../../../../helpers/pump_app.dart';
import '../../fakes/mutable_auth_controller.dart';
import '../../fakes/scripted_accounts_api.dart';
import '../../fakes/scripted_social_repository.dart';
import '../../helpers/account_profile_api_harness.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  Future<void> pumpUntilVisible(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 80,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var index = 0; index < maxPumps; index++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) return;
    }

    fail(
      'Expected $finder to appear within '
      '${step.inMilliseconds * maxPumps} ms.',
    );
  }

  Future<({AccountProfileApiHarness harness, ScriptedAccountsApi api})>
  buildHarnessFor(String fixtureName) async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter((
      RequestOptions options,
    ) async {
      if (options.path == ApiEndpoints.getSellerEndpoint) {
        return jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': false,
            'error': 'SELLER_NOT_FOUND',
            'message': 'Seller not found.',
          },
        }, statusCode: 404);
      }
      return jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message': 'Items fetched.',
          'data': <String, dynamic>{'items': <dynamic>[]},
        },
      });
    });
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    final Map<String, dynamic> payload = await loadAccountProfileMessageFixture(
      fixtureName,
    );
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      payload['data'] as Map<String, dynamic>,
    );
    data
      ..['user_image'] = null
      ..['is_live'] = false
      ..['live_id'] = null;
    final Map<String, dynamic> safePayload = <String, dynamic>{
      ...payload,
      'data': data,
    };
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      harness.client,
      getProfileHandler: (_) async => Either.right(safePayload),
    );
    return (harness: harness, api: api);
  }

  List<Override> overridesFor(
    AccountProfileApiHarness harness,
    ScriptedAccountsApi api, {
    String currentUser = 'owner@example.invalid',
    SocialRepository? socialRepository,
  }) {
    return <Override>[
      apiClientProvider.overrideWithValue(harness.client),
      accountsApiProvider.overrideWithValue(api),
      if (socialRepository != null)
        socialRepositoryProvider.overrideWithValue(socialRepository),
      authControllerProvider.overrideWith((Ref ref) {
        return MutableAuthController(
          ref: ref,
          api: AuthApi(harness.client),
          apiClient: harness.client,
          storage: FakeSessionStorage(sid: 'test-session-id'),
          initialState: AuthAuthenticated(
            user: AuthUser(
              email: currentUser,
              fullName: 'Test Owner',
              bio: 'Owner bio.',
            ),
            sid: 'test-session-id',
          ),
        );
      }),
    ];
  }

  testWidgets(
    'public friend profile hides owner controls and preserves Friends',
    (WidgetTester tester) async {
      final bundle = await buildHarnessFor('public_profile_friend.json');
      addTearDown(bundle.harness.container.dispose);

      await tester.pumpTestApp(
        const ProfileScreen(user: 'friend@example.invalid'),
        overrides: overridesFor(bundle.harness, bundle.api),
      );
      await pumpUntilVisible(tester, find.text('Friend User'), maxPumps: 10);
      await tester.pump();

      expect(find.text('Friend User'), findsWidgets);
      expect(find.byKey(const Key('profile_edit_action')), findsNothing);
      expect(find.byKey(const Key('profile_message_action')), findsOneWidget);
      expect(find.byKey(const Key('profile_follow_action')), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Private'), findsNothing);
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Liked'), findsNothing);
      expect(find.text('friend@example.invalid'), findsNothing);

      final Iterable<String> initialPaths = bundle.harness.adapter.requests.map(
        (RequestOptions request) => request.path,
      );
      expect(initialPaths, contains(ApiEndpoints.userShorts));
      expect(initialPaths, isNot(contains(ApiEndpoints.repostedShorts)));
      expect(initialPaths, isNot(contains(ApiEndpoints.savedShorts)));
      expect(initialPaths, isNot(contains(ApiEndpoints.likedShorts)));
    },
  );

  testWidgets('blocked public profile is unavailable and non-interactive', (
    WidgetTester tester,
  ) async {
    final bundle = await buildHarnessFor('public_profile_blocked_by_me.json');
    addTearDown(bundle.harness.container.dispose);
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      bundle.harness.client,
      getProfileHandler: (_) async => Either.left(
        const Failure(
          'Profile is unavailable.',
          type: FailureType.forbidden,
          error: 'PROFILE_UNAVAILABLE',
        ),
      ),
    );

    await tester.pumpTestApp(
      const ProfileScreen(user: 'blocked@example.invalid'),
      overrides: overridesFor(bundle.harness, api),
    );
    await pumpUntilVisible(tester, find.text('Profile unavailable'));

    expect(find.byKey(const Key('profile_message_action')), findsNothing);
    expect(find.byKey(const Key('profile_follow_action')), findsNothing);
    expect(find.text('Message'), findsNothing);
    expect(find.text('Unblock'), findsNothing);
    expect(find.text('blocked@example.invalid'), findsNothing);
  });

  testWidgets('deleted public profile remains redacted and non-interactive', (
    WidgetTester tester,
  ) async {
    final bundle = await buildHarnessFor('public_profile_deleted.json');
    addTearDown(bundle.harness.container.dispose);

    await tester.pumpTestApp(
      const ProfileScreen(user: 'deleted@example.invalid'),
      overrides: overridesFor(bundle.harness, bundle.api),
    );
    await pumpUntilVisible(tester, find.text('Deleted User'));

    expect(find.text('Deleted User'), findsWidgets);
    expect(find.byKey(const Key('profile_message_action')), findsNothing);
    expect(find.byKey(const Key('profile_follow_action')), findsNothing);
    expect(find.text('deleted@example.invalid'), findsNothing);
  });

  testWidgets('own profile exposes edit and private integration tabs', (
    WidgetTester tester,
  ) async {
    final bundle = await buildHarnessFor('own_profile.json');
    addTearDown(bundle.harness.container.dispose);

    await tester.pumpTestApp(
      const ProfileScreen(),
      overrides: overridesFor(bundle.harness, bundle.api),
    );
    await pumpUntilVisible(tester, find.text('Owner profile bio.'));

    expect(find.byKey(const Key('profile_edit_action')), findsOneWidget);
    expect(find.byKey(const Key('profile_message_action')), findsNothing);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
  });

  testWidgets('public counts come from profile payload without list requests', (
    WidgetTester tester,
  ) async {
    final bundle = await buildHarnessFor('public_profile_follow.json');
    addTearDown(bundle.harness.container.dispose);

    await tester.pumpTestApp(
      const ProfileScreen(user: 'public@example.invalid'),
      overrides: overridesFor(bundle.harness, bundle.api),
    );
    await pumpUntilVisible(tester, find.text('1.5K'));

    expect(find.text('999'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('1.5K'), findsOneWidget);
    final Iterable<String> paths = bundle.harness.adapter.requests.map((
      RequestOptions request,
    ) {
      return request.path;
    });
    expect(paths, isNot(contains(ApiEndpoints.getFollowsEndpoint)));
    expect(paths, isNot(contains(ApiEndpoints.getFollowingEndpoint)));
    expect(paths, isNot(contains(ApiEndpoints.getFriendsEndpoint)));
  });

  testWidgets('rapid follow taps produce one in-flight mutation', (
    WidgetTester tester,
  ) async {
    final bundle = await buildHarnessFor('public_profile_follow.json');
    addTearDown(bundle.harness.container.dispose);
    final Completer<void> requestStarted = Completer<void>();
    final Completer<Either<Failure, SocialRelationship>> response =
        Completer<Either<Failure, SocialRelationship>>();
    final ScriptedSocialRepository repository = ScriptedSocialRepository(
      toggleFollowHandler: (_) {
        if (!requestStarted.isCompleted) requestStarted.complete();
        return response.future;
      },
    );

    await tester.pumpTestApp(
      const ProfileScreen(user: 'public@example.invalid'),
      overrides: overridesFor(
        bundle.harness,
        bundle.api,
        socialRepository: repository,
      ),
    );
    final Finder follow = find.byKey(const Key('profile_follow_action'));
    await pumpUntilVisible(tester, follow);
    await tester.ensureVisible(follow);
    await tester.pump();

    await tester.tap(follow);
    await requestStarted.future;
    await tester.tap(follow);
    await tester.pump();

    expect(repository.toggleFollowCalls, 1);

    response.complete(Either.left(const Failure('Temporary follow failure.')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(repository.toggleFollowCalls, 1);
  });
}
