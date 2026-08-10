# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Run on a specific device
flutter run -d linux   # or android, chrome, etc.

# Analyze / lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Regenerate localizations after editing lib/l10n/*.arb
flutter gen-l10n

# Build
flutter build apk --release --split-per-abi   # Android
flutter build linux --release                  # Linux (needs cmake installed)
flutter build web --release                    # Web
```

## Architecture

This is a **Flutter personal finance app** supporting mobile (Android/iOS), desktop (Linux), and web. It manages accounts, transactions, budgets, recurring payments, bank statement reconciliation, and shared household access via invitations.

### Layout

```
lib/
  data/          services (HTTP), repositories, and API-shaped models
  domain/        domain models
  ui/
    core/        shared widgets, screens, themes, converters, mixins, extensions
    features/    one folder per feature, each with a views/ folder
  l10n/          .arb translations plus the generated app_localizations*.dart
  main.dart      entry point and dependency registration
  routing.dart   GoRouter configuration
```

`lib/domain/use_cases/` exists but is empty — business logic lives in the repositories today.

### Dependency Injection

The app uses **GetIt** as a service locator (no BLoC/Provider/Riverpod). Registration is **hand-written** in `lib/main.dart`, in `registerDependencies()`, `registerServices()` and `registerSingletons()`. The `injectable` package is a dependency but is not used: there is no `@injectable`/`@Injectable()` code generation in this repo, so a new service or repository has to be registered by hand — don't add those annotations expecting them to be picked up. Widgets retrieve dependencies via `GetIt.I<T>()` or the equivalent `GetIt.instance<T>()`; both spellings are in use.

### Data Flow

```
HTTP Service  →  Repository (ChangeNotifier)  →  Widget (via GetIt)
```

- **`lib/data/services/`** — HTTP calls to the backend API, one class per resource (e.g. `TransactionService`, `AccountService`). Most go through `ApiServiceFactory`, which owns the base URL, the auth headers and the success checks; a few use the `HttpApiServiceMixin` instead, which supports query parameters but does not refresh an expired token. Infra services live here too (`Caching`, `AuthenticationService`, `CryptographyService`, and platform detection under `lib/data/services/platform/`).
- **`lib/data/repositories/`** — Wrap the services, hold the in-memory state, report failures through `NotifierService`, and extend `ChangeNotifier` so views can rebuild on change. Views should call repositories, not services, directly.
- **`lib/data/models/`** — API/deserialization models. **`lib/domain/models/`** — a smaller set of clean domain models; most features don't have a separate domain layer yet.
- **`lib/ui/features/*/views/`** — Widgets that call repositories directly. State is held in the widgets with `setState`, or driven by a repository through `AnimatedBuilder`/`ListenableBuilder`. Only `authentication` has a `view_models/` folder using `ChangeNotifier` — that MVVM split is the exception, not yet the norm.
- File naming inside `views/` is inconsistent across features (`account.list.dart`, `account-list-desktop.dart`, `main_account.list.dart` all coexist) — match the convention already used in the folder you're editing rather than picking a new one.

### Navigation

GoRouter is configured in `lib/routing.dart`. An authentication guard redirects unauthenticated users to `/login_screen`. Routes under `/home_screen` require authentication. The app supports deep links (handled by `DeepLinkService`) including QR-scanned invite links.

Screens declare their own route constants: `path` for the child segment and `fullPath` for the absolute one. Navigation passes models with GoRouter's `extra` rather than through path parameters — e.g. `context.go(AccountDetailScreen.fullPath, extra: account)`.

Key route hierarchy:
- `/login_screen`, `/registration_screen`, `/2fa_screen`, `/reset_password` — auth flow (mobile and desktop variants)
- `/home_screen` — authenticated shell, with `/account_detail_screen` (and its nested `/account_metrics_screen`), `/settings_screen`, `/statistics`, `/budget`, `/invites`, `/logging_screen`, `/transactions_search_desktop_view`, `/transactions_search_statistics`, `/bulk_transactions`, `/reconciliation`

### Platform Awareness

`PlatformContext` (in `lib/data/services/platform/`) is an abstract class with mobile, desktop and web implementations, selected at runtime by `AppPlatformResolver`. Many views have separate mobile and desktop implementations (e.g. `AccountDetailScreen` vs. `AccountDetailDesktop`), and `routing.dart` picks the right one per route with a `!isDesktop ? Mobile() : Desktop()` ternary — full-screen variants are separate widget trees, not one responsive widget with breakpoints.

### Authentication & Security

`AuthenticationService` manages JWT tokens, biometric auth (via `local_auth` on mobile), and secure storage. `CryptographyService` provides AES encryption for sensitive local data.

### Localization

Translations live in `lib/l10n/*.arb` (`en` is the template, plus `es`, `es_AR`, `it`, `pt`). The generated `app_localizations*.dart` files are **checked into the repo**, so run `flutter gen-l10n` after editing any `.arb` and commit the result. **Never hand-edit `app_localizations*.dart`** — the next `gen-l10n` run overwrites manual changes silently. Non-English locales are partially translated and fall back to English for missing keys. See the `flutter-add-locale-string` skill for the full workflow.

### Key Infrastructure

- **`lib/data/services/api.service.factory.dart`** — HTTP plumbing shared by every service
- **`lib/data/services/caching.dart`** — In-memory cache for API responses (no TTL, no eviction; invalidation is manual)
- **`lib/data/services/logger_wrapper.dart`**, **`file_logger_output.dart`** — App-wide logging
- **`lib/data/services/error_notifier_service.dart`** — `NotifierService`, how repositories surface errors to the UI
- **`lib/data/services/platform/platform_context.dart`** — Platform detection
- **`lib/data/models/`** — Shapes that mirror API responses (e.g. `reconciliation.dart`)
- **`lib/domain/models/`** — Domain models used across the UI
- **`lib/ui/features/*/view_models/`** — UI-specific data shapes (only present in the `authentication` feature today)

### Testing

Coverage is thin but no longer a single smoke test: `test/widget_test.dart` (full-app smoke test), `test/models/` (`main_account_model_test.dart`, `reconciliation_model_test.dart`), `test/views/reconciliation_screen_test.dart` (screen-level widget test), and `test/localized_number_input_formatter_test.dart`. No mocking library (`mockito`/`mocktail`) is set up — check `pubspec.yaml` before assuming one is available. See the `flutter-write-widget-test` skill for the patterns to follow.

## Agent skills

Task-specific procedures live in `.claude/skills/<name>/SKILL.md` — read the matching one before adding an HTTP call, a cached response, a route, user-facing text, a desktop variant, a theme change, a test, or a release build. `AGENTS.md` is the shared entry point and indexes them; `.junie/skills/` and `.github/instructions/` point at the same files for other tools.
