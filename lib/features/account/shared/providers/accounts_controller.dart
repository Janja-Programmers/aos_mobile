import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/account/domain/account_state.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final accountsControllerProvider =
    StateNotifierProvider<AccountsController, AccountState>((ref) {
      final AuthState authState = ref.watch(authControllerProvider);
      final AccountsApi api = ref.watch(accountsApiProvider);
      final AccountsController controller = AccountsController(api: api);

      if (authState is AuthAuthenticated) {
        unawaited(controller.loadProfile());
      }

      return controller;
    });

class AccountsController extends StateNotifier<AccountState> {
  AccountsController({required AccountsApi api})
    : _api = api,
      super(const AccountState());

  final AccountsApi _api;

  Future<Either<Failure, Map<String, dynamic>>> loadProfile() async {
    if (state.loading) {
      return Either.right(state.profile);
    }

    state = state.copyWith(loading: true, clearError: true);

    final res = await _api.getProfile();

    if (res.isLeft) {
      final f = res.leftOrNull ?? const Failure('Failed to load profile.');
      state = state.copyWith(loading: false, errorMessage: f.message);
      return Either.left(f);
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;

    if (!ok) {
      final f = Failure(
        (payload['message'] ?? 'Failed to load profile.').toString(),
      );
      state = state.copyWith(loading: false, errorMessage: f.message);
      return Either.left(f);
    }

    final data = asJsonMap(payload['data']);

    state = state.copyWith(loading: false, profile: data, clearError: true);
    return Either.right(data);
  }

  Future<Either<Failure, String>> updateProfile({
    String? fullName,
    String? userImage,
    String? bio,
  }) async {
    state = state.copyWith(clearError: true);

    final res = await _api.updateProfile(
      fullName: fullName,
      userImage: userImage,
      bio: bio,
    );

    if (res.isLeft) {
      final f = res.leftOrNull ?? const Failure('Failed to update profile.');
      state = state.copyWith(errorMessage: f.message);
      return Either.left(f);
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg =
        (payload['message'] ?? (ok ? 'Profile updated.' : 'Update failed.'))
            .toString();

    if (!ok) {
      final f = Failure(msg);
      state = state.copyWith(errorMessage: f.message);
      return Either.left(f);
    }

    // Refresh local profile after update
    await loadProfile();
    return Either.right(msg);
  }

  void clearError() => state = state.copyWith(clearError: true);
}
