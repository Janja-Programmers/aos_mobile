# Debugging

## Analyzer first

Run `flutter analyze` before chasing runtime behavior. Strict analyzer errors in this project often identify real async lifecycle, typing, or import defects.

## Network failures

Inspect `Failure.error`, `Failure.type`, and status code before relying on message text. Confirm the Frappe envelope and endpoint payload against the feature API parser. Never log credentials, SID, upload signatures, private messages, or verification documents.

## Riverpod state

Check:

- the provider family key;
- auto-dispose lifecycle;
- whether a mutation invalidates all dependent providers;
- whether an app-root listener was unintentionally activated;
- whether state from a previous authenticated user survived logout;
- whether a notifier was disposed before an async callback completed.

## Navigation

Log or assert `state.uri`, `matchedLocation`, and route parameters. Protected-route redirect bugs commonly involve query strings, dynamic route bases, or bootstrap/auth refresh timing.

## Platform features

Separate platform-channel failures from application logic. Reproduce permissions, CallKit, Firebase, MapLibre, file picker, camera/microphone, and LiveKit issues on a configured device. Keep unit/widget tests on provider/service fakes.
