---
name: flutter-theme-and-styling
description: Style a widget or change app-wide appearance across light and dark themes. Use when picking colors, adding a styled widget, or when something looks wrong in one theme — the repo has two hand-maintained themes that do not share a color source.
---

# Theming and styling

Two themes, both under `lib/ui/core/themes/`:
[light_theme.dart](../../../lib/ui/core/themes/light_theme.dart) and
[dark_theme.dart](../../../lib/ui/core/themes/dark_theme.dart). Each is a static
`create()` returning `ThemeData.light()/.dark().copyWith(...)`, wired in
[myapp.dart](../../../lib/myapp.dart):

```dart
theme: LightTheme.create(),
darkTheme: DarkTheme.create(),
themeMode: identityUserRepository.themeMode,
```

The active mode is user-controlled and persisted through `IdentityUserRepository`, so **both themes are reachable at runtime** — neither is a theoretical fallback.

## Rules

1. **Prefer `Theme.of(context)` over literal colors.** Read `Theme.of(context).colorScheme.primary`, `.surface`, `.error`, and the text styles from `Theme.of(context).textTheme`. A literal `Colors.white` is invisible in exactly one of the two themes, and nothing in CI catches that.
2. **App-wide component appearance belongs in both theme files.** If you're styling every `ElevatedButton` or the bottom nav, edit `light_theme.dart` *and* `dark_theme.dart` — the existing `bottomNavigationBarTheme` / `elevatedButtonTheme` / `outlinedButtonTheme` entries are the pattern. The two files are maintained by hand and share no common color constants, so a change to one is almost always a change to both.
3. **One-off styling stays inline** in the widget. Don't add a theme override for a single screen.
4. **Semantic colors need a theme-aware choice.** "Income green / expense red" reads very differently on a dark surface — pick the shade per theme rather than reusing one constant.

## Steps

1. Decide app-wide (theme files) vs. one-off (inline), per rule 2 and 3.
2. Make the change in both theme files if app-wide.
3. `flutter analyze`.
4. **Verify in both themes.** Run the app and toggle the theme from settings, or temporarily force `themeMode: ThemeMode.dark` in `myapp.dart` to check — reverting the temporary change before committing. Screenshot-check anything with custom colors; this is the only real safety net here.

## Gotcha

`LightTheme.create()` returns `ThemeData?` (nullable) even though it never returns null. Match the existing signature if you edit it rather than tightening the type in passing — `myapp.dart` passes it straight into `MaterialApp.router`, which accepts the nullable value.
