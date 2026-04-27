import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService();

  // Clean up when app is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
