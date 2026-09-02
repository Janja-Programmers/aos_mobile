import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/short_deletion_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('successful delete refreshes Shorts once', () async {
    String? deletedShortId;
    var refreshCount = 0;

    final coordinator = ShortDeletionCoordinator(
      deleteShort: ({required String shortId}) async {
        deletedShortId = shortId;
        return Either<Failure, void>.right(null);
      },
      refreshShorts: () async {
        refreshCount++;
      },
    );

    final error = await coordinator.deleteShort('SHORT-001');

    expect(error, isNull);
    expect(deletedShortId, 'SHORT-001');
    expect(refreshCount, 1);
  });

  test(
    'failed delete preserves backend failure and does not refresh',
    () async {
      var refreshCount = 0;

      final coordinator = ShortDeletionCoordinator(
        deleteShort: ({required String shortId}) async {
          return Either<Failure, void>.left(const Failure('Not allowed.'));
        },
        refreshShorts: () async {
          refreshCount++;
        },
      );

      final error = await coordinator.deleteShort('SHORT-002');

      expect(error, 'Not allowed.');
      expect(refreshCount, 0);
    },
  );

  test('empty Short id is rejected before transport', () async {
    var deleteCalls = 0;

    final coordinator = ShortDeletionCoordinator(
      deleteShort: ({required String shortId}) async {
        deleteCalls++;
        return Either<Failure, void>.right(null);
      },
      refreshShorts: () async {},
    );

    final error = await coordinator.deleteShort('   ');

    expect(error, 'Invalid Short.');
    expect(deleteCalls, 0);
  });
}
