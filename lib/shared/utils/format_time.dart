import 'package:intl/intl.dart';

final DateFormat _clockFormat = DateFormat('h:mm a');
final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
final DateFormat _weekdayFormat = DateFormat('EEEE');

String formatTime(DateTime dateTime) {
  return _formatRelativeDate(dateTime, todayValue: _clockFormat.format);
}

String formatMessageTime(DateTime dateTime) {
  return _clockFormat.format(dateTime);
}

String formatDateGroupTitle(DateTime dateTime) {
  return _formatRelativeDate(dateTime, todayValue: (_) => 'Today');
}

String _formatRelativeDate(
  DateTime dateTime, {
  required String Function(DateTime date) todayValue,
}) {
  final now = DateTime.now();
  final localDate = dateTime.toLocal();

  final today = _dateOnly(now);
  final targetDate = _dateOnly(localDate);
  final daysDifference = today.difference(targetDate).inDays;

  if (daysDifference == 0) {
    return todayValue(localDate);
  }

  if (daysDifference == 1) {
    return 'Yesterday';
  }

  if (daysDifference >= 2 && daysDifference < 7) {
    return _weekdayFormat.format(localDate);
  }

  return _dateFormat.format(localDate);
}

DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}
