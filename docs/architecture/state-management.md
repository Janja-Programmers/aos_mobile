# State Management

## Riverpod usage

The project uses `flutter_riverpod` 3.2.1 and also imports `flutter_riverpod/legacy.dart` for `StateNotifierProvider` and `StateNotifier` implementations. Approximately one hundred production files declare or consume providers.

Provider styles in active use include:

- `Provider` for services, repositories, derived state, and listeners;
- `StateNotifierProvider`, including families and auto-dispose variants;
- `AsyncNotifierProvider` for asynchronous stateful flows;
- `FutureProvider`, including family and auto-dispose variants;
- `StreamProvider` for realtime/media flows where applicable.

## Dependency injection

Providers are the primary override seam. Shared tests must construct isolated `ProviderContainer` instances or wrap widgets in a `ProviderScope` with explicit overrides. Global mutable singletons and platform plugins should be hidden behind existing providers whenever a provider already exists.

Two providers require startup overrides in production:

- `themeModeProvider`;
- `onboardingStorageProvider`.

Tests that build widgets depending on either provider must supply equivalents or use the shared pump harness where sufficient.

## Lifecycle and disposal

Production code uses `ref.onDispose`, auto-dispose providers, `ProviderSubscription.close`, stream cancellation, and service disposal in several areas. Tests must dispose every manually created container and verify cleanup for features that own subscriptions, media tracks, timers, controllers, or sockets.

## Root listeners

Root-level `ref.watch` and `ref.listenManual` calls intentionally activate global behavior:

- authentication drives realtime and notification lifecycle;
- call socket listeners process incoming signaling;
- notification realtime listeners keep notification state synchronized;
- Shorts upload listeners route upload progress/completion;
- CallKit and Live navigation listeners coordinate external events with routes.

These side-effect providers should not be activated in small unit/widget tests unless the behavior under test requires them.

## Testing rule

A feature test should override the narrowest dependency that provides a deterministic seam:

1. repository interface where available;
2. API provider when controllers consume APIs directly;
3. storage or platform service provider;
4. transport adapter for API contract tests.

Do not create a second dependency injection system for tests.
