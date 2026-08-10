---
name: flutter-add-route
description: Add or change a GoRouter route, including public routes and deep links. Use whenever a new screen needs to be reachable — the auth guard blocks anything not explicitly allowlisted, so a new public route is broken by default.
---

# Adding a route

All routes live in `Routing.createRoutes` in [routing.dart](../../../lib/routing.dart). There is one `GoRouter`, one `redirect` guard, and no route-per-feature split.

## Path constants

The path is declared as a `static const String` **on the screen widget**, not in the router:

```dart
static const String fullPath = '/home_screen/settings_screen';  // absolute
static const String path = '/settings_screen';                  // relative, for nested routes
```

Screens nested under `HomeScreen` declare both: `path` is what the nested `GoRoute` uses, `fullPath` is what callers navigate to. Top-level screens declare only `fullPath`. Follow this — the router references `SomeScreen.path`, never a string literal.

## Steps

1. Add the constant(s) to the screen widget.
2. Add the `GoRoute` in [routing.dart](../../../lib/routing.dart). Authenticated screens go in the `routes:` list nested under `HomeScreen.fullPath`; auth/public screens go at the top level.
3. If the screen has a desktop variant, use the router-level ternary — see [flutter-mobile-desktop-variant](../flutter-mobile-desktop-variant/SKILL.md):
   ```dart
   builder: (context, state) => !isDesktop ? SettingsScreen() : SettingsDesktopView(),
   ```
4. **Passing data.** This repo passes whole objects via `state.extra`, cast in the builder: `AccountDetailScreen(state.extra as AccountModel)`. Path parameters (`:token`) are read with `state.pathParameters['token']`, query parameters with `state.uri.queryParameters['email']`. `state.extra` does **not** survive a deep link, a browser refresh on web, or process death — if the screen must be reachable from a URL, take an id as a path parameter and load the entity in the screen instead.
5. **If the route must work while logged out, allowlist it in `redirect`.** The guard sends every unauthenticated request to `LoginView.fullPath` unless the location matches one of the explicit checks near the bottom of `createRoutes` (`isPublicInviteRoute`, `isRegistrationRoute`, `isLoginRoute`). Skipping this is the single most common way a new public route silently redirects to login.
6. **Deep links** are handled by [deep_link_service.dart](../../../lib/data/services/deep_link_service.dart) (including QR-scanned invite links). A new externally-reachable link needs handling there too, not just a `GoRoute`.
7. `flutter analyze`, then navigate to the route in the running app — both logged in and logged out if it is public.

## Gotchas

- The `redirect` callback runs on **every** navigation. It currently short-circuits on password-reset state before the auth check, so anything you add ordering-wise matters; put new public-route checks alongside the existing `isPublicInviteRoute` group, not above the password-reset block.
- `isPublicInviteRoute` uses `startsWith('/public/invites/')` — a hardcoded string, not the screen's `fullPath` constant (which contains `:token` and cannot be compared directly). If you rename that route, grep for the literal.
- `initialLocation` is `LoginView.fullPath`; the guard, not the initial location, is what actually routes an already-authenticated user.
