import 'dart:async';

class CallTimer {
  Timer? _timer;
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  Duration _elapsed = Duration.zero;

  Stream<Duration> get stream => _durationController.stream;
  Duration get elapsed => _elapsed;

  void start() {
    stop();
    _elapsed = Duration.zero;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
      _durationController.add(_elapsed);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    _elapsed = Duration.zero;
    _durationController.add(_elapsed);
  }

  Future<void> dispose() async {
    stop();
    await _durationController.close();
  }
}
