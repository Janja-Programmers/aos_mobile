# Feature Documentation Index

Feature documentation is delivered incrementally. Each accepted feature should add `docs/features/<feature>/` and cover only behavior grounded in the frontend implementation.

Required topics where applicable:

- purpose, scope and entry points;
- significant file map and architecture;
- providers, state lifecycle, caching and invalidation;
- end-to-end data flow;
- frontend-represented API contracts and models;
- business rules, statuses, ownership and visibility;
- navigation, arguments, return values and guards;
- UI states and failure handling;
- security, privacy, permissions and trust boundaries;
- performance and lifecycle risks;
- dependencies;
- test traceability;
- extension guidance;
- discovered limitations and risks.

The first recommended feature is **authentication and session** because it establishes the deterministic identity seam required by protected routes, account/profile, user-private caches, realtime startup, seller ownership, chat, notifications, and verification tests.

- [Connect Chat](connect-chat.md)
- [Calls](calls/README.md)
- [Catalog](catalog/README.md)
- [Live](live/README.md)
- [Wishlist](wishlist/README.md)

- [Application lock](native-app-lock.md)

- [Ad creation](ad-creation.md)
- [Ad detail gallery download](ad-detail-media-download.md)
- [Shorts Feed and media sharing](shorts-live-feed-sharing.md)
