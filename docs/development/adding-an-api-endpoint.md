# Adding an API Endpoint

1. Add the endpoint identifier to `ApiEndpoints` when it is part of the central registry convention.
2. Add or update the feature API class.
3. Use `ApiClient.get/post` unless the feature intentionally relies on direct Dio behavior that the wrapper does not expose.
4. Specify market context placement explicitly where country/currency affects the request.
5. Parse the Frappe envelope with `unwrapFrappe` or the feature's established parser.
6. Map `DioException` through `mapDioException` and preserve machine-readable backend errors.
7. Keep request payload construction separate enough to test exact fields and null/optional behavior.
8. Add a scripted adapter test that asserts method, path, body, query, headers, response mapping, malformed response behavior, and cancellation/retry only when implemented.

Never call staging or production from automated tests. Do not infer undocumented backend fields from UI labels.
