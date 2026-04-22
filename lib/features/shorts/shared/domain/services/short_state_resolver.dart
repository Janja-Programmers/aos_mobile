import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';

class ShortStateResolver {
  const ShortStateResolver();

  ShortStatus resolve({
    required bool isReady,
    required bool isProcessing,
    required bool isFailed,
  }) {
    if (isFailed) return ShortStatus.failed;
    if (isProcessing) return ShortStatus.processing;
    if (isReady) return ShortStatus.ready;

    return ShortStatus.initialized;
  }
}
