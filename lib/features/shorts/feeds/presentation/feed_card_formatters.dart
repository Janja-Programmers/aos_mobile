String formatFeedDuration(double seconds) {
  if (!seconds.isFinite || seconds <= 0) return '';

  final totalSeconds = seconds.floor();
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final remainingSeconds = totalSeconds % 60;

  final minuteText = minutes.toString().padLeft(2, '0');
  final secondText = remainingSeconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:$minuteText:$secondText';
  }

  return '$minuteText:$secondText';
}

String formatFeedCount(int count) {
  final safeCount = count < 0 ? 0 : count;

  if (safeCount < 1000) return safeCount.toString();
  if (safeCount < 1000000) return _compact(safeCount / 1000, 'K');
  if (safeCount < 1000000000) return _compact(safeCount / 1000000, 'M');
  return _compact(safeCount / 1000000000, 'B');
}

String _compact(double value, String suffix) {
  final rounded = value >= 10
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return '$rounded$suffix';
}
