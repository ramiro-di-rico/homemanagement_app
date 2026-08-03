---
name: flutter-mobile-desktop-variant
description: Create or update a desktop-specific view alongside its mobile counterpart. Use when a feature's mobile layout doesn't fit desktop/web and needs a parallel implementation, not a responsive tweak to one widget.
---

# Mobile vs. desktop view variants

`PlatformContext` (`lib/data/services/platform/platform_context.dart`) detects mobile vs. desktop/web at runtime. [lib/routing.dart](../../../lib/routing.dart) picks the variant per route with the pattern:

```dart
!isDesktop ? SomeScreen() : SomeDesktopView(),
```

This repo does **not** use one responsive widget with breakpoints for full screens — it uses two separate widget trees, wired at the router. Only use `LayoutBuilder`/`MediaQuery` breakpoints for small in-page adjustments, not for swapping entire screens.

## Steps

1. Find the mobile view for the feature in `lib/ui/features/<feature>/views/`.
2. Create the desktop counterpart in the same `views/` folder. Match the existing naming pattern for that feature's desktop files (e.g. `account-list-desktop.dart` sits next to `account.list.dart` — check the folder, conventions are inconsistent repo-wide, so mirror the neighbor, don't invent one).
3. Both variants should read from the same repository/view state shape — do not fork business logic, only layout. If the two variants start diverging in what data they need, that's a signal the repository method needs an extra parameter, not two different repository calls.
4. Wire the new desktop widget into [lib/routing.dart](../../../lib/routing.dart) using the `!isDesktop ? Mobile() : Desktop()` ternary, matching the surrounding routes.
5. Manually verify both branches — `flutter run -d linux` (or `-d chrome`) exercises the desktop branch; `flutter run -d android`/an emulator exercises the mobile one. `flutter test` won't catch a router wiring mistake since there's no route-level test coverage today.

## Common mistake to avoid

Don't gate desktop-only code on screen width instead of `PlatformContext`/`isDesktop` — this repo's convention is platform-based branching at the router, and mixing both approaches for the same feature makes the split harder to reason about later.
