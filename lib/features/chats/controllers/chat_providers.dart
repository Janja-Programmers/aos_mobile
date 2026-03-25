import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/chats/data/chat_realtime_service.dart';

/// Realtime service provider (singleton)
final chatRealtimeServiceProvider = Provider<ChatRealtimeService>((ref) {
  final service = ChatRealtimeService();

  // Cleanup when app is destroyed
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
});
