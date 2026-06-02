import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';

class CallFilterUtils {
  static List<CallLog> apply({
    required List<CallLog> calls,
    required String query,
    required String filter,
  }) {
    final q = query.trim().toLowerCase();
    final normalizedFilter = filter.trim().toLowerCase();

    return calls.where((call) {
      final displayName = call.displayName.trim().toLowerCase();

      final matchesSearch = q.isEmpty || displayName.contains(q);

      final direction = call.direction.trim().toLowerCase();
      final status = call.status.trim().toLowerCase();

      final isMissed = _isEffectivelyMissed(
        call: call,
        direction: direction,
        status: status,
      );

      final matchesFilter = switch (normalizedFilter) {
        'missed' => isMissed,

        // Missed incoming calls should not also appear under Incoming.
        'incoming' => direction == 'incoming' && !isMissed,

        // Outgoing should mean calls made by me.
        // If an outgoing call was cancelled by me, it can still remain outgoing.
        'outgoing' => direction == 'outgoing',

        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  static bool _isEffectivelyMissed({
    required CallLog call,
    required String direction,
    required String status,
  }) {
    if (call.isMissed) return true;

    if (status == 'missed') return true;

    // Backend change: cancelled incoming calls should behave like missed calls
    // for the receiver. But do not treat every cancelled outgoing call as missed.
    if (direction == 'incoming' && status == 'cancelled') {
      return true;
    }

    return false;
  }
}
