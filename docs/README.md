# AOS Frontend Documentation and Test Foundation

This directory is the shared maintenance foundation for the Africa Online Stores (AOS) Flutter frontend. It documents the application-wide architecture and defines the reusable test conventions that feature deliveries must use.

## Scope

This foundation covers cross-cutting behavior that every feature depends on:

- application bootstrap and root lifecycle;
- Riverpod dependency injection and state ownership;
- GoRouter route composition and guards;
- Dio networking, Frappe response envelopes, and failure mapping;
- authentication and session persistence;
- shared preferences, secure storage, and feature-local caches;
- theme and localization setup;
- media, realtime, notification, map, and LiveKit integration boundaries;
- shared test harnesses, fixtures, fakes, and validation policy.

Feature-specific API contracts and business rules belong under `docs/features/<feature>/` in later focused deliveries.

## Applying this ZIP

Overlay the contents of this package onto the Flutter project root. The package intentionally contains only `docs/`, `test/`, and the foundation reports. It does not contain the full frontend or unrelated production files.

The included `test/widget_test.dart` replaces the generated counter sample that currently does not compile. Future feature tests should import `test/helpers/test_harness.dart` instead of creating new application pumps, fixture loaders, or Riverpod container factories.

## Documentation map

- [`architecture/`](architecture/README.md): runtime architecture and cross-cutting data flow.
- [`development/`](development/getting-started.md): contribution and extension guidance.
- [`testing/`](testing/README.md): test strategy, structure, and execution.
- [`features/`](features/README.md): required structure for incremental feature documentation.

## Foundation status

See:

- `FOUNDATION_IMPLEMENTATION_REPORT.md`
- `FOUNDATION_VALIDATION_RESULTS.md`
- `FOUNDATION_MANIFEST.md`
