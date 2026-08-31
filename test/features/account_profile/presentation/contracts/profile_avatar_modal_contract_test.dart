import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile avatar chooser stays a modal dialog', () async {
    final File source = File(
      'lib/features/social/presentation/screens/profile_screen.dart',
    );
    final String contents = await source.readAsString();

    expect(contents, contains('showDialog<_AvatarPhotoAction>'));
    expect(
      contents,
      isNot(contains('showModalBottomSheet<_AvatarPhotoAction>')),
    );
  });
}
