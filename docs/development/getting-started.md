# Getting Started

## Toolchain

The uploaded `pubspec.yaml` requires Dart `^3.10.4`. Use a Flutter stable release that bundles a compatible Dart SDK. Confirm with:

```bash
flutter --version
dart --version
```

The project uses generated localizations and platform integrations. A complete checkout must retain Android/iOS Firebase, notification, permission, map, CallKit, and signing configuration outside this focused foundation ZIP.

## Install and generate

```bash
flutter clean
flutter pub get
flutter gen-l10n
```

Run code generation commands only when a feature actually uses a generator configured by the project. Do not add build tooling solely for tests.

## Baseline validation

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Applying incremental deliveries

Each foundation or feature ZIP is an overlay, not a standalone Flutter project. Apply it to the same frontend version it was produced from, review its manifest, and preserve the project-relative paths.

## Environment configuration

Never commit secrets, production credentials, private keys, signed upload URLs, or live session tokens. Test configuration uses `.invalid` domains and in-memory fakes. Production `AppConfig` values remain outside this package.
