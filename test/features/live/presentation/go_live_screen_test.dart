import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/presentation/screens/go_live_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('blank title disables Go Live and controls use button color', (
    tester,
  ) async {
    final liveKit = LiveKitService();
    addTearDown(liveKit.dispose);

    await tester.pumpTestApp(
      const GoLiveScreen(),
      overrides: [
        liveMediaServiceProvider.overrideWithValue(
          _UnavailablePreviewMediaService(liveKit),
        ),
      ],
    );
    await tester.pumpAndSettle();

    ElevatedButton goLiveButton() => tester.widget<ElevatedButton>(
      find.byKey(const Key('go_live_button')),
    );

    expect(goLiveButton().onPressed, isNull);

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

    await tester.enterText(
      find.byKey(const Key('go_live_title_field')),
      '   ',
    );
    await tester.pump();
    expect(goLiveButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('go_live_title_field')),
      'An AOS Live title',
    );
    await tester.pump();
    expect(goLiveButton().onPressed, isNotNull);
  });
}

class _UnavailablePreviewMediaService extends LiveMediaService {
  _UnavailablePreviewMediaService(super.liveKit);

  @override
  Future<lk.LocalVideoTrack> prepareCamera({required bool frontCamera}) {
    return Future<lk.LocalVideoTrack>.error(
      StateError('Camera intentionally unavailable in this widget test.'),
    );
  }
}
