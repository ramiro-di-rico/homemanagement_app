---
name: flutter-new-feature
description: Add a new feature end-to-end (service, repository, view, DI registration, route) following this repo's actual layering. Use when asked to add a new resource/screen, not a generic Flutter scaffold.
---

# Adding a new feature

This repo layers as `lib/data` (services + repositories + models) → `lib/domain` (clean models, sparingly) → `lib/ui/features/<feature>` (views). There is **no generated DI** despite `injectable` being a dependency — every registration in [main.dart](../../../lib/main.dart) is written by hand in `registerServices()` / `registerSingletons()`. Do not add `@injectable` annotations; they won't be picked up.

## Steps

1. **Service** (`lib/data/services/<name>.service.dart`) — wraps raw HTTP calls for one resource. For the HTTP-helper choice, body encoding, and the error-to-toast path, see [flutter-call-backend-endpoint](../flutter-call-backend-endpoint/SKILL.md); if responses should be cached, see [flutter-add-cached-data](../flutter-add-cached-data/SKILL.md). Constructor takes `AuthenticationService` and usually an `ApiServiceFactory` built from it. Look at `AccountService` or `CategoryService` in [main.dart](../../../lib/main.dart) for the exact constructor shape to copy.
2. **Repository** (`lib/data/repositories/<name>.repository.dart`) — consumes the service(s), handles errors, aggregates/caches. This is what views call — never call a Service directly from a view.
3. **Register in `lib/main.dart`** — add `GetIt.instance.registerFactory(() => XService(...))` and the matching repository registration inside `registerServices()`. Order matters only insofar as a registration can reference `GetIt.I<T>()` for something already registered earlier in the function — put dependencies first.
4. **View** (`lib/ui/features/<feature>/views/`) — a `StatefulWidget` that fetches the repository via `GetIt.instance<XRepository>()` and holds state with `setState`. Check sibling files in the same feature folder before picking a file-naming style (this repo mixes `kebab-case`, `dot.separated`, and `snake_case` across features — match the folder you're adding to, don't introduce a fourth convention). Any user-facing text the view introduces goes through [flutter-add-locale-string](../flutter-add-locale-string/SKILL.md), and any custom colors through [flutter-theme-and-styling](../flutter-theme-and-styling/SKILL.md).
5. **Mobile vs desktop** — if the feature needs a distinct desktop layout, see the [flutter-mobile-desktop-variant](../flutter-mobile-desktop-variant/SKILL.md) skill instead of duplicating this one.
6. **Route** — add the route in [lib/routing.dart](../../../lib/routing.dart), following the `!isDesktop ? MobileView() : DesktopView()` pattern already used there. See [flutter-add-route](../flutter-add-route/SKILL.md) for the path constants, `state.extra` caveats, and the auth-guard allowlist.
7. **Verify** — `flutter analyze` then `flutter test`. If you touched a model with JSON (de)serialization, add a test similar to [test/models/main_account_model_test.dart](../../../test/models/main_account_model_test.dart).

## Common mistake to avoid

Agent-facing docs have drifted before, describing an older `lib/services/`, `lib/models/` layout. The real paths are `lib/data/services/`, `lib/data/repositories/`, `lib/data/models/`, `lib/domain/models/`. Trust the filesystem over any doc if they drift again.
