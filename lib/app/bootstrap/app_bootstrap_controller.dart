import 'dart:async';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final appBootstrapControllerProvider =
    StateNotifierProvider<AppBootstrapController, AppBootstrapState>((ref) {
      final storage = ref.watch(onboardingStorageProvider);
      final media = ref.watch(mediaAcquisitionServiceProvider);
      return AppBootstrapController(storage, media);
    });

/// Read-only state provider (for UI & router)
final appBootstrapProvider = Provider<AppBootstrapState>((ref) {
  return ref.watch(appBootstrapControllerProvider);
});

class AppBootstrapController extends StateNotifier<AppBootstrapState> {
  AppBootstrapController(this._storage, this._media)
    : super(AppBootstrapState.initial());

  final OnboardingStorage _storage;
  final MediaLifecycleInitializable _media;

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
      // Start Android picker lost-result recovery at app startup. This is
      // intentionally non-blocking; every picker call also awaits the same
      // idempotent initialization future before opening an external picker.
      unawaited(_initializeMediaLifecycle());

      final completed = _storage.isOnboardingComplete();

      state = state.copyWith(isReady: true, onboardingCompleted: completed);

      _hasInitialized = true;
    } finally {
      _initializeFuture = null;
    }
  }

  Future<void> _initializeMediaLifecycle() async {
    try {
      await _media.initialize();
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'Media lifecycle initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
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
