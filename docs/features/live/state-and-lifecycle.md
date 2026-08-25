# Live State, Lifecycle, and Navigation

## State owners

`LiveManager` is the sole owner of active room/session state. Its public
`currentState` is a read-only snapshot for coordinating controllers; mutations
must use manager intent methods.

`LiveState` separates:

- backend/domain state: `live`, `session`, `role`, Live status and capabilities;
- media state: room state, publishing/subscribed flags, microphone, camera, and
  camera direction;
- presentation state: full-screen visibility, ending/reacting locks, reaction
  trigger, viewer count, and active co-host ID;
- recoverable UI error text.

Backend `AOSLiveStatus` values (`scheduled`, `live`, `ended`) are distinct from
the Flutter operation status (`idle`, `loading`, `live`, `ended`, `error`).
LiveKit room state (`disconnected`, `connecting`, `connected`, `reconnecting`)
is also distinct. A backend Live can be active while local media is still
connecting.

## Serialized transitions

Every room-changing operation is placed on `_transitionTail`. A generation
counter invalidates stale work when the user starts another join, leaves, ends,
or disposes the manager.

The protected invariants are:

- at most one active LiveKit room;
- at most one current backend Live/session pair;
- repeated same-Live joins share the in-flight operation;
- a later Live selection wins over an earlier incomplete join;
- viewer publication stays disabled;
- host/co-host media state changes only after server-issued role credentials;
- cleanup is safe to repeat.

## Lifecycle flows

### Start

`startLive` rejects a duplicate in-flight action, clears stale room/domain
state, calls the backend, hydrates the canonical result, and then connects media.
Only a successful media connection enables `hasLiveUi`.

If the result becomes stale, Flutter ends the newly created backend Live and
releases the prepared camera rather than navigating to an orphaned session.

### Join and Feed reuse

`joinLive` accepts `showLiveUi`:

- `true` for full-screen navigation;
- `false` for the visible Feed Live page.

If the same room is already active, no second backend or LiveKit join occurs;
only UI visibility is updated. A remembered canonical viewer session ID is sent
on reconnect. Otherwise the manager leaves the old tracked session before
joining the new one.

`ShortsFeedTab` owns only visibility selection. It does not create a second
LiveKit service or Live state store. Page changes, inactive tabs, replacement
feeds, and disposal call `leaveBackgroundLive`; a stale page completion cannot
claim the new visible Live.

### Co-host promotion and demotion

Promotion sequence:

```text
accepted workflow
→ get_live_cohost_token with viewer-owned session
→ disconnect viewer media
→ connect/publish with co-host token
→ activate_live_cohost
```

If media or backend activation fails, Flutter returns to a fresh viewer session.
If the workflow becomes stale after activation, Flutter ends the co-host and
returns to viewer. Demotion/ended events also recover viewer media.

### Leave and end

Viewer/co-host leave:

```text
track_leave
→ leave realtime room
→ disconnect LiveKit and local tracks
→ clear session/role/co-host state
```

Host end:

```text
end_live
→ leave realtime room
→ disconnect LiveKit and local tracks
→ terminal UI state
```

Failures in tracking/socket cleanup are logged without preventing local media
release. Host end failure keeps the session active and exposes a retryable error.

## App and media lifecycle

- `RoomReconnectingEvent` sets the local room state to reconnecting.
- `RoomReconnectedEvent` marks connected and starts canonical Live refresh.
- `RoomDisconnectedEvent` clears the active-room flag without fabricating a
  backend terminal state.
- `LiveScreen.dispose` cancels its media subscription and runs tracked
  leave/cleanup when it owns a visible session.
- Manager disposal invalidates pending generations, cancels its media-event
  subscription, and releases media best-effort.
- Prepared and published local camera tracks switch using LiveKit's physical
  `CameraPosition` API. The client does not select a device from a nullable
  current device ID, which could select the already-active camera.
- `LiveMediaService` holds the shared `live` camera lease while a prepared or
  published local camera track exists and releases it in the same cleanup path.
- Go Live suspends its prepared LiveKit preview before the shared cover-photo
  camera opens, then reacquires the specialized preview after capture. App
  inactive/pause/detach also releases an untransferred preview.

## Host follow presentation

The backend Live payload remains the relationship source of truth. `LiveScreen`
adds only an in-flight tap lock and a short-lived successful-target marker so
the button disappears immediately after a confirmed follow. It then refreshes
the active Live; no second relationship provider, cache, or persistent store is
created.

## Navigation

`LiveNavigation` owns route construction using a canonical `live_id`. Route
entry does not trust notification/share metadata for title, host, permission,
room name, or token; `LiveScreen` calls the manager to join/hydrate first.

The full-screen screen may reuse an active Feed room. Explicit Leave and system
back both run the manager cleanup path. Widgets must not navigate immediately
after `start_live`; they wait for the manager's successful media result.

The Go Live screen watches the existing account-profile controller rather than
creating another profile store. Untouched title/cover defaults update when the
profile arrives. Opening the edit-details bottom sheet creates only a temporary
UI draft; Save returns the trimmed title and optional local cover selection to
the screen. A selected cover is uploaded before Start becomes available.

## Errors and UI states

| State | Required presentation |
| --- | --- |
| Initial/loading | Bounded progress state; duplicate actions disabled |
| Active | Video or accessible connecting/empty stage, safe-area controls, comment input when permitted |
| Reconnecting | Preserve screen state and indicate reconnection without starting a second join |
| Ended/inaccessible | Stop media, clear active controls, offer a safe route away |
| Recoverable error | Stable message, retry/leave path, no false active-room flags |
| Offline | Metadata may remain visible; network mutations fail through typed error handling |

## Extension rules

- Add backend capabilities to typed domain models and serializers before UI.
- Keep business permission and transition decisions on the backend.
- Add a method to the existing manager/controller rather than adding a second
  provider, socket listener, LiveKit room, cache, or persistence store.
- A new realtime event must define scope, ordering, idempotency/deduplication,
  reconnect recovery, and terminal behavior.
- Any native permission, plugin, entitlement, or deep-link change must be
  classified for a store release rather than assumed OTA-safe.
