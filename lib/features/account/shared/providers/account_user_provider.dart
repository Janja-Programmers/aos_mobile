import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';

final currentUserProvider = Provider<String?>((ref) {
  final accountState = ref.watch(accountsControllerProvider);
  final profile = accountState.profile;

  if (profile.isEmpty) return null;

  // 🔥 Adjust this key based on your backend
  return profile['email']?.toString();
});
