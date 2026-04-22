import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short.dart';

class ShortRetryPolicy {
  const ShortRetryPolicy();

  bool canRetry(Short short) {
    return short.status.canRetry;
  }
}
