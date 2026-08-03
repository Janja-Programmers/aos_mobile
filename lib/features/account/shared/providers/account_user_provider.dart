import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authenticated Frappe User identifier used by existing non-Chat features.
///
/// Calls store backend User IDs/emails, so this provider intentionally
/// preserves its original meaning. Chat ownership must use
/// [currentCanonicalAccountIdProvider] instead.
final currentUserProvider = Provider<String?>((ref) {
  final auth = ref.watch(authControllerProvider);
  if (auth is AuthAuthenticated) {
    final authEmail = auth.user.email.trim().toLowerCase();
    if (authEmail.isNotEmpty) return authEmail;
  }

  final accountState = ref.watch(accountsControllerProvider);
  final profile = accountState.profile;

  final profileEmail = profile['email']?.toString().trim().toLowerCase();
  if (profileEmail != null && profileEmail.isNotEmpty) return profileEmail;

  return null;
});

/// Canonical public account ID used by Chat sender/participant payloads.
///
/// This value is kept separate from email, username, display name, avatar, and
/// seller identity. It is the only frontend identity allowed for message
/// ownership/alignment and account-scoped Chat storage.
final currentCanonicalAccountIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authControllerProvider);
  if (auth is! AuthAuthenticated) return null;
  return _canonicalAccountId(auth.user.accountId);
});

String? _canonicalAccountId(String? value) {
  final clean = value?.trim().toUpperCase() ?? '';
  if (!clean.startsWith('ACC-')) return null;
  return clean;
}
