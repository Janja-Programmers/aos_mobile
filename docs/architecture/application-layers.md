# Application Layers

AOS uses a pragmatic feature-first architecture rather than one uniform Clean Architecture template. Future work must preserve the established structure of each feature while keeping responsibilities separated.

## Presentation

Screens, sections, sheets, dialogs, pickers, and reusable widgets live under feature `presentation/`, `screens/`, or `widgets/` directories. Presentation reads Riverpod state and delegates mutations to controllers, notifiers, repositories, or API services.

## Application and state

Controllers, managers, listeners, notifiers, providers, and state classes coordinate use cases and UI state. Common locations include:

- `application/controllers/`
- `application/providers/`
- `application/state/`
- legacy or smaller feature `controller/` directories
- provider files under `shared/providers/`

Both modern `AsyncNotifier` APIs and legacy `StateNotifier` APIs are present. Feature tests should follow the implementation being tested rather than migrating state technology opportunistically.

## Domain and models

Domain entities, value objects, enums, payload types, and UI/domain models appear under `domain/`, `models/`, or `shared/domain/`. Parsing is often defensive because API values may be nullable, stringified, or represented by several compatible field names.

## Data and repository

Most feature network code is in classes named `*Api`. Repository interfaces and implementations are used in communication, live, notifications, social, and Shorts flows, while several marketplace and account features inject API classes directly into controllers. This mixed pattern is intentional in the current codebase.

## Core and shared

- `lib/core` owns application-wide infrastructure such as API transport, route composition, storage, theme, realtime, location, media, and generic utilities.
- `lib/shared` owns reusable UI and cross-feature types.

Core code imports feature code in several places, especially router composition and session-aware startup listeners. Treat these edges as explicit coupling that must be regression-tested, not as permission for arbitrary feature-to-core dependencies.

## Platform and external services

Firebase, Firebase Messaging, local notifications, CallKit, LiveKit, geolocation, MapLibre, file/image pickers, secure storage, SharedPreferences, sockets, and media codecs sit at the platform boundary. Unit tests must replace or bypass these dependencies and must never invoke real platform channels or remote services.
