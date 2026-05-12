import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';

final currentUserProvider = Provider<String?>((ref) {
  final accountState = ref.watch(accountsControllerProvider);
  final profile = accountState.profile;

  if (profile.isEmpty) return null;

  final email = profile['email']?.toString().trim();

  if (email == null || email.isEmpty) return null;

  return email.toLowerCase();
});
