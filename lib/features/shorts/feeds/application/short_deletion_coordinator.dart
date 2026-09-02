import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:flutter/foundation.dart';

typedef DeleteShortRequest =
    Future<Either<Failure, void>> Function({required String shortId});

/// Application-layer coordinator for deleting a Short from detail/manage UI.
class ShortDeletionCoordinator {
  const ShortDeletionCoordinator({
    required DeleteShortRequest deleteShort,
    required Future<void> Function() refreshShorts,
  }) : _deleteShort = deleteShort,
       _refreshShorts = refreshShorts;

  final DeleteShortRequest _deleteShort;
  final Future<void> Function() _refreshShorts;

  Future<String?> deleteShort(String shortId) async {
    final normalizedShortId = shortId.trim();
    if (normalizedShortId.isEmpty) {
      return 'Invalid Short.';
    }

    try {
      final result = await _deleteShort(shortId: normalizedShortId);
      if (result.isLeft) {
        return result.leftOrNull?.message ?? 'Unable to delete Short.';
      }

      try {
        await _refreshShorts();
      } catch (error, stackTrace) {
        debugPrint(
          'Short deleted but feed refresh failed: $error\n$stackTrace',
        );
      }
      return null;
    } catch (error, stackTrace) {
      debugPrint('Delete Short command failed: $error\n$stackTrace');
      return 'Unable to delete Short. Please try again.';
    }
  }
}
