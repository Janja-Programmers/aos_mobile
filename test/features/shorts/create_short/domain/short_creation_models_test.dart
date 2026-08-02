import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_editor_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recording limits match the production design', () {
    expect(
      ShortRecordingLimit.values.map((value) => value.duration).toList(),
      const <Duration>[
        Duration(seconds: 15),
        Duration(seconds: 60),
        Duration(minutes: 3),
      ],
    );
  });

  group('trim validation', () {
    const duration = Duration(seconds: 10);

    test('accepts a valid non-zero range', () {
      expect(
        ShortEditorController.isValidTrim(
          const Duration(seconds: 1),
          const Duration(seconds: 8),
          duration,
        ),
        isTrue,
      );
    });

    test('rejects out-of-range and too-short ranges', () {
      expect(
        ShortEditorController.isValidTrim(
          Duration.zero,
          const Duration(milliseconds: 200),
          duration,
        ),
        isFalse,
      );
      expect(
        ShortEditorController.isValidTrim(
          const Duration(seconds: 9),
          const Duration(seconds: 11),
          duration,
        ),
        isFalse,
      );
    });
  });

  test('overlay serialization clamps normalized coordinates and scale', () {
    final restored = ShortOverlay.fromJson(<String, dynamic>{
      'id': 'overlay-1',
      'kind': 'caption',
      'content': 'Hello',
      'x': 2,
      'y': -1,
      'color': 0xFFFFFFFF,
      'scale': 12,
    });

    expect(restored.kind, ShortOverlayKind.caption);
    expect(restored.normalizedPosition, const Offset(1, 0));
    expect(restored.scale, 3);
  });
}
