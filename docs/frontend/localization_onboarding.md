# Launch, Onboarding, and Active Preferences

## Ownership

The backend owns locale master data, canonical identifiers, enabled/default
state, guest resolution, account preference validation, authenticated
preference persistence, and stable errors. Flutter does not reproduce those
rules.

Flutter owns presentation, supported localization assets, responsive layout,
accessibility, retry/offline UI, atomic local persistence, and the active
runtime preference repository.

## Runtime single source of truth

`UserPreferenceController` exposes the only active Flutter preference snapshot.
Persistence, authentication, and backend context use its canonical `countryId`,
`currencyId`, and `languageId` getters. Existing presentation consumers that
need ISO/display codes use `countryCode`, `currencyCode`, and `languageCode`
from the same snapshot; there is still only one runtime read path.

The snapshot also retains typed display metadata:

- canonical backend ID;
- display code;
- display name;
- backend flag;
- representative frontend flag;
- currency symbol;
- enabled/default state;
- resolution source;
- authority and schema version.

`OnboardingStorage` persists this as one JSON value:

```text
aos_active_preference_snapshot_v1
```

A single write prevents mixed country, currency, and language state after
process termination. The onboarding completion flag is written only after a
valid snapshot exists.

## First launch

1. `LocalizationController` loads `get_locale_bundle`.
2. Enabled backend languages are intersected with Flutter ARB locales.
3. It calls `resolve_locale_context` without invented fallback values.
4. The canonical resolved country, currency, and language are validated against
   the usable bundle.
5. `UserPreferenceController` atomically persists the guest snapshot.
6. Onboarding displays the resolved values, including Kenya/KES/English when
   that is what the backend resolver returns.

Duplicate locale loads are coalesced. An older request generation cannot
replace a newer state.

## Offline behavior

A previously valid snapshot is restored locally and remains the runtime source
of truth.

On a first-ever offline launch, Flutter shows the accepted retry/Skip for now
state. Skip is session-only when no valid snapshot exists: it does not persist
fabricated defaults or mark onboarding complete. Relaunching returns to
onboarding until a valid backend-resolved snapshot is saved.

## Independent selections

Language, country, and currency are independent. Selecting one updates and
persists only that selection while preserving the other two values in the same
snapshot.

The Country action **Use current location** restores the country returned by
the initial backend resolver. It does not request GPS permission and does not
change language or currency.

The Currency action **Use country currency** uses the frontend presentation
catalog only after an explicit press. It does not run when country changes. If
the association or enabled currency is unavailable, the action is disabled.

## Frontend-only representative metadata

`LocalePresentationCatalog` contains:

- representative country flags for Flutter-supported languages;
- representative country flags for known currencies;
- explicit ISO-country-to-currency convenience associations.

These values are UI metadata only. They are never sent to the backend and never
replace canonical backend IDs.

Country flags prefer the backend-provided value. Language flags prefer the
backend value and then the representative frontend mapping. Currency flags use
the representative frontend mapping.

## Authentication lifecycle

Registration and first social authentication read canonical IDs from the same
active snapshot.

Password and social login now await persistence of the server-returned account
preference before publishing `AuthAuthenticated`. `/me` is the fallback source
when the login payload lacks usable preferences.

The authenticated backend preference replaces the guest active snapshot. The
last valid guest snapshot is retained internally for logout restoration, but
widgets still have only one active read path.

On logout, the account snapshot is removed from active use and the last valid
guest snapshot is restored. The backend account preference remains durable.

## Authenticated preference updates

The Account Preferences screen submits one canonical backend ID at a time:
`country`, `currency`, or `language`. The request model is typed, so Flutter
cannot append arbitrary preference fields.

The update calls the existing whitelisted
`aos.api.v1.accounts.update_my_preference` method through Frappe RPC v2. This
transport is available in the backend's Frappe 17 runtime and forwards only the
client-supplied method arguments. It avoids RPC v1's internal `cmd` transport
argument reaching the backend's strict unknown-field validation. This changes
only the Frappe transport path; the AOS method, authentication, request field
names, validation, rate limit, stable errors, and response contract remain
backend-owned and unchanged.

After success, Flutter atomically replaces the active authenticated snapshot
with the complete preference object returned by the backend and updates the
authenticated session view. Language and market context consumers therefore
observe the same canonical state without a competing store.

Country locking follows both pieces of authenticated backend state:

- the account is a seller; and
- `preferences.is_country_locked` is true.

Only the Country card becomes read-only. Language and Currency always remain
editable and continue to submit independent partial updates. The client still
handles `COUNTRY_LOCKED` as authoritative if server state changes while the
screen is open.

## Supported UI languages

The current Flutter assets support:

- English (`en`)
- Arabic (`ar`)
- French (`fr`)
- Swahili (`sw`)
- Chinese (`zh`)

Only enabled backend languages whose display code normalizes into this set are
shown during onboarding.

## Responsive and accessibility behavior

Onboarding selection steps use scrollable slivers rather than
`IntrinsicHeight` plus `Spacer`. Actions remain after the content when the
viewport is short, rotated, or enlarged by text scaling.

Picker values may occupy multiple lines. Picker rows constrain long titles and
subtitles, expose a deliberate no-results state, and surface persistence errors
instead of swallowing them.

The accepted splash artwork is unchanged.

## Tests

Focused tests cover:

- canonical locale parsing;
- malformed contract rejection;
- supported-language rendering;
- representative flags;
- country-currency mapping;
- snapshot round trips;
- server ID priority;
- atomic persistence;
- invalid completion prevention;
- legacy restoration;
- independent guest changes;
- RPC v2 preference payloads with no `cmd` field;
- country, currency, and language partial-update response parsing;
- stable backend error preservation;
- seller-only country-lock policy;
- no fabricated onboarding initial state;
- high-text-scale picker layout.

## Local validation

Run from the Flutter project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter build apk --debug
```

Targeted tests:

```bash
flutter test test/features/localization
flutter test test/features/preferences
flutter test test/features/onboarding
flutter test test/shared/components/picker_field_layout_test.dart
```
