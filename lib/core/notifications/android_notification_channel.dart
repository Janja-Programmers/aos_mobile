import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AndroidNotificationConfig {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'aos_notifications', // 🔥 ID (must match backend if specified)
    'AOS Notifications',
    description: 'General notifications for AOS',
    importance: Importance.high,
  );
}
