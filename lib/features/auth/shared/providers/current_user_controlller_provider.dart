import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';

final currentUserControllerProvider = Provider.family<bool, String>((
  ref,
  sellerId,
) {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null) return false;

  return user.email == sellerId;
});
