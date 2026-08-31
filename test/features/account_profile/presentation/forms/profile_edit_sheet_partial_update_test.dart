import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_session_storage.dart';
import '../../../../fakes/recording_http_client_adapter.dart';
import '../../../../helpers/pump_app.dart';
import '../../fakes/mutable_auth_controller.dart';
import '../../fakes/scripted_accounts_api.dart';
import '../../helpers/account_profile_api_harness.dart';

void main() {
  late AccountProfileApiHarness apiHarness;

  setUp(() async {
    apiHarness = await buildAccountProfileApiHarness(
      RecordingHttpClientAdapter((_) => jsonResponse(<String, dynamic>{})),
    );
  });

  tearDown(() => apiHarness.container.dispose());

  List<Override> overridesFor(ScriptedAccountsApi accountsApi) {
    return <Override>[
      accountsApiProvider.overrideWithValue(accountsApi),
      authControllerProvider.overrideWith((Ref ref) {
        return MutableAuthController(
          ref: ref,
          api: AuthApi(apiHarness.client),
          apiClient: apiHarness.client,
          storage: FakeSessionStorage(sid: 'test-session-id'),
          initialState: AuthAuthenticated(
            user: AuthUser(
              email: 'owner@example.invalid',
              fullName: 'Old auth name',
              bio: 'Stale auth bio',
            ),
            sid: 'test-session-id',
          ),
        );
      }),
    ];
  }

  Either<Failure, Map<String, dynamic>> successProfile({
    required String fullName,
    required String bio,
  }) {
    return Either.right(<String, dynamic>{
      'ok': true,
      'message': 'Profile updated.',
      'data': <String, dynamic>{
        'email': 'owner@example.invalid',
        'full_name': fullName,
        'display_name': fullName,
        'bio': bio,
        'avatar': '',
        'user_image': '',
      },
    });
  }

  testWidgets('explicit empty backend bio does not fall back to auth bio', (
    WidgetTester tester,
  ) async {
    final ScriptedAccountsApi api = ScriptedAccountsApi(apiHarness.client);

    await tester.pumpTestApp(
      const ProfileEditSheet(initialFullName: 'Owner', initialBio: ''),
      overrides: overridesFor(api),
    );

    final TextField bio = tester.widget<TextField>(
      find.byKey(const Key('profile_edit_bio_field')),
    );
    expect(bio.controller?.text, '');
  });

  testWidgets('editing only name omits unchanged bio from update', (
    WidgetTester tester,
  ) async {
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      updateProfileHandler: (_) async =>
          successProfile(fullName: 'New Owner', bio: 'Existing bio'),
    );

    await tester.pumpTestApp(
      const ProfileEditSheet(
        initialFullName: 'Owner',
        initialBio: 'Existing bio',
      ),
      overrides: overridesFor(api),
    );

    await tester.enterText(
      find.byKey(const Key('profile_edit_name_field')),
      'New Owner',
    );
    await tester.tap(find.byKey(const Key('profile_edit_save_button')));
    await tester.pumpAndSettle();

    expect(api.updateProfileCalls, 1);
    expect(api.updateCalls.single.fullName, 'New Owner');
    expect(api.updateCalls.single.bio, isNull);
  });

  testWidgets('editing only bio omits unchanged name from update', (
    WidgetTester tester,
  ) async {
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      updateProfileHandler: (_) async =>
          successProfile(fullName: 'Owner', bio: 'New bio'),
    );

    await tester.pumpTestApp(
      const ProfileEditSheet(
        initialFullName: 'Owner',
        initialBio: 'Existing bio',
      ),
      overrides: overridesFor(api),
    );

    await tester.enterText(
      find.byKey(const Key('profile_edit_bio_field')),
      'New bio',
    );
    await tester.tap(find.byKey(const Key('profile_edit_save_button')));
    await tester.pumpAndSettle();

    expect(api.updateProfileCalls, 1);
    expect(api.updateCalls.single.fullName, isNull);
    expect(api.updateCalls.single.bio, 'New bio');
  });

  testWidgets('unchanged normalized values do not call update endpoint', (
    WidgetTester tester,
  ) async {
    final ScriptedAccountsApi api = ScriptedAccountsApi(apiHarness.client);

    await tester.pumpTestApp(
      const ProfileEditSheet(
        initialFullName: 'Profile Owner',
        initialBio: 'Existing bio',
      ),
      overrides: overridesFor(api),
    );

    await tester.enterText(
      find.byKey(const Key('profile_edit_name_field')),
      '  Profile   Owner  ',
    );
    await tester.tap(find.byKey(const Key('profile_edit_save_button')));
    await tester.pumpAndSettle();

    expect(api.updateProfileCalls, 0);
  });
}
