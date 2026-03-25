import 'package:africaonlinestores/core/utils/logger.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatRealtimeService {
  IO.Socket? _socket;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // -----------------------------
  // Connect
  // -----------------------------
  void connect({required String baseUrl, required String sid}) {
    appLogger.i('⚡ Attempting connect...');
    // prevent duplicate connections
    if (_socket != null && _isConnected) return;

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection() // 🔥 auto reconnect
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setExtraHeaders({'Cookie': 'sid=$sid'})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      appLogger.i('🟢 Realtime connected');
    });

    _socket!.onConnectError((err) {
      appLogger.e('❌ Connect error: $err');
    });

    _socket!.onError((err) {
      appLogger.e('❌ Socket error: $err');
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      appLogger.i('🔴 Realtime disconnected: ${reason.toString()}');
    });

    _socket!.onReconnect((_) {
      appLogger.i('🟡 Realtime reconnected');
    });

    _socket!.connect();
  }

  // -----------------------------
  // Safe Listener Registration
  // -----------------------------
  void onNewMessage(Function(dynamic data) handler) {
    _socket?.off('aos_new_message'); // prevent duplicates
    _socket?.on('aos_new_message', handler);
  }

  void onTyping(Function(dynamic data) handler) {
    _socket?.off('aos_typing');
    _socket?.on('aos_typing', handler);
  }

  void onPresence(Function(dynamic data) handler) {
    _socket?.off('aos_presence_update');
    _socket?.on('aos_presence_update', handler);
  }

  // -----------------------------
  // Remove specific listeners
  // -----------------------------
  void removeNewMessageListener() {
    _socket?.off('aos_new_message');
  }

  void removeTypingListener() {
    _socket?.off('aos_typing');
  }

  void removePresenceListener() {
    _socket?.off('aos_presence_update');
  }

  // -----------------------------
  // Disconnect
  // -----------------------------
  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
