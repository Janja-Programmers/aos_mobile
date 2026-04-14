import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';

class CallFilterUtils {
  static List<CallLog> apply({
    required List<CallLog> calls,
    required String query,
    required String filter,
  }) {
    final q = query.toLowerCase();

    return calls.where((call) {
      final matchesSearch = call.displayName.toLowerCase().contains(q);

      final matchesFilter = switch (filter) {
        "missed" => call.isMissed,
        "incoming" => call.direction == "incoming",
        "outgoing" => call.direction == "outgoing",
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }
}
