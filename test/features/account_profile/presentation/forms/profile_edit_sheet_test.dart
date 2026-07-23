import 'dart:async';

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
import '../../../../helpers/pump_app.dart';
import '../../fakes/mutable_auth_controller.dart';
import '../../fakes/scripted_accounts_api.dart';
import '../../helpers/account_profile_api_harness.dart';
import '../../../../fakes/recording_http_client_adapter.dart';

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
              fullName: 'Auth Owner',
              bio: 'Auth bio',
            ),
            sid: 'test-session-id',
          ),
        );
      }),
    ];
  }

  testWidgets('prefills explicit profile values including bio', (
    WidgetTester tester,
  ) async {
    final ScriptedAccountsApi api = ScriptedAccountsApi(apiHarness.client);

    await tester.pumpTestApp(
      const ProfileEditSheet(
        initialFullName: 'Profile Owner',
        initialBio: 'Prefilled profile bio.',
      ),
      overrides: overridesFor(api),
    );

    final TextField name = tester.widget<TextField>(
      find.byKey(const Key('profile_edit_name_field')),
    );
    final TextField bio = tester.widget<TextField>(
      find.byKey(const Key('profile_edit_bio_field')),
    );

    expect(name.controller?.text, 'Profile Owner');
    expect(bio.controller?.text, 'Prefilled profile bio.');
    expect(name.maxLength, 80);
    expect(bio.maxLength, 300);
  });

  testWidgets('duplicate save taps share one in-flight update', (
    WidgetTester tester,
  ) async {
    final Completer<Either<Failure, Map<String, dynamic>>> response =
        Completer<Either<Failure, Map<String, dynamic>>>();
    final ScriptedAccountsApi api = ScriptedAccountsApi(
      apiHarness.client,
      updateProfileHandler: (_) => response.future,
    );

    await tester.pumpTestApp(
      const ProfileEditSheet(
        initialFullName: 'Profile Owner',
        initialBio: 'Profile bio.',
      ),
      overrides: overridesFor(api),
    );

    final Finder save = find.byKey(const Key('profile_edit_save_button'));
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();

    expect(api.updateProfileCalls, 1);
    response.complete(Either.left(const Failure('Temporary failure.')));
    await tester.pumpAndSettle();
  });
}
