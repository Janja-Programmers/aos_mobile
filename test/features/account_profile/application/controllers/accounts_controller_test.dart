import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../fakes/scripted_accounts_api.dart';
import '../../helpers/account_profile_api_harness.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  late AccountProfileApiHarness apiHarness;

  setUp(() async {
    apiHarness = await buildAccountProfileApiHarness(
      RecordingHttpClientAdapter((_) => jsonResponse(<String, dynamic>{})),
    );
  });

  tearDown(() => apiHarness.container.dispose());

  test('successful load transitions from loading to populated state', () async {
    final Map<String, dynamic> payload = await loadAccountProfileMessageFixture(
      'own_profile.json',
    );
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      getProfileHandler: (_) async => Either.right(payload),
    );
    final AccountsController controller = AccountsController(api: api);

    final Future<dynamic> operation = controller.loadProfile();

    expect(controller.state.loading, isTrue);
    final result = await operation;
    // ignore: avoid_dynamic_calls
    expect(result.isRight, isTrue);
    expect(controller.state.loading, isFalse);
    expect(controller.state.profile['user'], 'owner@example.invalid');
    expect(controller.state.errorMessage, isNull);
  });

  test('failure ends loading and remains retryable', () async {
    int calls = 0;
    final Map<String, dynamic> success = await loadAccountProfileMessageFixture(
      'own_profile.json',
    );
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      getProfileHandler: (_) async {
        calls += 1;
        if (calls == 1) {
          return Either.left(const Failure('Temporary profile failure.'));
        }
        return Either.right(success);
      },
    );
    final AccountsController controller = AccountsController(api: api);

    final first = await controller.loadProfile();
    final second = await controller.loadProfile();

    expect(first.isLeft, isTrue);
    expect(controller.state.loading, isFalse);
    expect(second.isRight, isTrue);
    expect(controller.state.profile['full_name'], 'Test Owner');
  });

  test('concurrent profile loads issue one request', () async {
    final Completer<Either<Failure, Map<String, dynamic>>> response =
        Completer<Either<Failure, Map<String, dynamic>>>();
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      getProfileHandler: (_) => response.future,
    );
    final AccountsController controller = AccountsController(api: api);

    final first = controller.loadProfile();
    final second = controller.loadProfile();

    expect(api.getProfileCalls, 1);
    response.complete(
      Either.right(<String, dynamic>{
        'ok': true,
        'data': <String, dynamic>{'user': 'owner@example.invalid'},
      }),
    );
    await Future.wait<dynamic>(<Future<dynamic>>[first, second]);
    expect(api.getProfileCalls, 1);
  });

  test(
    'successful edit preserves submitted bio and refreshes profile',
    () async {
      final Map<String, dynamic> updatePayload =
          await loadAccountProfileMessageFixture('profile_update_success.json');
      final Map<String, dynamic> profilePayload =
          await loadAccountProfileMessageFixture('own_profile.json');
      final ScriptedAccountsApi api = ScriptedAccountsApi(
        apiHarness.client,
        updateProfileHandler: (_) async => Either.right(updatePayload),
        getProfileHandler: (_) async => Either.right(profilePayload),
      );
      final AccountsController controller = AccountsController(api: api);

      final result = await controller.updateProfile(
        fullName: 'Updated Owner',
        bio: 'Updated profile bio.',
      );

      expect(result.isRight, isTrue);
      expect(api.updateProfileCalls, 1);
      expect(api.updateCalls.single.fullName, 'Updated Owner');
      expect(api.updateCalls.single.bio, 'Updated profile bio.');
      expect(api.getProfileCalls, 1);
      expect(controller.state.profile['user'], 'owner@example.invalid');
    },
  );

  test('failed edit does not clear the last loaded profile', () async {
    final Map<String, dynamic> profilePayload =
        await loadAccountProfileMessageFixture('own_profile.json');
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      getProfileHandler: (_) async => Either.right(profilePayload),
      updateProfileHandler: (_) async => Either.left(
        const Failure('Bio is too long.', error: 'VALIDATION_ERROR'),
      ),
    );
    final AccountsController controller = AccountsController(api: api);
    await controller.loadProfile();

    final result = await controller.updateProfile(bio: 'Invalid');

    expect(result.isLeft, isTrue);
    expect(controller.state.profile['user'], 'owner@example.invalid');
    expect(controller.state.errorMessage, 'Bio is too long.');
  });
}
