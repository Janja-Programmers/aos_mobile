# Networking

## Transport

`ApiClient` wraps Dio with:

- a normalized base URL;
- 60-second connect and receive timeouts;
- JSON content/accept headers;
- an in-memory `CookieJar` and `CookieManager`;
- request-time AOS market-context headers;
- optional market-context injection into query/body data;
- a broadcast `sessionExpiredStream` triggered by HTTP 401 responses.

`apiClientProvider` creates and disposes the client. API features generally obtain it through Riverpod.

## Session cookie

After authentication, the SID is saved to the Dio cookie jar using an HTTP-only `sid` cookie scoped to `/`. This cookie jar is in memory; persistent restoration is driven separately by `SessionStorage` and the authentication controller.

## Endpoint registry

`ApiEndpoints` centralizes endpoint identifiers across auth, account, media, catalog, ads, reports, reviews, communication, calls, live, notifications, social, Shorts, maps, seller, search, verification, and activity operations.

Some feature APIs use `ApiClient.get/post`; others access `client.dio` directly. Tests must assert the real call style and should not silently rewrite API clients merely for consistency.

## Response shape

`unwrapFrappe` accepts:

- `{ "message": { ... } }` and returns the nested map;
- `{ "message": "..." }` and converts it to an `ok/message` map;
- an unwrapped map;
- otherwise a parse `Failure`.

Feature models then parse the resulting payload. Frontend documentation must distinguish the transport envelope from feature `data` models.

## Failure mapping

Dio failures are converted to `Failure`, preserving:

- user-facing message;
- HTTP status code;
- normalized `FailureType`;
- backend machine-readable `error` token;
- optional structured `data`.

Auth and session decisions must use the error token/type, not backend message wording.

## API test seam

`test/fakes/recording_http_client_adapter.dart` scripts Dio responses and records `RequestOptions`. It enables assertions on method, path, query, body, headers, cancellation, and parsing without contacting staging or production.
