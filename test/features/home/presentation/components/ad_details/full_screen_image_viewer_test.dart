import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('exposes a localized direct-download action without overflow', (
    tester,
  ) async {
    await tester.pumpTestApp(
      const MediaQuery(
        data: MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(2),
        ),
        child: FullScreenImageViewer(images: <String>[], initialIndex: 0),
      ),
    );

    expect(find.byTooltip('Download image'), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
