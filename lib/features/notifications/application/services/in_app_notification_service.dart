import 'dart:async';

import 'dart:collection';

import 'package:flutter/services.dart';

class InAppNotificationService {
  final _controller = StreamController<InAppNotificationData?>.broadcast();

  final Queue<InAppNotificationData> _queue = Queue();
  bool _isShowing = false;

  Stream<InAppNotificationData?> get stream => _controller.stream;

  void show({
    required String id,
    required String title,
    required String body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    _queue.add(
      InAppNotificationData(
        id: id,
        title: title,
        body: body,
        onTap: onTap,
        duration: duration,
      ),
    );

    _drainQueue();
  }

  void markDismissed() {
    _isShowing = false;
    _controller.add(null);
    _drainQueue();
  }

  void _drainQueue() {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;
    final next = _queue.removeFirst();

    // subtle foreground feedback
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();

    _controller.add(next);
  }

  void dispose() {
    _controller.close();
  }
}

class InAppNotificationData {
  final String id;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final Duration duration;

  const InAppNotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.onTap,
    required this.duration,
  });
}
