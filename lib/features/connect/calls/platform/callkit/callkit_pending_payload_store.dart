import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CallKitPendingPayloadStore {
  static const String key = 'pending_incoming_call_payload';

  const CallKitPendingPayloadStore();

  Future<void> save(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return null;
    }

    return null;
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

    final pendingCallId = _clean(payload['call_id'] ?? payload['id']);
    if (pendingCallId == cleanCallId) {
      await clear();
    }
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
