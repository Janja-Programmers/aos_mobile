import 'package:africaonlinestores/core/media/application/media_picker_operation_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only one external media picker owns the result channel at a time', () {
    final coordinator = MediaPickerOperationCoordinator();
    final gallery = coordinator.acquire(MediaPickerOwner.photoLibrary);

    expect(coordinator.activeOwner, MediaPickerOwner.photoLibrary);
    expect(
      () => coordinator.acquire(MediaPickerOwner.fileBrowser),
      throwsA(isA<MediaPickerBusyException>()),
    );

    gallery.release();
    final files = coordinator.acquire(MediaPickerOwner.fileBrowser);
    expect(coordinator.activeOwner, MediaPickerOwner.fileBrowser);

    files.release();
    expect(coordinator.activeOwner, isNull);
  });

  test('picker lease release is idempotent', () {
    final coordinator = MediaPickerOperationCoordinator();
    final lease = coordinator.acquire(MediaPickerOwner.photoLibrary);

    lease.release();
    lease.release();

    expect(lease.isReleased, isTrue);
    expect(coordinator.activeOwner, isNull);
  });
}
