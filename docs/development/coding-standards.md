# Coding Standards

`analysis_options.yaml` is authoritative. New documentation/test work must not weaken analyzer settings or suppress valid findings.

## Key enforced rules

- strict casts, strict inference, and strict raw types;
- package imports instead of relative library imports;
- required return types and public API annotations;
- final locals/fields where applicable;
- no `print`;
- awaited or explicitly `unawaited` futures;
- build-context async safety;
- subscription and sink cleanup;
- const construction where possible;
- trailing commas;
- single quotes;
- Flutter widget constructor keys;
- no broad production refactors hidden inside test work.

## Test code

Tests are production maintenance code. They must be formatted, analyzed, deterministic, and readable. Use explicit types where strict inference would otherwise produce `dynamic`. Avoid arbitrary sleeps; drive state through futures, provider listeners, or `WidgetTester.pump`/`pumpAndSettle` with bounded behavior.

## Comments

Explain intent, risk, or a non-obvious contract. Do not narrate obvious statements. Regression tests should describe the defect they prevent in the test name or a concise comment.
