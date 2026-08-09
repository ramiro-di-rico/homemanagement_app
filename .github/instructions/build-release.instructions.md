---
applyTo: "android/**,linux/**,windows/**,macos/**,ios/**,pubspec.yaml,.github/workflows/**"
---

# Build and release

Full procedure: `.claude/skills/flutter-release-build/SKILL.md`.

## Versioning

`version:` in `pubspec.yaml` is the only source of truth (`versionName+versionCode`).
Android reads both from Flutter's generated `local.properties`. **Never** hand-edit
version numbers in `android/app/build.gradle`. Bump the build number on every
store upload.

## Signing

`android/app/build.gradle` resolves the keystore from `android/key.properties`
(gitignored) if present, otherwise from the env vars `KEY_STORE_PASSWORD`,
`KEY_PASSWORD`, `ALIAS`, `KEY_PATH`. Never print, echo, or commit these values.

## Known traps

- `applicationId` is still the template default
  `com.example.homemanagement_app`. It cannot be changed after the first Play
  Store upload — confirm with the repo owner before touching it.
- Both Groovy and Kotlin DSL Gradle files exist (`build.gradle` **and**
  `build.gradle.kts`, at `android/` and `android/app/`). Only the Groovy
  `android/app/build.gradle` has the real signing config; the `.kts` still has
  the template's debug signing. A release built from the wrong file is
  **debug-signed** — verify with `keytool -printcert -jarfile <apk>`.

## Commands

```bash
flutter build apk --release --split-per-abi
```

```bash
flutter build linux --release
```

Always `flutter analyze && flutter test` before a release build.
