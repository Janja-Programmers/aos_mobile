import 'dart:io';

import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/account/domain/account_state.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/presentation/screens/go_live_screen.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/go_live_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('profile title and avatar seed editable Live details', (
    tester,
  ) async {
    final liveKit = LiveKitService();
    addTearDown(liveKit.dispose);
    final accountsController = _StaticAccountsController(
      const AccountState(
        profile: <String, dynamic>{
          'display_name': 'Kings Collection',
          'avatar': 'https://example.invalid/profile.jpg',
        },
      ),
    );

    await tester.pumpTestApp(
      const GoLiveScreen(),
      overrides: [
        accountsControllerProvider.overrideWith((_) => accountsController),
        liveMediaServiceProvider.overrideWithValue(
          _UnavailablePreviewMediaService(liveKit),
        ),
      ],
    );
    await tester.pumpAndSettle();

    ElevatedButton goLiveButton() =>
        tester.widget<ElevatedButton>(find.byKey(const Key('go_live_button')));

    expect(find.text('Kings Collection'), findsOneWidget);
    expect(goLiveButton().onPressed, isNotNull);

    final flipIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const Key('go_live_flip_camera')),
        matching: find.byIcon(Icons.cameraswitch_outlined),
      ),
    );
    final muteIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const Key('go_live_mute')),
        matching: find.byIcon(Icons.mic_none_outlined),
      ),
    );
    expect(flipIcon.color, AppColorTokens.light.btnText);
    expect(muteIcon.color, AppColorTokens.light.btnText);

    await tester.tap(find.byKey(const Key('go_live_edit_details')));
    await tester.pumpAndSettle();

    final titleField = tester.widget<TextField>(
      find.byKey(const Key('go_live_title_field')),
    );
    expect(titleField.controller?.text, 'Kings Collection');
    expect(titleField.maxLength, 140);
    expect(find.byKey(const Key('go_live_change_cover')), findsOneWidget);

    ElevatedButton saveButton() => tester.widget<ElevatedButton>(
      find.byKey(const Key('go_live_save_details')),
    );

    await tester.enterText(find.byKey(const Key('go_live_title_field')), '   ');
    await tester.pump();
    expect(saveButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('go_live_title_field')),
      'Night market deals',
    );
    await tester.pump();
    expect(saveButton().onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('go_live_save_details')));
    await tester.pumpAndSettle();

    expect(find.text('Night market deals'), findsOneWidget);
    expect(goLiveButton().onPressed, isNotNull);
  });

  testWidgets('missing profile cover keeps Go Live blocked with edit path', (
    tester,
  ) async {
    final liveKit = LiveKitService();
    addTearDown(liveKit.dispose);

    await tester.pumpTestApp(
      const GoLiveScreen(),
      overrides: [
        accountsControllerProvider.overrideWith(
          (_) => _StaticAccountsController(
            const AccountState(
              profile: <String, dynamic>{'display_name': 'Kings Collection'},
            ),
          ),
        ),
        liveMediaServiceProvider.overrideWithValue(
          _UnavailablePreviewMediaService(liveKit),
        ),
      ],
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('go_live_button')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Add a cover photo to continue.'), findsOneWidget);
    expect(find.byKey(const Key('go_live_edit_details')), findsOneWidget);

    await tester.tap(find.byKey(const Key('go_live_edit_details')));
    await tester.pumpAndSettle();

    final save = tester.widget<ElevatedButton>(
      find.byKey(const Key('go_live_save_details')),
    );
    expect(save.onPressed, isNull);
    expect(find.byKey(const Key('go_live_change_cover')), findsOneWidget);
  });

  testWidgets('asynchronous profile load applies untouched defaults', (
    tester,
  ) async {
    final liveKit = LiveKitService();
    addTearDown(liveKit.dispose);
    final accountsController = _StaticAccountsController(
      const AccountState(loading: true),
    );

    await tester.pumpTestApp(
      const GoLiveScreen(),
      overrides: [
        accountsControllerProvider.overrideWith((_) => accountsController),
        liveMediaServiceProvider.overrideWithValue(
          _UnavailablePreviewMediaService(liveKit),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('go_live_button')))
          .onPressed,
      isNull,
    );

    accountsController.replace(
      const AccountState(
        profile: <String, dynamic>{
          'full_name': 'Loaded Profile',
          'user_image': 'https://example.invalid/loaded-profile.jpg',
        },
      ),
    );
    await tester.pump();

    expect(find.text('Loaded Profile'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('go_live_button')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('later profile refresh does not overwrite an edited title', (
    tester,
  ) async {
    final liveKit = LiveKitService();
    addTearDown(liveKit.dispose);
    final accountsController = _StaticAccountsController(
      const AccountState(
        profile: <String, dynamic>{
          'display_name': 'Initial Name',
          'avatar': 'https://example.invalid/profile.jpg',
        },
      ),
    );

    await tester.pumpTestApp(
      const GoLiveScreen(),
      overrides: [
        accountsControllerProvider.overrideWith((_) => accountsController),
        liveMediaServiceProvider.overrideWithValue(
          _UnavailablePreviewMediaService(liveKit),
        ),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go_live_edit_details')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('go_live_title_field')),
      'My chosen title',
    );
    await tester.tap(find.byKey(const Key('go_live_save_details')));
    await tester.pumpAndSettle();

    accountsController.replace(
      const AccountState(
        profile: <String, dynamic>{
          'display_name': 'Updated Profile Name',
          'avatar': 'https://example.invalid/new-profile.jpg',
        },
      ),
    );
    await tester.pump();

    expect(find.text('My chosen title'), findsOneWidget);
    expect(find.text('Updated Profile Name'), findsNothing);
  });

  testWidgets('details sheet remains scrollable at 320px and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpTestApp(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: const GoLiveDetailsSheet(
            initialTitle: 'A readable Live title',
            displayName: 'Kings Collection',
            coverImageUrl: null,
            coverImage: null,
            pickCover: _noCoverSelection,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byKey(const Key('go_live_title_field')), findsOneWidget);
    expect(find.byKey(const Key('go_live_change_cover')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _StaticAccountsController extends AccountsController {
  _StaticAccountsController(AccountState initialState)
    : super(api: _UnusedAccountsApi()) {
    state = initialState;
  }

  void replace(AccountState next) => state = next;
}

class _UnusedAccountsApi extends Fake implements AccountsApi {}

class _UnavailablePreviewMediaService extends LiveMediaService {
  _UnavailablePreviewMediaService(super.liveKit);

  @override
  Future<lk.LocalVideoTrack> prepareCamera({required bool frontCamera}) {
    return Future<lk.LocalVideoTrack>.error(
      StateError('Camera intentionally unavailable in this widget test.'),
    );
  }
}

Future<File?> _noCoverSelection(BuildContext _) => Future<File?>.value();
