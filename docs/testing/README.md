# Testing Foundation

The shared test foundation establishes one reusable approach for future feature deliveries.

## Included utilities

| Utility | Purpose |
| --- | --- |
| `helpers/provider_container.dart` | Creates auto-disposed Riverpod containers with overrides |
| `helpers/pump_app.dart` | Pumps widgets with ProviderScope, production theme, localization and observers |
| `helpers/test_router.dart` | Builds and pumps isolated GoRouter graphs |
| `helpers/fixture_loader.dart` | Loads typed JSON object/list fixtures |
| `helpers/test_preferences.dart` | Initializes deterministic SharedPreferences values |
| `helpers/widget_actions.dart` | Common tap/text/settle interactions |
| `fakes/fake_clock.dart` | Fixed and manually advanced time |
| `fakes/fake_session_storage.dart` | In-memory auth/session persistence |
| `fakes/recording_http_client_adapter.dart` | Scripted Dio responses and request recording |
| `fixtures/shared/auth_fixtures.dart` | Sanitized `AuthState` builders |
| `test_config/test_environment.dart` | Non-secret deterministic test constants |

Import the barrel:

```dart
import 'package:africaonlinestores/...';
import '../helpers/test_harness.dart';
```

Use a path appropriate to the test file. Do not copy these helpers into feature folders.
