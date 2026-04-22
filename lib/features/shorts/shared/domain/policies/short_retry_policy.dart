import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortRetryPolicy {
  const ShortRetryPolicy();

  bool canRetry(Short short) {
    return short.status.canRetry;
  }
}
