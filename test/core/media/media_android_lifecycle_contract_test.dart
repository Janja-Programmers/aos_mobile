import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android root activity uses singleTask for result-returning pickers',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android:launchMode="singleTask"'));
      expect(manifest, isNot(contains('android:launchMode="singleInstance"')));
    },
  );

  test('Android gallery uses the endorsed system Photo Picker path', () {
    final gateway = File(
      'lib/core/media/data/adapters/image_picker_gateway.dart',
    ).readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(gateway, contains('ImagePickerPlatform.instance'));
    expect(gateway, contains('ImagePickerAndroid'));
    expect(gateway, contains('useAndroidPhotoPicker = true'));
    expect(gateway, contains('requestFullMetadata: false'));
    expect(pubspec, contains('image_picker: ^1.2.1'));
    expect(pubspec, contains('image_picker_android: 0.8.13+16'));
    expect(pubspec, contains('image_picker_platform_interface: 2.11.1'));
  });

  test(
    'gallery lifecycle initialization is a compile-time adapter contract',
    () {
      final ports = File(
        'lib/core/media/application/media_acquisition_ports.dart',
      ).readAsStringSync();
      final service = File(
        'lib/core/media/application/media_acquisition_service.dart',
      ).readAsStringSync();

      expect(
        ports,
        contains(
          'GalleryMediaAdapter\n    implements MediaLifecycleInitializable',
        ),
      );
      expect(service, contains('await _gallery.initialize();'));
      expect(
        service,
        isNot(contains('gallery is MediaLifecycleInitializable')),
      );
    },
  );

  test('picker recovery starts at app bootstrap and is request-scoped', () {
    final bootstrap = File(
      'lib/app/bootstrap/app_bootstrap_controller.dart',
    ).readAsStringSync();
    final adapter = File(
      'lib/core/media/data/adapters/image_picker_media_adapter.dart',
    ).readAsStringSync();

    expect(bootstrap, contains('_initializeMediaLifecycle'));
    expect(bootstrap, contains('await _media.initialize()'));
    expect(adapter, contains('media.image_picker.pending.v2'));
    expect(adapter, contains("'use_case': useCase.name"));
    expect(adapter, contains("'kind': kind.name"));
    expect(adapter, contains('_maxRecoveryAge'));
  });

  test('camera switches to captured preview before controller disposal', () {
    final camera = File(
      'lib/core/media/data/adapters/camera_media_adapter.dart',
    ).readAsStringSync();

    expect(camera, contains('_showCapturedPreviewBeforeRelease'));
    expect(camera, contains('WidgetsBinding.instance.endOfFrame'));
    expect(camera, contains('_captureFinalizing = true'));
    expect(camera, contains('_captureFinalizing ? null : _useCapture'));
  });
}
