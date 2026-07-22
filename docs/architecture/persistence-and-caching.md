# Persistence and Caching

## Persistent stores

| Store | Backing technology | Current uses |
| --- | --- | --- |
| `SessionStorage` | `FlutterSecureStorage` + `SharedPreferences` | SID, remember-me, remembered email |
| `OnboardingStorage` | `SharedPreferences` | country, language, currency, onboarding completion |
| `ThemePrefs` | `SharedPreferences` | theme mode |
| Search recent storage | `SharedPreferences` | recent search terms/state |
| Wishlist storage | `SharedPreferences` | local wishlist persistence/support |
| User verification draft storage | `SharedPreferences` | in-progress verification draft |
| CallKit pending payload store | `SharedPreferences` | deferred incoming-call payload |
| Chat local preferences | `SharedPreferences` | chat-specific local settings |
| Device identifier | `FlutterSecureStorage` | stable local device identity |

No general-purpose local relational database or offline synchronization layer is represented in the uploaded frontend.

## Riverpod caching

Provider instances are the primary in-memory cache. Family parameters define cache keys, auto-dispose providers release state when unobserved, and explicit invalidation/refresh is used after mutations. Feature tests must verify invalidation and stale-state behavior where mutations affect more than one provider.

## Network/media caching

`cached_network_image` handles image cache behavior at the widget layer. Video and LiveKit resources have separate controller/track lifecycles and must be disposed explicitly.

## Logout behavior

Onboarding preferences are intentionally not automatically removed on logout. Session/auth data and user-private feature state must be cleared or invalidated. Feature phases should identify any provider or local cache that can leak one account's data into another session.

## Testing

Use `SharedPreferences.setMockInitialValues` through `test/helpers/test_preferences.dart`. Use `FakeSessionStorage` for SID/remembered-user behavior. Do not use real device secure storage in tests.
