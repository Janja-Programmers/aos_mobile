String formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final localDate = dateTime.toLocal();

  if (_isSameDay(localDate, now)) {
    return _formatClockTime(localDate);
  }

  if (_isSameDay(localDate, now.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }

  final daysDifference = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(localDate.year, localDate.month, localDate.day)).inDays;

  if (daysDifference >= 2 && daysDifference < 7) {
    return _weekdayName(localDate.weekday);
  }

  return _formatSlashDate(localDate);
}

bool _isSameDay(DateTime a, DateTime b) {
  final localA = a.toLocal();
  final localB = b.toLocal();

  return localA.year == localB.year &&
      localA.month == localB.month &&
      localA.day == localB.day;
}

String _formatClockTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');

  final isPm = hour >= 12;
  final displayHour = hour == 0
      ? 12
      : hour > 12
      ? hour - 12
      : hour;

  return '$displayHour:$minute ${isPm ? 'PM' : 'AM'}';
}

String _weekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return '';
  }
}

String _formatSlashDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();

  return '$day/$month/$year';
}

String formatDateGroupTitle(DateTime dateTime) {
  final now = DateTime.now();
  final localDate = dateTime.toLocal();

  if (_isSameDay(localDate, now)) {
    return 'Today';
  }

  if (_isSameDay(localDate, now.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }

  final daysDifference = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(localDate.year, localDate.month, localDate.day)).inDays;

  if (daysDifference >= 2 && daysDifference < 7) {
    return _weekdayName(localDate.weekday);
  }

  return _formatSlashDate(localDate);
}
