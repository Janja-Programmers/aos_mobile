import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatRealtimeService {
  IO.Socket? _socket;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // -----------------------------
  // Stream Controllers
  // -----------------------------
  final _messageController = StreamController<dynamic>.broadcast();
  final _typingController = StreamController<dynamic>.broadcast();
  final _presenceController = StreamController<dynamic>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // -----------------------------
  // Public Streams
  // -----------------------------
  Stream<dynamic> get messages => _messageController.stream;
  Stream<dynamic> get typing => _typingController.stream;
  Stream<dynamic> get presence => _presenceController.stream;
  Stream<bool> get connection => _connectionController.stream;

  // -----------------------------
  // Connect
  // -----------------------------
  void connect({required String baseUrl, required String sid}) {
    appLogger.i('⚡ Attempting realtime connection...');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setPath('/socket.io')
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setExtraHeaders({'Cookie': 'sid=$sid'})
          .build(),
    );

    // Prevent duplicate connections
    if (_socket != null && _isConnected) {
      appLogger.i('⚠️ Already connected. Skipping.');
      return;
    }

    // -----------------------------
    // Core Connection Events
    // -----------------------------
    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionController.add(true);

      appLogger.i('🟢 Realtime connected');

      // 🔥 CRITICAL FIX
      _socket!.emit('login', {'sid': sid});
    });
    _socket!.onDisconnect((reason) {
      _isConnected = false;
      _connectionController.add(false);
      appLogger.w('🔴 Disconnected: $reason');
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      _connectionController.add(true);
      appLogger.i('🟡 Reconnected');
    });

    _socket!.onConnectError((err) {
      appLogger.e('❌ Connect error: $err');
    });

    _socket!.onError((err) {
      appLogger.e('❌ Socket error: $err');
    });

    // -----------------------------
    // App Events
    // -----------------------------
    _socket!.on('aos_new_message', (data) {
      appLogger.i('📩 Message event received: $data');
      _messageController.add(data);
    });

    _socket!.on('aos_typing', (data) {
      appLogger.i('Listening to aos_typing .');
      _typingController.add(data);
    });

    _socket!.on('aos_presence_update', (data) {
      appLogger.i('Listening to aos_presence_update .');
      _presenceController.add(data);
    });

    // Register listener FIRST
    _socket!.onAny((event, data) {
      appLogger.i('🔥 RAW SOCKET EVENT → $event → $data');
    });

    // Then connect
    _socket!.connect();
  }

  // -----------------------------
  // Emit Helpers
  // -----------------------------
  void sendTyping({required String conversationId, required bool isTyping}) {
    if (!_isConnected) return;

    _socket?.emit('typing', {
      'conversation_id': conversationId,
      'is_typing': isTyping ? 1 : 0,
    });
  }

  // (Optional future use)
  void sendMessageAck(Map<String, dynamic> payload) {
    if (!_isConnected) return;
    _socket?.emit('message_ack', payload);
  }

  // -----------------------------
  // Disconnect
  // -----------------------------
  void disconnect() {
    appLogger.i('⚡ Disconnecting realtime...');

    _socket?.dispose();
    _socket = null;

    _isConnected = false;
    _connectionController.add(false);
  }

  // -----------------------------
  // Dispose بالكامل (call on app shutdown)
  // -----------------------------
  void dispose() {
    disconnect();

    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _connectionController.close();
  }
}
