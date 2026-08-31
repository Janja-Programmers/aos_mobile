import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('decode policy converts logical size using device pixel ratio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 3),
          child: Builder(
            builder: (BuildContext context) {
              final AppImageDecodeSize landscape = AppImageDecode.forBox(
                context,
                logicalWidth: 100,
                logicalHeight: 80,
              );
              final AppImageDecodeSize portrait = AppImageDecode.forBox(
                context,
                logicalWidth: 80,
                logicalHeight: 120,
              );

              expect(landscape.width, 300);
              expect(landscape.height, isNull);
              expect(portrait.width, isNull);
              expect(portrait.height, 360);

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });

  testWidgets(
    'decode policy caps thumbnails and ignores unbounded dimensions',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(devicePixelRatio: 4),
            child: Builder(
              builder: (BuildContext context) {
                final AppImageDecodeSize capped = AppImageDecode.forBox(
                  context,
                  logicalWidth: 1000,
                  logicalHeight: 800,
                );
                final AppImageDecodeSize unbounded = AppImageDecode.forBox(
                  context,
                  logicalWidth: double.infinity,
                  logicalHeight: 0,
                );

                expect(capped.width, AppImageDecode.maxThumbnailPixels);
                expect(capped.height, isNull);
                expect(unbounded.width, isNull);
                expect(unbounded.height, isNull);

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    },
  );

  testWidgets('provider resizing preserves aspect ratio with one decode axis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 2),
          child: Builder(
            builder: (BuildContext context) {
              final ImageProvider<Object> provider =
                  AppImageDecode.resizeProvider(
                    context,
                    const NetworkImage('https://example.invalid/avatar.jpg'),
                    logicalWidth: 96,
                    logicalHeight: 96,
                  );

              expect(provider, isA<ResizeImage>());
              final ResizeImage resized = provider as ResizeImage;
              expect(resized.width, 192);
              expect(resized.height, isNull);

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });
}
