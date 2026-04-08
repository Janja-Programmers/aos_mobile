import 'dart:async';

// ignore: library_prefixes
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';

class RealtimeService {
  IO.Socket? _socket;

  // -----------------------------
  // Connection State
  // -----------------------------
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // -----------------------------
  // Event Stream
  // -----------------------------
  final _controller = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _controller.stream;

  // -----------------------------
  // Connect
  // -----------------------------
  void connect({
    required String baseUrl,
    required String siteName,
    required String sid,
    required String email,
  }) {
    // 🔥 Prevent duplicate connections
    if (_socket != null && _isConnected) {
      appLogger.w('[Realtime] Already connected → skipping connect');
      return;
    }

    final url = "$baseUrl/$siteName";

    appLogger.i('[Realtime] Connecting to $url');
    appLogger.i('[Realtime] User: $email');

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setPath('/socket.io')
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .setExtraHeaders({'Cookie': 'sid=$sid'})
          .build(),
    );

    // -----------------------------
    // Core Events
    // -----------------------------
    _socket!.onConnect((_) {
      _isConnected = true;

      appLogger.i('[Realtime] ✅ Connected');

      // Subscribe to user room
      final room = "user:$email";
      appLogger.i('[Realtime] Subscribing → $room');

      _socket!.emit("subscribe", room);
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      appLogger.w('[Realtime] ❌ Disconnected → $reason');
    });

    _socket!.onReconnect((_) {
      _isConnected = true;

      appLogger.i('[Realtime] 🔁 Reconnected');

      final room = "user:$email";
      appLogger.i('[Realtime] Re-subscribing → $room');

      _socket!.emit("subscribe", room);
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      appLogger.e('[Realtime] ⚠️ Connect error → $err');
    });

    _socket!.onError((err) {
      _isConnected = false;
      appLogger.e('[Realtime] ⚠️ Socket error → $err');
    });

    // -----------------------------
    // All Events
    // -----------------------------
    _socket!.onAny((event, data) {
      final mapped = mapRealtimeEvent(event);

      appLogger.i('[Realtime] 📡 Event → $event');
      appLogger.i('[Realtime] Data → $data');

      _controller.add(RealtimeEvent(type: mapped, data: data));
    });

    appLogger.i('[Realtime] Initiating socket connection...');
    _socket!.connect();
  }

  // -----------------------------
  // Emit
  // -----------------------------
  void emit(String event, dynamic data) {
    if (!_isConnected) return;
    _socket?.emit(event, data);
  }

  // -----------------------------
  // Disconnect
  // -----------------------------
  void disconnect() {
    appLogger.w('[Realtime] 🔌 Disconnecting socket');

    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // -----------------------------
  // Dispose (optional)
  // -----------------------------
  void dispose() {
    disconnect();
    _controller.close();
  }
}
