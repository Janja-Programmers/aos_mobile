# AOS Live

## Status

The Flutter Live implementation is **hardened but requires device revalidation**.
It now uses one Live domain manager, one realtime coordinator, typed backend
models, serialized room transitions, durable comment recovery, the canonical
one-slot co-host workflow, and the same LiveKit room for Feed preview and the
full-screen experience.

The backend remains immutable and authoritative. These documents describe only
the behavior represented by the current Flutter sources.

## Documentation map

- [API contracts](api-contracts.md)
- [State, lifecycle, and navigation](state-and-lifecycle.md)
- [Realtime, comments, reactions, and co-hosts](realtime-comments-cohosts.md)
- [Testing and validation](testing.md)

## Entry points

| Entry | Behavior |
| --- | --- |
| Go Live | Loads the authenticated account profile, seeds title from `display_name` and cover from the profile avatar when available, exposes both values in the edit-details sheet, and requires only the backend-mandated title before Start |
| Feed → Live tab | Lists active Lives and silently joins the visible eligible item with viewer media disabled |
| Tap visible Live | Reuses the tracked manager/session and opens the full-screen Live route |
| Notification/deep link | Resolves the canonical `LIVE-*` identifier and joins through the backend before showing Live UI |
| Host controls | End, mute/unmute, camera flip, comment, react, share, and co-host management where backend capabilities permit |
| Viewer controls | Follow an unfollowed host, leave, comment, react, share, and request/respond to co-host where backend capabilities permit |

## Authority and trust boundaries

The backend owns:

- canonical Live, account, viewer-session, message, reaction, and co-host IDs;
- Live lifecycle, visibility, account/block policy, permissions, and capability
  flags;
- room names, LiveKit identities, grants, tokens, and token expiry;
- validation, rate limits, idempotency, aggregates, and stable error codes;
- co-host state transitions and the single accepted/active slot;
- persistent comments, reactions, tracking, and chat shares;
- realtime publication after committed mutations.

Flutter owns:

- camera/microphone permission prompts and local track preparation;
- profile-derived Go Live defaults and the editable draft; the cover remains optional exactly as the backend contract specifies;
- LiveKit connect, publish, subscribe, reconnect presentation, and cleanup;
- screen state, navigation, Feed visibility activation, and keyboard-safe UI;
- duplicate-tap suppression and stale async-result rejection;
- scoped realtime ingestion, bounded in-memory event deduplication, and
  reconnect reconciliation;
- presentation-only reaction animation and the native share sheet.

Flutter must not infer permissions from role labels. UI actions use the
backend-provided `viewer_state` capabilities and still treat backend rejection
as authoritative.

The host Follow button is shown only when `viewer_state.can_follow` is true,
`is_following` is false, the viewer is not the host, and `target_user` is
present. It uses the Social endpoint's explicit `action=follow` form so a
repeated or stale request cannot accidentally unfollow. A canonical Live
refresh follows a successful response.

## Architecture and ownership

| Owner | Responsibility |
| --- | --- |
| `LiveManager` | One active Live session, serialized start/join/leave/end transitions, LiveKit coordination, viewer tracking, stale-generation protection, reaction aggregate state |
| `LiveRepository` | Typed throwing boundary over `LiveApi` results |
| `LiveApi` | Exact lifecycle, discovery, tracking, reaction, and chat-share HTTP contracts |
| `LiveMediaService` | Permissions, prepared camera ownership, LiveKit role-specific publication/subscription, local media controls |
| `LiveRealtimeCoordinator` | Sole Live realtime event consumer, ordering, scoping, deduplication, and reconnect recovery |
| `LiveCommentsController` | Comment history, submission lock, realtime merge, delete tombstones, and stale-load protection |
| `LiveCohostController` | Invite/request/response state, token→media→activation sequencing, return-to-viewer recovery |
| `LiveSharingService` | Deduplicated sequential sharing to canonical Chat conversations |
| `SocialRepository` | Idempotent explicit host-follow mutation through the existing Social endpoint |
| `LiveScreen` | Full-screen presentation, duplicate follow-tap lock, success feedback, and intent dispatch only |
| `ShortsFeedTab` | Visible Live selection and background viewer join/leave |

The following retired files must remain absent:

```text
live_signaling_handler.dart
live_realtime_listeners.dart
socket_live_listener.dart
```

They belonged to competing realtime architectures. Adding compatibility
methods to `LiveManager` for these files would restore duplicate event ownership.
When applying an archive over an existing checkout, delete obsolete files first
or use a clean extraction; ZIP extraction does not remove files that are absent
from the archive.

## Primary flows

### Host start

```text
load current account profile
→ seed title + profile-avatar cover
→ optionally edit title or select/upload another cover
→ prepare camera
→ start_live
→ hydrate data.live + data.session
→ join LiveKit with server token
→ publish the prepared local track
→ show Live UI
```

If backend start succeeds but media startup fails, Flutter attempts `end_live`
and releases local media. Navigation occurs only after the connection succeeds.
Profile refreshes may improve untouched defaults, but never overwrite a title
the user has edited. A failed replacement-cover upload restores the last valid
cover instead of leaving an unusable local-only selection.

### Viewer join

```text
join_live(live_id, session_id)
→ validate data.live capabilities
→ join LiveKit without local publication
→ track_join
→ show full-screen UI or remain in Feed preview
```

The manager caches a bounded set of canonical viewer-session IDs for reconnect
and Feed/full-screen reuse. A later Live selection invalidates an older pending
join. The transition queue prevents overlapping room mutations.

### Leave or end

Viewers and co-hosts call `track_leave`, leave the realtime room, and disconnect
LiveKit. Hosts call `end_live` first and then perform local cleanup. A backend
`aos_live_ended` event also executes the tracked cleanup path.

## Security and privacy

- LiveKit `token`, `ws_url`, private viewer session IDs, and internal user IDs
  must not be logged, deep-linked, shared, or persisted as display data.
- Host co-host invitations submit only the opaque `aos:participant:*` identity
  already visible in the room. Flutter never asks for another viewer's private
  AOS session ID.
- Chat sharing stores the canonical Live reference through
  `share_live_to_chat`; it does not expose media credentials.
- Native external sharing uses only the registered AOS Live deep link. The
  current custom scheme has no browser fallback.
- Missing capability payloads fail closed through `LiveViewerState.initial()`.
- The backend rechecks authentication, visibility, account state, blocking,
  session ownership, rate limits, and lifecycle on every mutation.

## Errors, offline behavior, and recovery

- HTTP and backend envelope failures become typed `Failure` values; UI must not
  branch on human-readable message text.
- A failed Feed join leaves the item non-playing and permits a later retry.
- Full-screen start/join failures expose retryable error UI and do not keep a
  false active-room state.
- Socket reconnect rejoins the room, refreshes canonical Live state, reloads
  comments, and reconciles co-host state.
- Live media has no offline playback. Existing metadata may remain visible, but
  starting, joining, commenting, reacting, co-hosting, and sharing to Chat
  require the backend.
- Local cleanup continues best-effort even when `track_leave` or socket leave
  fails.

## Current limitations

- Backend validation requires a nonblank title up to 140 characters and accepts an optional cover. The mobile preparation screen now matches that contract: an account without an avatar may start without selecting a cover.
- Replies are represented by API/model code but are not exposed in the current
  Live screen.
- Comment history currently loads a bounded first page using offset parameters;
  cursor pagination and older-page loading are not yet wired in Flutter.
- The inspected backend has no Live-level comments toggle, report-comment API,
  persisted moderator role, or public recording/share URL; Flutter does not
  invent them.
- The Go Live preparation screen is localized in all five existing app locales.
  Several other existing Live presentation strings remain English literals, so
  complete feature-wide localization and RTL copy review is still required.
- Automated tests use fakes and cannot prove camera, microphone, audio routing,
  background socket behavior, or real LiveKit publication. Device testing is
  required.

## Delivery

The documented and tested Live implementation is a **Shorebird OTA candidate**:
the feature changes are Dart-only and use existing dependencies and native
configuration. The previously registered custom deep-link schemes require the
matching store binary to already be installed.
