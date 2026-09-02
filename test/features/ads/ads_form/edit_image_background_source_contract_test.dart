import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('background taps update preview state without encoding per tap', () {
    final editor = File(
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/'
      'edit_image_screen.dart',
    ).readAsStringSync();

    expect(editor, contains('bool _backgroundSelectionMade = false'));
    expect(editor, contains('void _applyBackground(Color? color)'));
    expect(editor, contains('void _applyGradient(List<Color> colors)'));
    expect(editor, contains('Future<void> _materializeBackground()'));
    expect(editor, contains('await _materializeBackground()'));
    expect(editor, contains('Widget _buildPreview()'));
    expect(editor, contains('FittedBox('));
    expect(editor, isNot(contains('Future<void> _applyBackground')));
    expect(editor, isNot(contains('Future<void> _applyGradient')));
  });

  test('transparent selection and returned temp-file ownership are explicit', () {
    final editor = File(
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/'
      'edit_image_screen.dart',
    ).readAsStringSync();
    final picker = File(
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/'
      'background_picker.dart',
    ).readAsStringSync();

    expect(editor, contains('_returnedFilePath = _file.path'));
    expect(editor, contains('if (file.path == _returnedFilePath) continue'));
    expect(editor, contains('transparentSelected:'));
    expect(picker, contains('required this.transparentSelected'));
    expect(picker, contains('selected: transparentSelected'));
  });

  test('background-removal media stays temporary until final upload', () {
    final controller = File(
      'lib/features/ads/shared/providers/ad_draft_controller.dart',
    ).readAsStringSync();
    final editor = File(
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/'
      'edit_image_screen.dart',
    ).readAsStringSync();
    final media = File(
      'lib/features/ads/ads_form/presentation/steps/basic/media_section.dart',
    ).readAsStringSync();

    expect(controller, contains('requestImageBackgroundRemoval'));
    expect(controller, isNot(contains('removeImageBackground(')));
    expect(editor, contains('deleteMediaSilently(generated.fileId)'));
    expect(media, contains('final replaceResult = await ref'));
    expect(media, contains('_editingImage'));
  });
}
