import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';

class CallFilterUtils {
  static List<CallLog> apply({
    required List<CallLog> calls,
    required String query,
    required String filter,
  }) {
    final q = query.trim().toLowerCase();

    return calls.where((call) {
      final matchesSearch =
          q.isEmpty || call.displayName.toLowerCase().contains(q);

      final matchesFilter = switch (filter) {
        "missed" => call.isMissed || call.status == "cancelled",
        "incoming" =>
          call.direction == "incoming" &&
              !call.isMissed &&
              call.status != "cancelled",

        "outgoing" => call.direction == "outgoing",
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }
}
