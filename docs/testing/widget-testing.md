# Widget Testing

## Shared harness

Use `pumpTestApp` for ordinary widgets and `pumpTestRouter` for navigation. Both install:

- `ProviderScope` overrides;
- AOS light/dark theme;
- generated localization delegates;
- supported locales;
- optional navigator observers.

## Assertions

Prefer user-visible behavior and semantics:

- loading/empty/error/populated states;
- enabled/disabled actions;
- validation and conditional fields;
- progress and duplicate-tap prevention;
- permission/ownership visibility;
- dialogs, sheets, retry and feedback;
- navigation destination or returned result.

Avoid assertions on incidental widget-tree depth, framework internals, exact padding unrelated to a design regression, or the mere existence of a widget without behavior.

## Interaction helpers

`widget_actions.dart` centralizes tap, text entry, and settle behavior. Do not create feature-specific copies of the same helpers.
