# Profile Editing

## Implemented fields

The current sheet edits only:

- `full_name`
- `bio`

The backend also supports avatar fields through the dedicated avatar workflow. Gender, birth date, interests, phone, location, and legal name are not part of this profile-update screen and are not documented as supported here.

## Prefill

`ProfileEditSheet` seeds controllers once from explicit `initialFullName` / `initialBio`, then authenticated user fields as fallback. This preserves an existing profile bio instead of replacing it with an empty controller value.

## Validation and normalization

`ProfileUpdateRequest` mirrors backend constraints:

- full name: required when supplied, 2–80 characters
- bio: optional, maximum 300 trimmed characters
- repeated full-name whitespace is collapsed
- repeated spaces/tabs and excessive blank lines in bio are normalized

Backend validation remains authoritative.

## Request and response

`AccountsApi.updateProfile` POSTs only supported keys. The returned profile data is passed to `AuthController.setUserFromMap`, the sheet closes, and the caller invalidates account/profile state.

The save button uses `_saving` to prevent duplicate submissions. Backend/Dio failures end loading and show a safe message without clearing unchanged fields.

## Preserving unchanged data

Nullable request fields are omitted. The sheet submits both displayed fields because they are prefilled with current values. Avatar updates use a separate request containing only `profile_image_media`.

## Extension rule

A new editable field requires all of the following: confirmed backend validator/serializer support, request-model serialization, prefill mapping, validation, regression tests, privacy review, and documentation update. Database fields alone do not establish API support.
