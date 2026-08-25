import 'package:africaonlinestores/core/media/application/media_camera_resource_coordinator.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only one non-call camera owner can hold the resource', () {
    final coordinator = MediaCameraResourceCoordinator();
    final live = coordinator.acquire(MediaCameraOwner.live);

    expect(coordinator.activeOwner, MediaCameraOwner.live);
    expect(
      () => coordinator.acquire(MediaCameraOwner.shorts),
      throwsA(isA<MediaCameraBusyException>()),
    );

    live.release();
    final shorts = coordinator.acquire(MediaCameraOwner.shorts);
    expect(coordinator.activeOwner, MediaCameraOwner.shorts);

    shorts.release();
    shorts.release();
    expect(coordinator.activeOwner, isNull);
  });

  test('a stale lease cannot release the current owner', () {
    final coordinator = MediaCameraResourceCoordinator();
    final first = coordinator.acquire(MediaCameraOwner.sharedCapture);
    first.release();
    final second = coordinator.acquire(MediaCameraOwner.live);

    first.release();
    expect(coordinator.activeOwner, MediaCameraOwner.live);

    second.release();
  });
}
