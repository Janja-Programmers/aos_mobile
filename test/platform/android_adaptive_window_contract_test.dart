import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated launch themes stay free of legacy window overrides', () {
    const List<String> stylePaths = <String>[
      'android/app/src/main/res/values/styles.xml',
      'android/app/src/main/res/values-night/styles.xml',
      'android/app/src/main/res/values-v31/styles.xml',
      'android/app/src/main/res/values-night-v31/styles.xml',
    ];
    const List<String> retiredItems = <String>[
      'android:windowFullscreen',
      'android:windowDrawsSystemBarBackgrounds',
      'android:windowLayoutInDisplayCutoutMode',
    ];

    for (final String path in stylePaths) {
      final String source = File(path).readAsStringSync();
      for (final String retiredItem in retiredItems) {
        expect(
          source,
          isNot(contains(retiredItem)),
          reason: '$path: $retiredItem',
        );
      }
    }

    final String lightV31 = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();
    final String darkV31 = File(
      'android/app/src/main/res/values-night-v31/styles.xml',
    ).readAsStringSync();
    for (final String source in <String>[lightV31, darkV31]) {
      expect(source, contains('android:windowSplashScreenBackground'));
      expect(source, contains('android:windowSplashScreenAnimatedIcon'));
    }
  });

  test('native splash configuration remains non-fullscreen', () {
    final String source = File('flutter_native_splash.yaml').readAsStringSync();
    expect(source, contains('fullscreen: false'));
    expect(source, isNot(contains('fullscreen: true')));
  });

  test('uCrop activity remains adaptive instead of portrait locked', () {
    final String manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    const String activityName =
        'android:name="com.yalantis.ucrop.UCropActivity"';
    final int activityStart = manifest.indexOf(activityName);

    expect(activityStart, greaterThanOrEqualTo(0));
    final int activityEnd = manifest.indexOf('/>', activityStart);
    expect(activityEnd, greaterThan(activityStart));

    final String activity = manifest.substring(activityStart, activityEnd + 2);
    expect(activity, isNot(contains('android:screenOrientation')));
    expect(activity, isNot(contains('android:resizeableActivity="false"')));
  });

  test('Flutter splash owns system icon brightness but not bar colors', () {
    final String source = File(
      'lib/app/splash/splash_screen.dart',
    ).readAsStringSync();

    expect(source, contains('statusBarIconBrightness:'));
    expect(source, contains('systemNavigationBarIconBrightness:'));
    expect(source, isNot(contains('statusBarColor:')));
    expect(source, isNot(contains('systemNavigationBarColor:')));
  });
}
