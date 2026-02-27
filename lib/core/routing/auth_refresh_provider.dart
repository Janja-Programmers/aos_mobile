import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';

final authRefreshProvider = StreamProvider<void>((ref) {
  final ctrl = ref.watch(authControllerProvider.notifier);
  return ctrl.changes;
});
