---
applyTo: "lib/ui/**/*.dart,lib/routing.dart,lib/myapp.dart"
---

# UI layer (views, routing, theming)

Full procedures: `.claude/skills/flutter-mobile-desktop-variant/SKILL.md`,
`.claude/skills/flutter-add-route/SKILL.md`,
`.claude/skills/flutter-theme-and-styling/SKILL.md`,
`.claude/skills/flutter-add-locale-string/SKILL.md`.

## Views

Views live in `lib/ui/features/<feature>/views/` and are `StatefulWidget`s that
fetch repositories via `GetIt.instance<XRepository>()` and hold state with
`setState`. Only the `authentication` feature uses a `view_models/` ChangeNotifier
split — that is the exception, not the norm to spread.

**File naming is inconsistent by design of history**: `account.list.dart`,
`account-list-desktop.dart`, and `main_account.list.dart` all coexist. Match the
folder you are editing; never introduce a fourth convention.

## Mobile vs. desktop

Full screens are **two separate widget trees**, chosen at the router:

```dart
builder: (context, state) => !isDesktop ? SomeScreen() : SomeDesktopView(),
```

Do not convert these into one responsive widget. Use `LayoutBuilder`/`MediaQuery`
only for small in-page adjustments. Both variants read the same repository state —
fork layout, never business logic.

## Routing

Paths are `static const String path` / `fullPath` declared on the screen widget
and referenced from `lib/routing.dart` — never string literals in the router.

**A route that must work while logged out has to be allowlisted in the `redirect`
guard** (alongside `isPublicInviteRoute` / `isRegistrationRoute` / `isLoginRoute`),
or it silently redirects to login.

`state.extra` is used to pass whole objects, but it does not survive a deep link,
a web refresh, or process death. Anything reachable by URL takes a path parameter
and loads the entity itself. Externally reachable links also need handling in
`deep_link_service.dart`.

## Theming

Both `LightTheme` and `DarkTheme` are user-reachable at runtime. Prefer
`Theme.of(context)` over literal colors — a hardcoded `Colors.white` is invisible
in one theme and nothing catches it. App-wide component styling must be edited in
**both** `lib/ui/core/themes/light_theme.dart` and `dark_theme.dart`; they share
no color constants.

## Text

Every user-facing string goes in `lib/l10n/app_en.arb` **and** every other locale
(`es`, `es_ar`, `it`, `pt`), then `flutter gen-l10n`. Never hand-edit
`app_localizations*.dart`. Read via `AppLocalizations.of(context)!.yourKey`.
