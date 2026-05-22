import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AndroidNotificationConfig {
  static const AndroidNotificationChannel general = AndroidNotificationChannel(
    'aos_notifications',
    'AOS Notifications',
    description: 'General notifications for AOS',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel calls = AndroidNotificationChannel(
    'aos_calls',
    'AOS Calls',
    description: 'Incoming call alerts for AOS',
    importance: Importance.max,
  );
}
