# Live Realtime, Comments, Reactions, and Co-hosts

## One realtime owner

`LiveRealtimeCoordinator` is the only Live socket consumer. It subscribes once
to `RealtimeService.events` and `RealtimeService.connections`, serializes event
handling on `_eventTail`, and cancels both subscriptions during disposal.

Every event must contain a `live_id` matching the manager's active session.
Events for an empty, old, Feed-adjacent, or otherwise inactive Live are ignored.

| Event | Owner/action |
| --- | --- |
| `aos_live_started` | Manager marks the current Live active |
| `aos_live_ended` | Manager performs tracked leave and terminal cleanup |
| `aos_live_viewer_count` | Manager replaces the nonnegative authoritative count |
| `aos_live_comment` / legacy `aos_live_message` | Comments controller merges canonical message |
| `aos_live_comment_deleted` / legacy message name | Comments controller applies tombstones |
| `aos_live_reaction` | Manager validates type, deduplicates ID, increments presentation aggregate |
| Co-host invite/request/accepted/rejected/cancelled/activated/started/ended | Co-host controller reconciles workflow and media role |
| Viewer joined/left | No local roster mutation; authoritative viewer-count events/refresh own the displayed count |

Bounded deduplication protects at-least-once delivery:

- coordinator event keys: last 512;
- manager reaction IDs: last 256;
- comment deletion tombstones: last 256;
- visible comments: last 80.

These are local presentation guards. Backend idempotency and database
constraints remain the durable duplicate boundary.

## Reconnect recovery

On a socket connection event, the coordinator:

1. rejoins the active Live socket room;
2. refreshes canonical Live state;
3. demotes a stale local co-host when backend capability no longer confirms it;
4. reloads persistent comments;
5. hydrates and, when relevant, reloads co-host workflow state.

Recovery requests are coalesced and serialized with normal events. Comments do
not poll periodically.

## Comments

`LiveCommentsController` owns a single Live ID at a time. Switching Live IDs
increments a generation so an older history response cannot replace the new
room's comments.

Submission behavior:

- trim whitespace and reject blank text locally;
- permit only one pending submit;
- generate an idempotency key;
- pass the viewer-owned session ID;
- insert the canonical backend response;
- restore input and expose the stable failure on rejection.

Realtime/history merge uses canonical message ID. A duplicate replaces the
existing entry rather than creating a second row. Delete is optimistic; API
failure restores the removed comment, while success records a tombstone so a
late event cannot resurrect it.

The current screen shows the bounded root comment stream. Reply models and APIs
exist, but reply presentation/pagination is not yet wired.

## Reactions

A tap sends `like`; long press opens the complete typed reaction picker:
`like`, `fire`, `clap`, `love`, and `wow`.

`LiveManager` permits one pending local reaction request, requires backend
`can_react`, and deduplicates the canonical reaction ID between the HTTP response
and socket echo. `LiveTopBar` presents one total reaction-count badge beside the
LIVE badge. Floating emoji animation is presentation-only and uses the last
accepted reaction type.

The backend owns authentication, session participation, rate limits, persistence,
and the aggregate. Flutter never exposes a per-user reaction history that the
backend does not provide.

## Co-host workflow

`LiveCohostController` owns workflow UI state; `LiveManager` owns media role.
The controller does not fabricate accepted/active transitions.

### Host invitation

The host selects an eligible authenticated LiveKit viewer participant. Flutter
sends only the opaque room identity. The backend resolves the account and
private viewer session.

### Viewer request

The active viewer submits their own canonical `session_id`. Duplicate pending
requests are resolved by the backend's idempotent workflow.

### Accept and activate

An accepted candidate is not considered media-active immediately. Flutter gets
a server-issued co-host token, connects/publishes as co-host, and only then calls
activation. This order prevents the application state from claiming an active
co-host whose media never connected.

Only one activation per co-host ID runs locally. Generation/live checks protect
against acceptance racing with Live end, cancellation, another room, or screen
disposal.

### End and recovery

Terminal workflows are removed from actionable local state. When the current
co-host receives rejected/cancelled/ended state, Flutter rejoins as viewer.
Activation failure also demotes and surfaces an error. Host-side active co-host
state is hydrated from canonical Live detail and list responses.

## Maintenance rules

- Do not restore `LiveSignalingHandler`, `SocketLiveListener`, or
  `LiveRealtimeListener`.
- Do not send another viewer's AOS session ID from the host client.
- Do not use viewer joined/left events as an independent counter store.
- Do not increment aggregates for both HTTP and socket delivery without ID
  deduplication.
- Do not depend on socket memory for durable comments or co-host recovery.
- Do not swallow parse or async errors; malformed payloads must be ignored or
  surfaced without terminating the coordinator subscription.
