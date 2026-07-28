import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum PendingCallKitAction { accept, decline, ended, timeout }

class CallKitPendingPayloadStore {
  static const String key = 'pending_incoming_call_payload';
  static const String actionKey = 'pending_callkit_action';
  static const String handledActionsKey = 'handled_callkit_actions';
  static const Duration handledActionRetention = Duration(days: 7);

  const CallKitPendingPayloadStore();

  Future<void> save(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return _decodeMap(prefs.getString(key));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearIfMatches(String callId) async {
    final cleanCallId = _clean(callId);
    if (cleanCallId == null) return;

    final payload = await read();
    if (payload == null) return;

    final pendingCallId = _clean(
      payload['call_id'] ?? payload['backend_call_id'] ?? payload['id'],
    );
    if (pendingCallId == cleanCallId) {
      await clear();
    }
  }

  Future<void> saveAction({
    required String callId,
    required PendingCallKitAction action,
    String? callkitUuid,
  }) async {
    final cleanCallId = _clean(callId);
    if (cleanCallId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      actionKey,
      jsonEncode(<String, dynamic>{
        'call_id': cleanCallId,
        'action': action.name,
        'callkit_uuid': _clean(callkitUuid),
        'created_at_ms': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  Future<Map<String, dynamic>?> readAction() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return _decodeMap(prefs.getString(actionKey));
  }

  Future<void> clearAction() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(actionKey);
  }

  Future<void> clearActionIfMatches(String callId) async {
    final cleanCallId = _clean(callId);
    if (cleanCallId == null) return;

    final action = await readAction();
    if (_clean(action?['call_id']) == cleanCallId) {
      await clearAction();
    }
  }

  Future<bool> wasActionHandled({
    required String callId,
    required PendingCallKitAction action,
  }) async {
    final cleanCallId = _clean(callId);
    if (cleanCallId == null) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final handled = _readHandledActions(prefs);
    final changed = _purgeExpiredHandledActions(handled);
    if (changed) {
      await _writeHandledActions(prefs, handled);
    }

    return handled.containsKey(_actionSignature(cleanCallId, action));
  }

  Future<void> markActionHandled({
    required String callId,
    required PendingCallKitAction action,
  }) async {
    final cleanCallId = _clean(callId);
    if (cleanCallId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final handled = _readHandledActions(prefs);
    _purgeExpiredHandledActions(handled);
    handled[_actionSignature(cleanCallId, action)] =
        DateTime.now().millisecondsSinceEpoch;
    await _writeHandledActions(prefs, handled);
  }

  Future<void> clearCallActions(String callId) async {
    final cleanCallId = _clean(callId);
    if (cleanCallId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final handled = _readHandledActions(prefs);
    handled.removeWhere(
      (signature, _) => signature.startsWith('$cleanCallId:'),
    );
    await _writeHandledActions(prefs, handled);
    await clearActionIfMatches(cleanCallId);
  }

  Map<String, dynamic>? _decodeMap(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map<Object?, Object?>) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Map<String, int> _readHandledActions(SharedPreferences prefs) {
    final decoded = _decodeMap(prefs.getString(handledActionsKey));
    if (decoded == null) return <String, int>{};

    final result = <String, int>{};
    for (final entry in decoded.entries) {
      final timestamp = switch (entry.value) {
        final int value => value,
        final String value => int.tryParse(value),
        _ => null,
      };
      if (timestamp != null) {
        result[entry.key] = timestamp;
      }
    }
    return result;
  }

  Future<void> _writeHandledActions(
    SharedPreferences prefs,
    Map<String, int> handled,
  ) async {
    if (handled.isEmpty) {
      await prefs.remove(handledActionsKey);
      return;
    }
    await prefs.setString(handledActionsKey, jsonEncode(handled));
  }

  bool _purgeExpiredHandledActions(Map<String, int> handled) {
    final cutoff = DateTime.now().subtract(handledActionRetention);
    final before = handled.length;
    handled.removeWhere(
      (_, timestamp) =>
          DateTime.fromMillisecondsSinceEpoch(timestamp).isBefore(cutoff),
    );
    return handled.length != before;
  }

  String _actionSignature(String callId, PendingCallKitAction action) {
    return '$callId:${action.name}';
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
