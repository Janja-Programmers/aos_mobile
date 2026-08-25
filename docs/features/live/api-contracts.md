# Live API Contracts

## Envelope and failure mapping

Frappe wraps the AOS envelope inside `message`:

```json
{
  "message": {
    "ok": true,
    "message": "Live fetched.",
    "data": {}
  }
}
```

Failures use the stable `error` field. Flutter unwraps the response once,
returns `Either<Failure, T>` at the API layer, and throws the typed `Failure` at
the repository boundary. Human-readable `message` is display copy, not control
flow.

Stable Live errors include `LIVE_INVALID_REQUEST`, `LIVE_UNKNOWN_FIELD`,
`LIVE_ALIAS_CONFLICT`, `LIVE_INVALID_IDENTIFIER`, `LIVE_INPUT_TOO_LARGE`,
`LIVE_INVALID_CURSOR`, `LIVE_PAGINATION_CONFLICT`, `LIVE_ACCESS_DENIED`,
`LIVE_NOT_FOUND`, `LIVE_CONFLICT`, `LIVE_INVALID_STATE`,
`LIVE_COHOST_SLOT_UNAVAILABLE`, `LIVE_DEPENDENCY_UNAVAILABLE`, and
`LIVE_INTERNAL_ERROR`. Shared errors such as `AUTH_REQUIRED` and `RATE_LIMIT`
remain valid.

## Lifecycle, discovery, and tracking

Base path: `/api/method/aos.api.v1.live`.

| Flutter operation | HTTP endpoint | Request represented in Flutter | Required response data |
| --- | --- | --- | --- |
| Start | POST `start_live` | `title`; optional `live_cover_media`, otherwise optional `cover_image` | `data.live`, `data.session` |
| Join | POST `join_live` | `live_id`, client/canonical `session_id` | `data.live`, `data.session` |
| End | POST `end_live` | `live_id` | Success envelope |
| Detail/recovery | GET `get_live` | `live_id`; optional `session_id` | `data.live` |
| Discovery | GET `list_live_streams` | `limit`; optional signed `cursor` | `data.items`, `data.pagination` |
| Track join | POST `track_join` | `live_id`, `session_id` | Optional refreshed `data.live` |
| Track leave | POST `track_leave` | `live_id`, `session_id` | Optional refreshed `data.live` |
| React | POST `send_reaction` | `live_id`, `reaction_type`; optional `session_id` for host compatibility | `data.reaction` |
| Chat share | POST `share_live_to_chat` | `live_id`, `conversation_id`; optional `message`, `idempotency_key` | Success envelope |

`start_live.title` is required and bounded to 140 Unicode characters by the
backend. The transport permits an omitted cover. The mobile preparation screen uses the current profile avatar as `cover_image` when available, but does not require a cover because the backend contract makes it optional. A newly
selected cover is uploaded with purpose `live_cover` and sent as
`live_cover_media`; Flutter does not send conflicting cover aliases.

`mapLiveBootstrap` rejects a response when the Live/session IDs differ or the
server-controlled room name, token, WebSocket URL, or identity is missing. The
client never fabricates private credentials.

The supported reaction values are exactly:

```text
like
fire
clap
love
wow
```

## Comments

| Operation | Endpoint | Fields currently sent |
| --- | --- | --- |
| List messages | GET `list_live_messages` | `live_id`, `start`, `limit` |
| List replies | GET `list_live_replies` | `parent_message`, `start`, `limit` |
| Add | POST `add_live_message` | `live_id`, `content`, optional `session_id`, generated `idempotency_key` |
| Reply | POST `reply_live_message` | `live_id`, `parent_message`, `content`, optional `session_id` |
| Delete | POST `delete_live_message` | `message_id` |

The backend owns author identity, escaping, the 500-character bound,
idempotency, authorization, timestamps, ordering, and soft deletion. Flutter
trims blank input for UX, filters deleted history rows, and keeps deletion
tombstones so a late socket/history event cannot resurrect a removed message.

## Co-host

| Operation | Endpoint | Fields currently sent |
| --- | --- | --- |
| Host invite | POST `invite_live_cohost` | `live_id`, `livekit_identity` |
| Viewer request | POST `request_live_cohost` | `live_id`, `session_id` |
| Accept/reject | POST `respond_live_cohost` | `cohost_id`, `action`; optional `reason` |
| Cancel | POST `cancel_live_cohost` | `cohost_id`; optional `reason` |
| List | GET `list_live_cohosts` | `live_id`; optional `status` |
| Token | POST `get_live_cohost_token` | `cohost_id`, viewer-owned `session_id` |
| Activate | POST `activate_live_cohost` | `cohost_id`, viewer-owned `session_id` |
| End | POST `end_live_cohost` | `cohost_id` |

Workflow statuses represented by Flutter are `pending`, `accepted`, `active`,
`rejected`, `cancelled`/`canceled`, `ended`, and `expired`. Request types are
`host_invite` and `viewer_request`.

The server permits one accepted or active co-host. Flutter does not predict slot
availability: it submits the intent, consumes the returned workflow, and
handles `LIVE_COHOST_SLOT_UNAVAILABLE` or another stable error.

## Pagination and bounds

- Discovery uses bounded signed-cursor pagination through `next_cursor` and
  `has_more`.
- Live message APIs support cursor pagination in the backend, but the current
  Flutter comments API uses bounded `start`/`limit` requests.
- Flutter does not combine cursor and offset parameters.
- Backend limits, identifier formats, title/comment/reason bounds, rate limits,
  and ordering remain authoritative.

## Host relationship action

Live payloads provide the host relationship through `viewer_state`, including
`target_user`, `is_following`, `action_label`, and `can_follow`. Flutter does
not infer those values from the host profile.

When the backend permits following and the viewer is not already following,
the Live screen calls the existing Social `toggle_follow` endpoint with:

```json
{
  "target_user": "ACC-...",
  "action": "follow"
}
```

The explicit action is idempotent and avoids toggle races. The returned
relationship confirms success, then Flutter refreshes `get_live` so
`viewer_state` remains the canonical presentation state.

## Credential handling

The following values are private transport credentials, not shareable domain
content:

```text
session.token
session.ws_url
viewer session_id
private co-host workflow metadata
```

They remain in memory for the active session and must not appear in logs,
analytics, URLs, share text, notifications, or fixtures copied from production.
Test fixtures use nonfunctional values under `.invalid` domains.

## Declared but intentionally unused paths

`get_live_token` exists in `ApiEndpoints`, but the current join/recovery flow
receives session credentials from `join_live` and refreshes through
`get_live`/`join_live`. Widgets must not call token endpoints directly.

The backend exposes no public active-Live MP4/HLS recording URL. External share
therefore uses an AOS deep link rather than a LiveKit URL or fabricated media
link.
