import 'dart:async';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  bool _hasInitialized = false;
  Future<void>? _initializeFuture;

  // -----------------------------
  // Initialize app bootstrap
  // -----------------------------
  Future<void> initialize() {
    if (_hasInitialized) {
      appLogger.i('[App] Bootstrap ignored: already initialized');
      return Future.value();
    }

    final existing = _initializeFuture;
    if (existing != null) {
      appLogger.i('[App] Bootstrap ignored: already initializing');
      return existing;
    }

    _initializeFuture = _initialize();

    return _initializeFuture!;
  }

  Future<void> _initialize() async {
    appLogger.i('[App] Bootstrapping...');

    try {
      final completed = _storage.isOnboardingComplete();

      state = state.copyWith(isReady: true, onboardingCompleted: completed);

      _hasInitialized = true;
    } finally {
      _initializeFuture = null;
    }
  }

  // -----------------------------
  // Mark onboarding complete
  // -----------------------------
  Future<void> completeOnboarding() async {
    await _storage.markOnboardingComplete();

    state = state.copyWith(onboardingCompleted: true);
  }

  void deferOnboardingForSession() {
    state = state.copyWith(onboardingCompleted: true);
  }

  // -----------------------------
  // Reset onboarding (for debug / logout cases)
  // -----------------------------
  Future<void> resetOnboarding() async {
    await _storage.clearAll();

    _hasInitialized = false;
    _initializeFuture = null;

    state = state.copyWith(isReady: true, onboardingCompleted: false);
  }
}
