---
name: flutter-write-widget-test
description: Write a Flutter test for a model, repository, or widget in this repo. Use when adding test coverage — the repo has almost none, so there's no dense set of examples to copy from; this skill fills that gap.
---

# Writing a test in this repo

`test/` currently has only three files: [test/widget_test.dart](../../../test/widget_test.dart) (one full-app smoke test), and [test/models/main_account_model_test.dart](../../../test/models/main_account_model_test.dart) (a plain model JSON test). There is no existing pattern for testing a Repository or a Service — pick the shape below closest to what you're testing.

## Model tests (JSON round-trip, business logic on a model)

Plain `test()`/`group()`, no widget pump needed. Follow [test/models/main_account_model_test.dart](../../../test/models/main_account_model_test.dart): construct the model directly, assert on `toJson()`/`fromJson()` shape and any computed getters. Put these in `test/models/`.

## Widget/screen tests

Follow [test/widget_test.dart](../../../test/widget_test.dart)'s setup:
```dart
var platform = PlatformStrategy.createPlatform();
registerDependencies(platform); // registers real services via GetIt — see note below
tester.view.physicalSize = Size(1920, 1080);
tester.view.devicePixelRatio = 1.0;
addTearDown(() => tester.view.reset());
await tester.pumpWidget(MyApp(platform));
```
Because `registerDependencies()` wires real HTTP-backed services (no fakes/mocks are set up in this repo yet), a widget test that reaches a real repository call will hit the network. Prefer testing widgets that don't trigger a repository call in `initState`/build, or register a fake implementation in GetIt *after* `registerDependencies()` and *before* `pumpWidget` for the specific service/repository under test — `GetIt.instance.unregister<T>()` then `registerFactory` a fake.

## Steps

1. Decide model vs. widget test per the above.
2. Place the file under `test/`, mirroring the `lib/` path of what's under test (e.g. a test for `lib/data/repositories/account.repository.dart` goes in `test/repositories/account_repository_test.dart` — this subfolder doesn't exist yet, create it).
3. Run the single file while iterating: `flutter test test/path/to/test_file.dart`.
4. Run the full suite before finishing: `flutter test`.

## Common mistake to avoid

Don't assume mocking infrastructure (e.g. `mockito`/`mocktail`) is already set up — check `pubspec.yaml`'s `dev_dependencies` first. If it's missing and you need it, that's a dependency change to flag to the user, not something to add silently.
