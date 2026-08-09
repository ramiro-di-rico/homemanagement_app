---
name: flutter-release-build
description: Cut a release build for Android or Linux, including version bump and signing. Use when asked to build, package, or ship a release — signing credentials come from a gitignored file or env vars, and an unsigned build fails late and confusingly.
---

# Release builds

## 1. Bump the version

Single source of truth is `version:` in [pubspec.yaml](../../../pubspec.yaml) — currently `1.0.10+11`, i.e. `versionName+versionCode`. Android reads both from Flutter's generated `local.properties` (`flutter.versionName` / `flutter.versionCode`), so **do not** hand-edit version numbers in `android/app/build.gradle`. Bump the `+N` build number on every store upload; Play rejects a reused `versionCode`.

## 2. Android signing

[android/app/build.gradle](../../../android/app/build.gradle) resolves the keystore two ways, in this order:

1. **`android/key.properties`** if it exists (gitignored — it is not in the repo and must not be committed).
2. **Environment variables** otherwise: `KEY_STORE_PASSWORD`, `KEY_PASSWORD`, `ALIAS`, `KEY_PATH`.

Local builds normally use `key.properties`; CI uses the env vars. If neither is present the release build fails at signing. **Never** print, echo, or commit these values, and never paste keystore passwords into a file for someone else — the person building supplies them.

## 3. Build

```bash
flutter build apk --release --split-per-abi
```

```bash
flutter build linux --release
```

Split-per-ABI produces one APK per architecture under `build/app/outputs/flutter-apk/`. For a Play Store upload use an app bundle instead:

```bash
flutter build appbundle --release
```

## 4. Before shipping

Run these and confirm they pass — a release build does not run them for you:

```bash
flutter analyze && flutter test
```

## Known issues to check first

- **`applicationId` is still `com.example.homemanagement_app`** ([android/app/build.gradle:60](../../../android/app/build.gradle)). That is the Flutter template default. It cannot be changed after the first Play Store upload, so if this app is not yet published, fix it *before* the first release. Confirm with the owner rather than changing it unilaterally — if it is already published, changing it creates a second, unrelated listing.
- **Both Groovy and Kotlin DSL build files exist** (`build.gradle` and `build.gradle.kts`, at both `android/` and `android/app/`). Only the Groovy `android/app/build.gradle` contains the real signing configuration; `build.gradle.kts` still has the template's `signingConfig = signingConfigs.getByName("debug")`. Confirm which one Gradle actually resolved before trusting a release build — a build that silently used the `.kts` file is **debug-signed**. Verify with:
  ```bash
  keytool -printcert -jarfile build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
  ```
  If the certificate says `CN=Android Debug`, the wrong file was used. The duplicate build files are worth cleaning up separately.
