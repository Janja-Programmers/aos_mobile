import 'dart:async';

import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/domain/repository/shorts_repository.dart';

class ProcessingWatcher {
  final ShortsRepository _repository;
  final Duration interval;
  final int maxAttempts;

  const ProcessingWatcher(
    this._repository, {
    this.interval = const Duration(seconds: 2),
    this.maxAttempts = 30,
  });

  Future<Short> waitUntilReady(ShortId shortId) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      final short = await _repository.getShort(shortId: shortId);

      if (short.isPlayable) {
        return short;
      }

      if (short.canRetry) {
        return short;
      }

      await Future.delayed(interval);
      attempts++;
    }

    return _repository.getShort(shortId: shortId);
  }
}
