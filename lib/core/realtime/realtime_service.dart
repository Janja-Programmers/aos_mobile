import 'dart:async';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class RealtimeService {
  RealtimeService(/* deps */);

  io.Socket? _socket;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final StreamController<RealtimeEvent> _controller =
      StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _controller.stream;

  final StreamController<void> _connectionController =
      StreamController<void>.broadcast();
  Stream<void> get connections => _connectionController.stream;

  void connect({
    required String baseUrl,
    required String siteName,
    required String sid,
    required String email,
  }) {
    if (_socket != null && _isConnected) {
      appLogger.i('[Realtime] Connect ignored: socket already connected');
      return;
    }

    final String url = '$baseUrl/$siteName';
    appLogger.i(
      '[Realtime] Connect requested '
      '(host=${Uri.tryParse(baseUrl)?.host ?? 'unknown'}, site=$siteName, '
      'identityPresent=${email.trim().isNotEmpty})',
    );

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setPath('/socket.io')
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .setExtraHeaders(<String, String>{'Cookie': 'sid=$sid'})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionController.add(null);
      appLogger.i('[Realtime] ✅ Connected (site=$siteName)');
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      final String reasonText = reason is String && reason.trim().isNotEmpty
          ? reason.trim()
          : 'unspecified';
      appLogger.w('[Realtime] Disconnected (reason=$reasonText)');
    });

    _socket!.onReconnect((attempt) {
      _isConnected = true;
      _connectionController.add(null);
      appLogger.i('[Realtime] Reconnected (attempt=$attempt)');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      appLogger.e(
        '[Realtime] Connection failed',
        error: error,
        stackTrace: StackTrace.current,
      );
    });

    _socket!.onError((error) {
      _isConnected = false;
      appLogger.e(
        '[Realtime] Socket error',
        error: error,
        stackTrace: StackTrace.current,
      );
    });

    _socket!.onAny((event, data) {
      final String eventName = event.toString();
      _controller.add(
        RealtimeEvent(
          type: mapRealtimeEvent(eventName),
          eventName: eventName,
          data: data,
        ),
      );
    });

    _socket!.connect();
  }

  void emit(String event, Object? data) {
    if (!_isConnected) return;
    _socket?.emit(event, data);
  }

  Future<void> joinSocketRoom(String liveId) async {
    if (!_isConnected || _socket == null) {
      throw Exception('Socket not connected');
    }
    _socket!.emit('join_live_room', <String, String>{'live_id': liveId});
  }

  Future<void> leaveSocketRoom(String liveId) async {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('leave_live_room', <String, String>{'live_id': liveId});
  }

  void disconnect() {
    if (_socket != null || _isConnected) {
      appLogger.i('[Realtime] Disconnect requested');
    }
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    unawaited(_controller.close());
    unawaited(_connectionController.close());
  }
}
