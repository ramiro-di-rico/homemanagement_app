---
applyTo: "test/**/*.dart"
---

# Tests

Full procedure: `.claude/skills/flutter-write-widget-test/SKILL.md`.

Coverage is currently minimal — `test/widget_test.dart` (a full-app smoke test)
and `test/models/main_account_model_test.dart`. There is **no dense set of
examples to copy from**, and **no mocking library** (`mockito` / `mocktail`) in
`pubspec.yaml`. Check before assuming one is available; do not add a dependency
without asking.

- **Model tests** — plain `test()`/`group()`, construct the model directly,
  assert on `toJson()`/`fromJson()` and computed getters. Put them in
  `test/models/`.
- **Widget tests** — follow `test/widget_test.dart`'s setup: build the platform
  via `PlatformStrategy.createPlatform()`, call `registerDependencies(platform)`,
  and set `tester.view.physicalSize`. Note that this registers the **real**
  services through GetIt, so anything hitting the network is not isolated.

Run:

```bash
flutter test
```
