# Profile Editing

## Implemented fields

The name/bio sheet edits:

- `full_name` (backend alias of canonical `display_name`)
- `bio`

Avatar remains a deliberately separate UI flow. Replacement sends only `avatar_media_id`; removal sends only `remove_avatar=true` after the existing media workflow.

## Backend patch semantics

`update_profile` is POST-only but applies partial profile changes. Every editable field is optional at request level; the backend requires at least one supported field. Fields not supplied are not changed.

The frontend therefore sends only values that changed. If only name changes, bio is omitted. If only bio changes, name is omitted. Unchanged normalized values do not trigger a profile-update request.

## Prefill

Edit actions are unavailable until the authoritative `get_profile` payload has loaded. `ProfileEditSheet` then seeds name and bio once from that payload.

An explicitly empty backend bio is authoritative and must remain empty; it must not fall back to stale authenticated-user state. The same rule applies to a cleared avatar: backend-present empty avatar fields mean no avatar and must not fall back to navigation/auth seeds.

## Validation and normalization

`ProfileUpdateRequest` mirrors backend constraints:

- full name: required when supplied, 2–80 characters
- bio: optional, maximum 500 trimmed characters
- repeated full-name whitespace is collapsed
- repeated spaces/tabs and excessive blank lines in bio are normalized

Backend validation remains authoritative.

## Response/state synchronization

A successful `update_profile` returns the complete private profile. The frontend feeds that backend snapshot into `AuthController.setUserFromMap`, closes the editor, and invalidates account/profile state through the existing caller flow. It does not construct a merged profile from local form values.

## Regression coverage

Tests cover:

- explicit empty bio prefill without stale auth fallback
- name-only update omitting bio
- bio-only update omitting name
- normalized no-op save issuing no update request
- existing duplicate-submit protection
- existing avatar-media and remove-avatar request contracts

## Frappe RPC transport

Profile reads continue through the existing v1 method endpoint. Profile mutations call the same whitelisted `aos.api.v1.accounts.update_profile` backend method through Frappe RPC v2 (`/api/v2/method/...`). Frappe v1 injects its routing `cmd` value into `frappe.form_dict`; the account backend deliberately rejects unknown profile fields, so v2 is required to keep framework routing metadata out of the strict partial-update payload. The AOS backend method, auth, validation, and field contract are unchanged.

Frappe v2 wraps custom method results under `data`; `AccountsApi.updateProfile` normalizes that envelope back to the AOS `{ok,message,data,error}` shape. Its profile-update error path also recognizes nested v2 AOS errors so stable backend IDs remain available without changing global Dio behavior.

## Avatar chooser UX

Avatar acquisition remains separate from the name/bio edit form. Tapping the own-profile avatar opens a centered modal dialog with gallery, camera, and (when an avatar exists) remove actions. It must not use a bottom sheet. The selected action still uses the shared media acquisition/upload contract and sends only `avatar_media_id` or `remove_avatar` to `update_profile`.
