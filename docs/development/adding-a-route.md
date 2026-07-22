# Adding a Route

1. Add a stable path and name to `AppRoutes`.
2. Register the route in the owning feature route module or central router according to existing structure.
3. Place static routes before generic dynamic routes that could consume them.
4. Parse path/query parameters defensively and validate `state.extra` types.
5. Define whether the route is public, onboarding-only, auth-only, or protected.
6. Update `RouteGuards` only when frontend login gating is required.
7. Preserve return values for pickers/editors and refresh/invalidate the caller's state after a successful mutation.
8. Add navigation tests for direct URL entry, named navigation, arguments, return values, redirects, and guards.

Remember that route protection is not backend authorization.
