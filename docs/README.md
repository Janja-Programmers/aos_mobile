# AOS Frontend Documentation

This directory documents the cross-cutting Flutter architecture and feature
contracts used by the Africa Online Stores frontend.

## Documentation map

- [`architecture/`](architecture/README.md): runtime ownership, navigation,
  networking, persistence, lifecycle, privacy, and integration boundaries.
- [`architecture/app-lock-prerequisites.md`](architecture/app-lock-prerequisites.md):
  verified session-restoration, lifecycle, privacy-cover, and protected-navigation
  foundation for a later native app-lock iteration.
- [`development/`](development/getting-started.md): local setup and contribution
  guidance.
- [`testing/`](testing/README.md): shared test conventions and validation policy.
- [`features/`](features/README.md): feature-specific contracts, tests, and
  limitations.

Backend behavior remains authoritative in `backend.zip`; frontend documents
must not redefine backend contracts.

## Security

- [Native application lock](features/native-app-lock.md)

- [Shorts creation and publishing](features/shorts-creation-publishing.md)

## Feature guides

- [Localization, onboarding, and active preferences](frontend/localization_onboarding.md)
- [AOS Live](features/live/README.md)
- [AOS Calls](features/calls/README.md)
  - [Calls physical device test matrix](features/calls/device-test-matrix.md)
  - [Calls implementation validation](features/calls/implementation-validation.md)
- [Connect Chat](features/connect-chat.md)
