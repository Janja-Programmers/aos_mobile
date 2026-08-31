# Review reporting

## Backend contract

Review abuse reports use `POST /api/method/aos.api.v1.reviews.report_review` with the authenticated Frappe session.

Request fields:

- `review` (canonical review ID)
- `reason` (active central AOS Report Reason ID)
- `details` (optional, maximum 500 characters)

The backend remains authoritative for approval visibility, self-report prevention, duplicate/idempotent reports, permissions, validation, report status, rate limits, and error codes.

## Frontend ownership

`ReviewCard` exposes a small flag action. Both ad-detail review previews and the all-reviews screen open the same review report sheet.

The sheet reuses the existing report-reason API/provider and report reason tile UI. Review-specific submission is owned by `ReviewApi.reportReview`.

The UI provides loading, empty, error/retry, submitting, keyboard-aware, and success/error states. Duplicate taps are blocked while submission is in progress.

## Validation

Run:

```bash
dart format lib/features/reviews test/features/reviews
dart analyze
flutter test test/features/reviews/presentation/review_card_report_test.dart
flutter test
```
