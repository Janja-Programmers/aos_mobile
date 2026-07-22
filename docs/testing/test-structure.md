# Test Structure

```text
test/
├── core/                     # Shared infrastructure behavior
├── helpers/                  # Reusable harnesses only
├── fakes/                    # Reusable deterministic implementations
├── fixtures/
│   └── shared/               # Cross-feature sanitized payloads/builders
├── test_config/              # Non-secret constants
├── features/<feature>/       # Focused feature tests
└── regression/cross_feature/ # Final integration phase
```

Feature directories should mirror only the production layers that have tests. Do not create empty `data/`, `application/`, or `presentation/` folders to satisfy a template.

## Naming

- Files end in `_test.dart`.
- Test names state the condition and expected behavior.
- Group by public behavior or method, not private implementation.
- Regression names should identify the user-visible or state defect prevented.

## Shared versus local

A fixture/helper belongs in shared infrastructure only when at least two feature areas can use it. Otherwise keep it in `test/features/<feature>/fixtures` or the relevant feature test directory.
