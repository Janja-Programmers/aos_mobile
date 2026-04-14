// -----------------------------
// Format time (smarter UX)
// -----------------------------
String formatTime(DateTime dt) {
  final now = DateTime.now();

  // normalize (remove time)
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);

  final difference = today.difference(date).inDays;

  // ✅ TODAY → time
  if (difference == 0) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return "$hour:$minute $period";
  }

  // ✅ YESTERDAY
  if (difference == 1) {
    return "Yesterday";
  }

  // ✅ LAST 7 DAYS
  if (difference < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }

  // ✅ OLDER
  return "${dt.day}/${dt.month}";
}
