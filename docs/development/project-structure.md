# Project Structure

```text
lib/
├── app/                 # Bootstrap and splash lifecycle
├── core/                # Cross-cutting infrastructure
├── features/            # Feature-oriented production modules
├── l10n/                # ARB and generated localization code
├── shared/              # Reusable UI, types, enums, utilities
├── firebase_options.dart
└── main.dart
```

## Feature organization

Feature depth reflects complexity:

- Small features may use `data/`, `domain/`, `presentation/`, and one controller.
- Larger features use `application/controllers`, `providers`, `state`, repositories, integrations, navigation, and presentation submodules.
- `connect` and `shorts` contain multiple related subfeatures and should be documented/tested by coherent behavioral boundary, not only by top-level folder.

## Documentation and tests

```text
docs/features/<feature>/
test/features/<feature>/
```

Tests should mirror meaningful production layers, but empty directories are prohibited. Shared helpers stay in `test/helpers`, shared fakes in `test/fakes`, and globally reusable sanitized payloads in `test/fixtures/shared`.

## Naming

Use project-relative package imports (`package:africaonlinestores/...`) in Dart. Test-only imports may use the same package imports for production code and relative imports only within `test/` where the analyzer permits; the shared foundation uses package imports consistently where practical.
