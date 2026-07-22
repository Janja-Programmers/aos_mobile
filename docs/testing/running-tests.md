# Running Tests

## Foundation

```bash
dart format --output=none --set-exit-if-changed test
flutter analyze
flutter test test/widget_test.dart test/helpers test/fakes test/core
flutter test test/widget_test.dart test/helpers test/fakes test/core --coverage
```

## Feature

```bash
dart format <changed Dart files>
flutter analyze
flutter test test/features/<feature>
flutter test test/features/<feature> --coverage
```

When shared production or shared test files change, run their tests and preferably the complete suite:

```bash
flutter test
```

## Environment failures

Report missing Flutter/Dart SDKs, unavailable platform toolchains, dependency resolution failures, or plugin limitations explicitly. Do not convert a blocked command into a claimed success.
