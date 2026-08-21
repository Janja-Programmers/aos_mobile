# Live Testing and Validation

## Automated test map

| Test path | Coverage |
| --- | --- |
| `domain/live_mapper_test.dart` | Canonical bootstrap hydration, aggregates/capabilities, scalar compatibility, incomplete/mismatched credential rejection |
| `domain/live_reaction_test.dart` | Exact reaction enum contract and unsupported-type rejection |
| `data/live_api_test.dart` | Start/join payloads, optional cover omission, session reuse, malformed envelope handling, reactions, Chat sharing |
| `data/live_comments_api_test.dart` | Comment fields/idempotency and deleted-history filtering |
| `data/live_cohost_api_test.dart` | Opaque identity invitation, response normalization, private co-host token mapping |
| `application/live_manager_test.dart` | Duplicate joins, stale Live switching, reaction deduplication, repeated-submit lock, tracked end cleanup |
| `comments/live_comments_controller_test.dart` | Stale fetch rejection, realtime deduplication, deletion tombstones, duplicate submit suppression, optimistic rollback |
| `presentation/go_live_screen_test.dart` | Profile title/avatar defaults, editable 140-character details sheet, missing-cover gating, edited-title preservation, 320px/200%-text scrolling, and button-token icon colors |
| `presentation/live_right_actions_test.dart` | Share action, complete long-press picker, small-screen/200% text overflow guard |
| `presentation/live_top_bar_test.dart` | Single reaction aggregate, viewer count, host/viewer actions, Follow colors/action, small-screen/200% text overflow guard |
| `regression/live_source_contract_test.dart` | Retired listeners absent, one coordinator, no comment polling, Feed tracked join/leave ownership, physical-position camera flip, explicit host follow and refresh |
| `account_profile/data/api/social_api_test.dart` | Exact idempotent `action=follow` request contract used by Live |

Fixtures contain only nonfunctional tokens, IDs, and `.invalid` hosts. Tests do
not contact the backend or LiveKit.

## Validation commands

Run from the Flutter project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze .
flutter test test/features/live
flutter test
flutter build apk --debug
```

`dart analyze .` is intentional: it detects obsolete Dart files that remain on
disk even if nothing imports them.

## Device validation matrix

Automated tests cannot validate native permissions, actual camera/microphone
tracks, audio routing, socket transport, or LiveKit credentials. Revalidate at
least Android foreground/background and iOS foreground when available.

| ID | Short steps | Expected result | Evidence if it fails |
| --- | --- | --- | --- |
| LIVE-01 | Open Go Live, deny camera | Start is blocked safely; no backend Live or leaked preview track | Screen recording, permission state, sanitized logs |
| LIVE-02 | Open Go Live with a profile name/avatar, then tap the details card | Current name and avatar are prefilled; the keyboard-safe sheet permits title and cover changes; title counter is `/140` | Recording, profile payload fields, screenshots |
| LIVE-03 | Clear the title, test an account without an avatar, then select a cover and flip the camera twice | Save/Go Live stay disabled until title and cover are ready; camera changes front→back→front; one Live starts with the prepared track | Recording and sanitized start/upload/LiveKit timeline |
| LIVE-04 | Repeatedly tap Start on slow network | One backend start and one room join | Network trace with credentials redacted |
| LIVE-05 | Viewer opens Feed Live tab and vertically scrolls | Visible eligible Live auto-plays; previous session leaves before next joins | Recording plus sanitized join/leave IDs |
| LIVE-06 | Tap Feed Live into full screen | Existing room/session is reused; no playback reset or duplicate viewer count | Recording and request counts |
| LIVE-07 | Open a host not followed, then tap Follow repeatedly | One explicit follow request; success feedback appears; button disappears; it is absent when already following | Recording and sanitized request body/status |
| LIVE-08 | Tap reaction, then long-press and choose each type | Correct emoji appears; total badge increments once per canonical reaction | Host/viewer recording and event IDs |
| LIVE-09 | Host and viewer exchange comments | Both see each committed comment once; reconnect restores history | Two-device recording and sanitized events |
| LIVE-10 | Delete own comment; host deletes viewer comment | Comment disappears for all and does not return after reconnect | Two-device recording and request/event IDs |
| LIVE-11 | Viewer requests co-host; host accepts | Viewer receives token, publishes, activates, and both devices show co-host | Two-device recording and sanitized workflow states |
| LIVE-12 | Host invites a visible viewer | Invite uses opaque participant identity; intended viewer alone can respond | Sanitized request body and both screens |
| LIVE-13 | End/remove co-host during slow transition | No duplicate publisher; candidate returns to viewer or exits safely | Two-device recording and ordered states |
| LIVE-14 | Host ends Live while viewer reconnects | All devices reach ended state; tracks and tracked sessions clean up | Recording and sanitized end/leave timeline |
| LIVE-15 | Disable network during active Live, then restore | Reconnecting state appears; room/comments/co-host state reconcile without duplicates | Recording and socket/recovery logs |
| LIVE-16 | Test 320px width, landscape, keyboard open, 200% text | Controls remain reachable; no overflow, clipping, or keyboard-covered input | Screenshot plus any Flutter overflow output |
| LIVE-17 | Test TalkBack/VoiceOver and RTL locale | Controls have meaningful labels/order; reaction picker and end/leave are reachable | Accessibility recording and locale |
| LIVE-18 | Open ended, blocked, or inaccessible deep link | No token/media leak; safe unavailable/ended state and route away | Screenshot, stable error code, redacted request |

Use `PASS`, `PASS — UPDATE REQUIRED`, `FAIL`, `UNSTABLE`, `BLOCKED`, or
`NOT APPLICABLE` when recording results.

## Failure evidence rules

Never include:

- LiveKit tokens or WebSocket query credentials;
- session cookies;
- private viewer session IDs;
- personal email/internal User identifiers;
- unredacted notification or co-host payloads.

Useful evidence includes canonical public `LIVE-*`/message/co-host IDs, stable
backend error code, platform/OS, app lifecycle state, timestamps, expected vs
observed UI, and a short sanitized request/event sequence.

## Known untested boundaries

- real camera flip and device-specific permission recovery;
- speaker/Bluetooth/headset routing;
- process death during an active Live;
- LiveKit publication/subscription quality and reconnect under packet loss;
- multi-device backend concurrency and rate-limit enforcement;
- hosted HTTPS universal/app-link fallback;
- reply UI, cursor history pagination, and full feature-wide localization.
