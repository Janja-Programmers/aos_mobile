import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';

final notificationUnreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationControllerProvider);
  return state.unreadCount;
});
