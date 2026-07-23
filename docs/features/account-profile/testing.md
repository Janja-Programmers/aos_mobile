# Testing

## Scope and infrastructure

Tests are Flutter unit/widget tests. They reuse:

- shared `createTestContainer` and `pumpTestApp`
- shared fixture loader with feature-local base directory
- shared `RecordingHttpClientAdapter`
- shared fake session storage
- accepted Authentication/Session controller/provider overrides
- sanitized, backend-shaped JSON fixtures

No test contacts Frappe, staging, OAuth, camera, gallery, LiveKit, chat transport, or a media server.

## Traceability

| Behavior | Level | Test location |
| --- | --- | --- |
| Exact profile update fields/limits | Model/API | `data/models/profile_update_request_test.dart`, `data/api/accounts_api_test.dart` |
| Backend profile parsing/privacy flags | Model | `data/models/account_profile_snapshot_test.dart` |
| Relationship states/block fields/non-negative counts | Model | `data/models/social_relationship_model_test.dart` |
| Relationship status GET and list parameters | API | `data/api/social_api_test.dart` |
| Delete/restore request contracts | API | `data/api/account_lifecycle_api_test.dart` |
| Account loading/failure/refresh/deduplication | Controller | `application/controllers/accounts_controller_test.dart` |
| Relationship mutation success/failure retention | Controller | `application/controllers/social_relationship_controller_test.dart` |
| Logout clears account provider | Provider | `application/providers/account_provider_auth_sync_test.dart` |
| Verified banner hidden; unverified sheet | Widget | `presentation/widgets/account_screen_test.dart` |
| Header fallback and badge | Widget | `presentation/widgets/account_header_card_test.dart` |
| Edit prefill/validation/duplicate save | Widget | `presentation/forms/profile_edit_sheet_test.dart` |
| Own/public/deleted/blocked privacy and tabs | Widget | `presentation/widgets/profile_screen_test.dart` |
| Routes and query arguments | Navigation | `navigation/account_profile_routes_test.dart` |
| Historical contract/privacy regressions | Regression | `regression/account_profile_contract_regression_test.dart` |

## Coverage priorities

Priority is given to contract fields/methods, owner/public separation, blocked/deleted behavior, update preservation, account/logout synchronization, count humanization, and navigation wiring. Real platform media behavior and cross-feature destination internals are excluded.

## Commands

```bash
dart format lib/features/account lib/features/social test/features/account_profile
flutter analyze
flutter test test/features/authentication_session
flutter test test/features/account_profile
flutter test test/features/account_profile --coverage
flutter test
```

See `FEATURE_TEST_RESULTS.md` for what was executable in the delivery environment.
