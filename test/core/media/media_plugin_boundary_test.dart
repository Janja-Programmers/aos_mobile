import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('picker and preparation plugins stay behind approved adapters', () {
    const approvedImports = <String, Set<String>>{
      'lib/core/media/data/adapters/camera_media_adapter.dart': <String>{
        'camera',
      },
      'lib/core/media/data/adapters/file_picker_media_adapter.dart': <String>{
        'file_picker',
      },
      'lib/core/media/data/adapters/image_picker_gateway.dart': <String>{
        'image_picker',
        'image_picker_android',
        'image_picker_platform_interface',
      },
      'lib/core/media/data/adapters/native_image_preparation_adapter.dart':
          <String>{'flutter_image_compress'},
      'lib/features/shorts/create_short/data/plugin_short_camera_driver.dart':
          <String>{'camera'},
    };
    final importPattern = RegExp(
      'package:(image_picker|image_picker_android|image_picker_platform_interface|'
      'file_picker|camera|flutter_image_compress)/',
    );
    final violations = <String>[];

    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in dartFiles) {
      final path = file.path.replaceAll('\\', '/');
      final source = file.readAsStringSync();
      for (final match in importPattern.allMatches(source)) {
        final plugin = match.group(1);
        if (plugin == null ||
            !(approvedImports[path]?.contains(plugin) ?? false)) {
          violations.add('$path imports $plugin');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
    for (final entry in approvedImports.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final plugin in entry.value) {
        expect(
          source,
          contains('package:$plugin/'),
          reason: '${entry.key} must remain the approved $plugin adapter',
        );
      }
    }

    final galleryGateway = File(
      'lib/core/media/data/adapters/image_picker_gateway.dart',
    ).readAsStringSync();
    expect(
      galleryGateway,
      isNot(contains('ImageSource.camera')),
      reason: 'Still-camera capture must remain inside the app.',
    );
  });

  test('feature code cannot bypass the shared upload coordinator', () {
    final rawUploadPattern = RegExp(r'\.uploadMedia\s*\(');
    final violations = <String>[];
    final featureFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in featureFiles) {
      final source = file.readAsStringSync();
      if (rawUploadPattern.hasMatch(source)) {
        violations.add(file.path.replaceAll('\\', '/'));
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('legacy picker helpers stay deleted', () {
    const retired = <String>[
      'lib/core/media/helpers/media_helper.dart',
      'lib/core/media/helpers/review_media_helper.dart',
      'lib/core/utils/normalize_image.dart',
    ];
    for (final path in retired) {
      expect(File(path).existsSync(), isFalse, reason: '$path is retired');
    }
  });
}
