import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/features/connect/chats/data/services/chat_realtime_service.dart';

/// Realtime service provider (singleton)
final chatRealtimeServiceProvider = Provider<ChatRealtimeService>((ref) {
  return ChatRealtimeService(ref.read(realtimeServiceProvider));
});
