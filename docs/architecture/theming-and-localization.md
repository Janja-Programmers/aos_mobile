# Theming and Localization

## Theme

`AppTheme.light()` and `AppTheme.dark()` define Material 3 themes backed by `AppColorTokens` theme extensions. Shared text styles read colors from the active theme extension rather than hardcoding production colors.

`ThemeController` persists `ThemeMode` through `ThemePrefs`. The provider throws by default and is overridden during startup with the restored mode. Tests that render production widgets should use `AppTheme.light()` or `AppTheme.dark()` through the shared widget harness.

## Localization

Flutter-generated `AppLocalizations` is enabled through `flutter: generate: true`. Supported locales are:

- English (`en`)
- Swahili (`sw`)
- French (`fr`)
- Arabic (`ar`)
- Chinese (`zh`)

`resolveLocale` normalizes language tags such as `en-US` to the primary language and falls back to English for unsupported values.

User preference state stores normalized language, country, and currency codes. Onboarding and authenticated preference synchronization update the same persistent storage.

## Widget testing

`pumpTestApp` and `pumpTestRouter` install the production theme, localization delegates, supported locales, and text direction behavior. Feature tests should select an explicit locale when copy, directionality, or translated semantics affect behavior.

Do not assert localized English text when a semantic finder, key, or callback assertion better represents the behavior. When exact copy is the requirement, set the locale explicitly.
