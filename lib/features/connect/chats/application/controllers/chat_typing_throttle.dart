import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:flutter/foundation.dart';

class ChatTypingThrottle {
  final String conversationId;
  final Future<Either<Failure, void>> Function({
    required String conversationId,
    required bool isTyping,
  })
  sendTyping;
  final Duration resendInterval;
  final Duration idleTimeout;

  Timer? _idleTimer;
  DateTime? _lastTypingTrueSentAt;
  bool _lastSentTypingState = false;
  bool _disposed = false;

  ChatTypingThrottle({
    required this.conversationId,
    required this.sendTyping,
    this.resendInterval = const Duration(seconds: 2),
    this.idleTimeout = const Duration(seconds: 3),
  });

  void update(bool hasText) {
    if (_disposed) return;

    _idleTimer?.cancel();

    if (!hasText) {
      _sendFalseIfNeeded();
      return;
    }

    final now = DateTime.now();
    final shouldSendTrue =
        !_lastSentTypingState ||
        _lastTypingTrueSentAt == null ||
        now.difference(_lastTypingTrueSentAt!) >= resendInterval;

    if (shouldSendTrue) {
      _send(true);
    }

    _idleTimer = Timer(idleTimeout, _sendFalseIfNeeded);
  }

  void _sendFalseIfNeeded() {
    if (!_lastSentTypingState) return;
    _send(false);
  }

  void _send(bool isTyping) {
    if (_disposed) return;

    _lastSentTypingState = isTyping;
    if (isTyping) {
      _lastTypingTrueSentAt = DateTime.now();
    }

    unawaited(_sendSafely(isTyping));
  }

  Future<void> _sendSafely(bool isTyping) async {
    final result = await sendTyping(
      conversationId: conversationId,
      isTyping: isTyping,
    );

    if (result.isLeft) {
      debugPrint('Typing status failed: ${result.leftOrNull}');
    }
  }

  void dispose() {
    if (_disposed) return;

    _disposed = true;
    _idleTimer?.cancel();

    if (_lastSentTypingState) {
      unawaited(sendTyping(conversationId: conversationId, isTyping: false));
    }
  }
}
