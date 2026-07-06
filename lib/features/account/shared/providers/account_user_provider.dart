import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = Provider<String?>((ref) {
  final auth = ref.watch(authControllerProvider);
  if (auth is AuthAuthenticated) {
    final authEmail = auth.user.email.trim().toLowerCase();
    if (authEmail.isNotEmpty) {
      return authEmail;
    }
  }

  final accountState = ref.watch(accountsControllerProvider);
  final profile = accountState.profile;

  final profileEmail = profile['email']?.toString().trim().toLowerCase();
  if (profileEmail != null && profileEmail.isNotEmpty) {
    return profileEmail;
  }

  return null;
});
