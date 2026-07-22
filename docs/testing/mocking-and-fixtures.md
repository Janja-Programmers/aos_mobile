# Mocking and Fixtures

## Preferred override boundary

1. repository interface;
2. API provider;
3. storage/platform service provider;
4. Dio adapter for transport-contract tests.

Handwritten fakes are preferred when they make state and assertions clearer. The project does not currently include a mock-generation package, so this foundation does not add one.

## Dio

Use `RecordingHttpClientAdapter` to return deterministic `ResponseBody` values and inspect `RequestOptions`. Assert method, path, body, query, and headers. Never point a test Dio instance at `AppConfig` or a staging URL.

## Sessions

Use `FakeSessionStorage`. It implements SID, remember-me, and remembered-email behavior in memory and exposes no platform channel.

## Fixtures

Use `loadJsonObjectFixture` or `loadJsonListFixture`. Fixture values must be:

- realistic for the parser;
- sanitized;
- deterministic;
- free of credentials, real emails, real phone numbers, session tokens, signed media URLs, and private data.

Prefer builders for model/state variations and JSON for transport payloads. Do not duplicate the same global auth/session fixture inside every feature.
