import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:flutter_riverpod/legacy.dart';

class PendingProtectedNavigation {
  const PendingProtectedNavigation({
    required this.accountId,
    required this.requestKey,
    required this.destination,
  });

  final String accountId;
  final String requestKey;
  final ProtectedNavigationDestination destination;
}

class PendingProtectedNavigationStore
    extends StateNotifier<PendingProtectedNavigation?> {
  PendingProtectedNavigationStore() : super(null);

  PendingProtectedNavigation? get pending => state;

  void replace(PendingProtectedNavigation request) {
    state = request;
  }

  void clear() {
    state = null;
  }
}
