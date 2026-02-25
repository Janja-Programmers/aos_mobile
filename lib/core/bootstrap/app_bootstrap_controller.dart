import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/core/utils/app_flags.dart';

final appBootstrapProvider =
    AsyncNotifierProvider<AppBootstrapController, AppBootstrapState>(
      AppBootstrapController.new,
    );

class AppBootstrapController extends AsyncNotifier<AppBootstrapState> {
  @override
  Future<AppBootstrapState> build() async {
    final completed = await AppFlags.isOnboardingCompleted();

    return AppBootstrapState(isReady: true, onboardingCompleted: completed);
  }

  Future<void> markOnboardingCompleted() async {
    await AppFlags.setOnboardingCompleted();

    state = const AsyncData(
      AppBootstrapState(isReady: true, onboardingCompleted: true),
    );
  }
}
