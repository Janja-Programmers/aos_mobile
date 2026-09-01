import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/features/live/domain/live_host.dart';
import 'package:africaonlinestores/features/live/domain/live_status.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/live_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_creator.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_viewer_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Short card survives a narrow column at 200% text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        locale: const Locale('en'),
        dark: false,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 168,
              child: ShortCard(short: _short(), onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('00:22'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });

  testWidgets('Live card survives RTL dark mode at 200% text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        locale: const Locale('ar'),
        dark: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 170,
            height: 230,
            child: LiveCard(live: _live(), onTap: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.podcasts_rounded), findsOneWidget);
  });
}

Widget _testApp({
  required Locale locale,
  required bool dark,
  required Widget child,
}) {
  return MaterialApp(
    locale: locale,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: Scaffold(body: SafeArea(child: child)),
        );
      },
    ),
  );
}

Short _short() {
  return Short(
    id: const ShortId('SHORT-1'),
    playbackUrl: 'https://example.invalid/short.m3u8',
    durationSeconds: 22,
    contentMode: ShortContentModes.shop,
    caption: Caption(
      'A deliberately long short caption that must wrap safely on a narrow device without hiding the creator row.',
    ),
    hashtags: const <String>[],
    status: ShortStatus.ready,
    isReady: true,
    creator: const ShortCreator(
      user: 'ACC-1',
      displayName: 'A very long creator display name for layout validation',
      isVerified: false,
    ),
    metrics: ShortMetrics.initial().copyWith(likeCount: 2800),
    viewerState: ShortViewerState.initial(),
  );
}

LiveStream _live() {
  return LiveStream.initial().copyWith(
    id: 'LIVE-1',
    title:
        'A deliberately long live title that should remain readable without overflow',
    status: AOSLiveStatus.live,
    host: const LiveHost(
      userId: 'ACC-2',
      displayName: 'Creator with a long display name',
    ),
    viewerCount: 12500,
    isActive: true,
    hostUser: 'ACC-2',
    hostDisplayName: 'Creator with a long display name',
    thumbnail: '',
    coverImage: '',
  );
}
