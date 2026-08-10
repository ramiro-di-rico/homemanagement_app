---
name: flutter-add-locale-string
description: Add or change a user-facing string across all supported locales. Use whenever a code change introduces new UI text, to keep the .arb files and generated app_localizations*.dart in sync instead of hand-patching the generated files.
---

# Adding a localized string

Localization is driven by [l10n.yaml](../../../l10n.yaml): template is `lib/l10n/app_en.arb`, generated output is `lib/l10n/app_localizations*.dart`. Supported locales in this repo: `en`, `es`, `es_ar`, `it`, `pt`.

## Steps

1. Add the key to **`lib/l10n/app_en.arb`** first (it's the template — new keys must exist here). Use a simple key name and, if the string takes parameters, an ICU placeholder plus a `@key` metadata block (copy the shape of a neighboring entry with placeholders).
2. Add the same key with a translated value to **every other `.arb` file**: `app_es.arb`, `app_es_ar.arb`, `app_it.arb`, `app_pt.arb`. Do not leave a locale missing the key — that produces a runtime fallback to English silently, not a build error.
3. Regenerate the Dart bindings instead of hand-editing them:
   ```bash
   flutter gen-l10n
   ```
   This rewrites `app_localizations.dart` and the per-locale `app_localizations_<code>.dart` files. Never edit those generated files by hand — the next `gen-l10n` run will overwrite manual edits silently.
4. Use the string in code via `AppLocalizations.of(context)!.yourKey`, matching existing call sites.
5. Run `flutter analyze` — a key present in some locales but not others, or a malformed ICU placeholder, surfaces as an analyzer/build error at this step.

## Common mistake to avoid

Don't translate only `app_en.arb` and regenerate — `flutter gen-l10n` will happily generate a build where `es`/`it`/`pt` fall back to missing-string behavior for that key. Always add the key to all five `.arb` files in the same change.
