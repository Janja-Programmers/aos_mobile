# Adding a Feature

1. Identify the user-facing scope and cross-feature dependencies.
2. Reuse core API, routing, theme, storage, media, and error abstractions.
3. Define domain/request/response models with defensive parsing consistent with the backend payload represented in the frontend.
4. Put orchestration in a controller/notifier/repository rather than widget builds.
5. Add provider override seams for remote, storage, time, or platform dependencies.
6. Add route constants and a feature route module where appropriate.
7. Document loading, empty, error, permission, ownership, privacy, and success states.
8. Add model, API/repository, controller/provider, widget, navigation, form, and regression tests as applicable.
9. Run format, analyze, focused tests, coverage, and relevant cross-feature tests.

Do not introduce a parallel architecture or duplicate shared test utilities. When an existing feature has an established pattern, preserve it unless a verified defect requires a minimal change.
