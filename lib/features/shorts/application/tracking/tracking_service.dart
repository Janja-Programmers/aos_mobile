import 'dart:async';

import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_tracking_api.dart.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class TrackingService {
  final ShortsTrackingApi _api;

  TrackingService(this._api);

  // ───────────── INTERNAL STATE ─────────────

  final Set<String> _impressionsSent = {};
  final Set<String> _viewsSent = {};

  final Set<String> _pendingImpressions = {};
  final Set<String> _pendingViews = {};

  Timer? _flushTimer;

  // ───────────── CONFIG ─────────────

  static const Duration flushInterval = Duration(seconds: 3);
  static const Duration viewThreshold = Duration(seconds: 2);

  // ───────────── START ─────────────

  void start() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(flushInterval, (_) => _flush());
  }

  void dispose() {
    _flushTimer?.cancel();
  }

  // ───────────── IMPRESSION ─────────────

  void trackImpression(ShortId shortId) {
    final id = shortId.value;

    if (_impressionsSent.contains(id)) return;

    _pendingImpressions.add(id);
  }

  // ───────────── VIEW TRACKING ─────────────

  final Map<String, DateTime> _viewTimers = {};

  void startViewTimer(ShortId shortId) {
    final id = shortId.value;

    if (_viewsSent.contains(id)) return;

    _viewTimers[id] = DateTime.now();
  }

  void stopViewTimer(ShortId shortId) {
    final id = shortId.value;

    final start = _viewTimers[id];
    if (start == null) return;

    final duration = DateTime.now().difference(start);

    if (duration >= viewThreshold) {
      _pendingViews.add(id);
    }

    _viewTimers.remove(id);
  }

  // ───────────── FLUSH ─────────────

  Future<void> _flush() async {
    // Flush impressions
    for (final id in _pendingImpressions) {
      await _api.trackImpression(shortId: id);
      _impressionsSent.add(id);
    }
    _pendingImpressions.clear();

    // Flush views
    for (final id in _pendingViews) {
      await _api.trackView(shortId: id);
      _viewsSent.add(id);
    }
    _pendingViews.clear();
  }
}
