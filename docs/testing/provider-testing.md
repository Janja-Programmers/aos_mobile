# Provider Testing

## Isolated containers

Use `createTestContainer(overrides: [...])`. The helper registers disposal with `addTearDown`, preventing leaked timers, subscriptions, and provider state.

```dart
final container = createTestContainer(
  overrides: [repositoryProvider.overrideWithValue(fakeRepository)],
);
```

## What to verify

- initial state before asynchronous work;
- dependency override usage;
- loading, data, and error transitions;
- family key isolation;
- refresh and invalidation;
- auto-dispose behavior when material to correctness;
- synchronization of related providers;
- cleanup of subscriptions and controllers;
- account/session transitions for user-private state.

Use provider listeners or provider futures to await state. Avoid arbitrary sleeps. Test public notifier/controller methods and observable state, not private fields.
