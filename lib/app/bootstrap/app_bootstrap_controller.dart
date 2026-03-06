import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';

final appBootstrapControllerProvider =
    StateNotifierProvider<AppBootstrapController, AppBootstrapState>((ref) {
      final storage = ref.watch(onboardingStorageProvider);
      return AppBootstrapController(storage);
    });

/// Read-only state provider (for UI & router)
final appBootstrapProvider = Provider<AppBootstrapState>((ref) {
  return ref.watch(appBootstrapControllerProvider);
});

class AppBootstrapController extends StateNotifier<AppBootstrapState> {
  AppBootstrapController(this._storage) : super(AppBootstrapState.initial());

  final OnboardingStorage _storage;

  final _controller = StreamController<AppBootstrapState>.broadcast();

  @override
  Stream<AppBootstrapState> get stream => _controller.stream;

  Future<void> initialize() async {
    final completed = _storage.isOnboardingComplete();

    state = state.copyWith(isReady: true, onboardingCompleted: completed);

    _controller.add(state);
  }

  Future<void> completeOnboarding() async {
    await _storage.markOnboardingComplete();

    state = state.copyWith(onboardingCompleted: true);

    _controller.add(state);
  }

  Future<void> resetOnboarding() async {
    await _storage.clear();

    state = state.copyWith(onboardingCompleted: false);

    _controller.add(state);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
