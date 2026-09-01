import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to supported interaction values', () {
    final state = UploadState.initial();

    expect(state.audience, 'everyone');
    expect(state.allowComments, isTrue);
    expect(state.allowDownloads, isFalse);
    expect(state.saveToDevice, isFalse);
  });

  test('product tagging does not client-classify or block upload', () {
    final video = SelectedMedia(
      File('/tmp/short.mp4'),
      MediaType.video,
      durationSeconds: 30,
    );
    final state = UploadState.initial().copyWith(media: <SelectedMedia>[video]);

    expect(state.canUpload, isTrue);
    expect(state.copyWith(selectedAdId: 'AD-0001').canUpload, isTrue);
  });
}
