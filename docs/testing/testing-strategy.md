# Testing Strategy

## Goals

Tests protect real business behavior, privacy, authorization assumptions, mutations, state transitions, API contracts, and regressions. Test count and 100% line coverage are not goals by themselves.

## Levels

1. **Pure unit/model tests**: parsing, serialization, validation, status mapping, value objects.
2. **API/repository tests**: exact transport contract through a scripted Dio adapter or repository fake.
3. **Controller/provider tests**: lifecycle, loading/success/failure, refresh, pagination, invalidation, optimistic rollback, duplicate prevention.
4. **Widget/form tests**: meaningful UI states, actions, validation, progress, feedback, conditional visibility.
5. **Navigation tests**: route, arguments, redirect, guard, return value.
6. **Cross-feature regression tests**: session expiry, global invalidation, route guards, notification/deep-link routing, shared model compatibility.

## Isolation

- No real HTTP, Firebase, sockets, LiveKit, CallKit, maps, location, camera, microphone, filesystem picker, or secure-storage calls.
- Each `ProviderContainer` is disposed.
- SharedPreferences uses mock initial values.
- Time is fixed or manually advanced.
- Fixtures use `.invalid` domains and sanitized identities.

## Feature completion

A feature is complete only when documentation and tests trace to actual production behavior, success and failure paths are covered, validation results are honest, and any production change is minimal and justified.
