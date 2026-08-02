import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to the backend geo mode and supported interaction values', () {
    final state = UploadState.initial();

    expect(state.contentMode, 'geo');
    expect(state.audience, 'everyone');
    expect(state.allowComments, isTrue);
    expect(state.allowDownloads, isFalse);
    expect(state.saveToDevice, isFalse);
  });

  test('requires a video and an ad only for Shop', () {
    final video = SelectedMedia(File('/tmp/short.mp4'), MediaType.video);
    final geo = UploadState.initial().copyWith(media: <SelectedMedia>[video]);
    final shop = geo.copyWith(contentMode: 'shop');

    expect(geo.canUpload, isTrue);
    expect(shop.canUpload, isFalse);
    expect(shop.copyWith(selectedAdId: 'AD-0001').canUpload, isTrue);
  });
}
