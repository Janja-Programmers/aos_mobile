import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RealtimeService {
  RealtimeService(/* deps */);

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
      return;
    }

    final url = '$baseUrl/$siteName';

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
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
    });

    _socket!.onError((err) {
      _isConnected = false;
    });

    // -----------------------------
    // All Events
    // -----------------------------
    _socket!.onAny((event, data) {
      final mapped = mapRealtimeEvent(event);

      _controller.add(RealtimeEvent(type: mapped, data: data));
    });

    _socket!.connect();
  }

  // -----------------------------
  // Emit
  // -----------------------------
  void emit(String event, Object? data) {
    if (!_isConnected) return;
    _socket?.emit(event, data);
  }

  Future<void> joinSocketRoom(String liveId) async {
    if (!_isConnected || _socket == null) {
      throw Exception('Socket not connected');
    }

    _socket!.emit('join_live_room', {'live_id': liveId});
  }

  Future<void> leaveSocketRoom(String liveId) async {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('leave_live_room', {'live_id': liveId});
  }

  // -----------------------------
  // Disconnect
  // -----------------------------
  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // -----------------------------
  // Dispose (optional)
  // -----------------------------
  void dispose() {
    disconnect();
    unawaited(_controller.close());
  }
}
