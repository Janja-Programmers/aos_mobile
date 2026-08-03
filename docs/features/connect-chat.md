# AOS Connect Chat

## Scope and entry points

AOS Connect keeps the existing Chats and Calls tabs under `/connect`. Chat routes are:

- `/connect/new` for verified-seller and friend selection;
- `/chats/:conversationId` for an active conversation;
- `/connect/starred` for the authenticated user's starred messages;
- `/connect/chat-settings` for supported global Chat settings.

Calls remain a separate state domain. Shared Connect navigation and badges must not create a second Calls owner.

## Architecture and state ownership

| Domain                                                                              | Owner                                                            |
| ----------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Authenticated identity                                                              | `authControllerProvider` and `currentCanonicalAccountIdProvider` |
| Conversation list and unread counts                                                 | `ConversationsController`                                        |
| One active conversation's messages, pagination, actions, and realtime subscriptions | `ChatMessagesController` family, keyed by conversation ID        |
| Typing and presence                                                                 | Existing Chat typing/presence controllers                        |
| Composer, reply, edit, and attachment selection                                     | Active `ChatScreen` state and focused composer helpers           |
| Voice recording                                                                     | `VoiceRecordController`                                          |
| Account-scoped local Chat settings                                                  | `ChatLocalPreferencesController`                                 |
| Navigation                                                                          | go_router Chat/Connect route helpers                             |

Widgets render state and dispatch actions. They do not decide backend permissions, participant identity, or message ownership from display text.

## Backend contracts

The backend is authoritative for conversation participants, messages, attachments, reactions, stars, edits, deletion, translation, pagination, realtime events, permissions, validation, rate limits, and errors.

Important frontend mappings:

- Auth `/me`/login user `id` is the canonical public account ID (`ACC-…`).
- Message `sender` and conversation participant IDs use the same canonical public account ID.
- Conversation pagination uses `limit` and `offset`.
- Message and starred-message pagination use the backend `before` cursor/timestamp contract.
- Backend `error` is retained in `Failure.error`; UI must not branch on translated message text.
- Unknown message types remain `unknown` and are not silently reinterpreted as text.

## Canonical identity and message alignment

The invariant is:

```text
message.senderCanonicalId == authenticatedUser.canonicalId
```

Only canonical `ACC-…` IDs are accepted by the Chat ownership seam. Email, username, display name, phone, avatar URL, object identity, and cached `isMine` values are not valid ownership signals.

- Server messages parse backend `sender` into `ChatMessage.senderCanonicalId`, independently from sender labels.
- Optimistic messages take the active authenticated canonical ID directly from `ChatMessagesController`.
- `isMe` is derived when presenting each message.
- Account/session generation guards discard stale requests and realtime events after logout or account switching.
- Conversation preview ownership uses canonical `last_sender`.

No message alignment value is persisted.

## Models and normalization

`ChatMessage`, `ChatConversation`, attachments, reactions, viewer state, and reply previews are parsed at explicit JSON boundaries. Parsing is null-safe and invalid server timestamps use a deterministic epoch fallback rather than `DateTime.now()`, preventing profile hydration or malformed records from reordering messages.

The authenticated `AuthUser.accountId` is the only reusable Chat identity source. Profile display fields remain presentation data and cannot override authenticated canonical identity.

## Local persistence and migration

Messages and conversations are not persisted by this feature, so there is no legacy cached bubble-alignment truth to migrate.

Local settings use versioned, account-scoped keys:

```text
chat.v2.<canonicalAccountId>.enter_to_send
chat.v2.<canonicalAccountId>.wallpaper.<conversationId>.id
chat.v2.<canonicalAccountId>.wallpaper.<conversationId>.image_path
```

Legacy unscoped Chat settings are invalidated rather than migrated across users. Gallery wallpapers are copied into application-support storage and scoped by account and conversation. Logout/account switching recreates providers under the new account scope.

## Conversation list and new conversation

The Connect screen supports loading, empty, populated, error, offline/retry, local search, unread badges, and backend conversation pagination. Realtime updates merge by stable conversation/message IDs.

New Conversation uses backend-backed verified seller and friend lists. Search is debounced, stale result generations are ignored, pagination deduplicates canonical user IDs, repeated open/call taps are guarded, and no display name is used as participant identity.

The screenshot-driven menus remain context-specific:

- Chats: Mark all read, Starred messages, Settings.
- Calls: Clear call log, Settings.
- Active Chat: Call, Video call, Change wallpaper.

Mark all read composes the available conversation-list and per-conversation `mark_read` contracts. Partial failures remain failures and are not represented as complete success.

## Messages, pagination, and realtime

The active controller owns one set of message subscriptions. Initialization cancels old subscriptions before listening again. Request/session generation checks prevent post-logout updates and stale account responses.

- Initial and older pages merge by stable message ID.
- Realtime and optimistic/server reconciliation deduplicate IDs.
- Optimistic failures remain retryable and keep canonical ownership.
- Incoming-message read synchronization compares canonical sender IDs.
- Edits, deletes, status changes, and reactions update the matching stable message ID without changing its owner or order.

## Attachments

Existing media/upload infrastructure remains authoritative. The attachment sheet exposes only implemented paths and call shortcuts. A selected file moves through selection/upload/send/failure/retry or cancellation before a backend message is considered sent. Upload/message duplicate-submit guards remain required.

Backend attachment identifiers and URLs are stored separately from local preview paths. Missing media is rendered as a recoverable placeholder rather than causing layout failure.

## Voice messages

Voice recording uses the existing `record` and media upload flow. Microphone permission is requested before recording. Start, finish, cancel, disposal, and lifecycle interruption clean up the recorder and temporary file flow.

The backend does not persist waveform samples. The UI therefore displays real duration/playback progress only and does not fabricate waveform data.

## Reactions, stars, edits, deletion, and forwarding

Actions are shown only when the message state and current canonical ownership permit them. Backend permissions remain authoritative.

- Reaction updates require the authoritative backend reaction payload; missing/invalid payloads fail instead of inventing counts.
- Star/unstar uses backend viewer state and is available from the long-press menu and Starred Messages screen.
- Edit is restricted to supported, server-backed current-user messages. Duplicate saves are blocked and cancellation leaves the original untouched.
- Delete-for-everyone is shown only for current-user messages; backend rules decide final permission.
- Forward is exposed only for supported server-backed messages.

## Translation

Translation preserves the sender's original content and renders translated content separately with language/status semantics. Editing clears stale translation presentation. Failures are retryable. German is represented with the service language code `deu_Latn`.

Machine translation is never persisted as original sender content by the frontend.

## Copy confirmation

Copy uses the platform clipboard and shows a localized, accessible live-region snackbar. Backend/debug data is never placed in the confirmation.

## Settings

Supported local settings have one owner: `ChatLocalPreferencesController`.

- Enter is send: local, account scoped.
- Default/per-conversation wallpaper: local, account scoped.
- Blocked contacts: routes to the existing Social owner.

Read receipts visibility, last-seen visibility, media auto-download, and message/call notification toggles are shown disabled where the screenshot requires their presence because the current backend has no authoritative Chat preference contract for them. No competing local setting is fabricated.

## Accessibility and responsive behavior

Changed surfaces use SafeArea, scrollable empty/error states, wrapping action layouts, constrained menus/sheets, minimum touch targets, sender/status/reaction/star/translation semantics, and keyboard-aware composer padding. Device validation must cover small screens, landscape, RTL, 200% text scale, light/dark themes, and TalkBack/VoiceOver.

## Errors and retry

Chat API failures preserve stable backend `error` IDs and status/type metadata. Connection and timeout failures are classified separately. User-visible strings are localized at the presentation boundary. Exceptions are not swallowed and no Python/Frappe debug exception text is exposed.

## Tests

Focused tests cover:

- canonical user/message parsing and ownership;
- left/right bubble alignment;
- optimistic canonical sender assignment contract;
- account-scoped settings and legacy invalidation;
- account switching ownership;
- realtime/pagination deduplication helpers;
- edit and translation mapping;
- reaction/star viewer-state mapping;
- German translation option;
- copy snackbar source contract;
- Quick Messages removal;
- responsive message actions at 320 px, RTL, and 200% text scale.

Run:

```bash
flutter test test/features/connect/chats
```

## Known limitations

- The backend has no single bulk mark-all-read endpoint; the frontend composes existing paginated list and `mark_read` calls.
- The backend does not provide voice waveform samples.
- Several screenshot settings have no backend preference contract and remain disabled rather than creating a second source of truth.
- No persisted message cache is introduced by this hardening pass.

## Validation

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter test test/features/connect/chats
flutter build apk --debug
```

## Delivery impact

The implementation changes Dart, localization, tests, and documentation only. It adds no dependency, native permission, plugin, asset, or platform-project change. It is therefore a **Shorebird OTA candidate**, subject to successful analyzer, test, build, and device validation on the exact release baseline.
