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

The app uses **GetIt** as a service locator (no BLoC/Provider/Riverpod). Registration is **hand-written** in `lib/main.dart`, in `registerDependencies()`, `registerServices()` and `registerSingletons()`. The `injectable` package is a dependency but is not used: there is no code generation for DI, so a new service or repository has to be registered by hand. Widgets retrieve dependencies via `GetIt.I<T>()`.

### Data Flow

```
HTTP Service  →  Repository (ChangeNotifier)  →  Widget (via GetIt)
```

- **`lib/data/services/`** — HTTP calls to the backend API, one class per resource (e.g. `TransactionService`, `AccountService`). They all go through `ApiServiceFactory`, which owns the base URL, the auth headers and the success checks.
- **`lib/data/repositories/`** — Wrap the services, hold the in-memory state, report failures through `NotifierService`, and extend `ChangeNotifier` so views can rebuild on change.
- **`lib/ui/features/*/views/`** — Widgets that call repositories directly. State is held in the widgets with `setState`, or driven by a repository through `AnimatedBuilder`/`ListenableBuilder`.

### Navigation

GoRouter is configured in `lib/routing.dart`. An authentication guard redirects unauthenticated users to `/login_screen`. Routes under `/home_screen` require authentication. The app supports deep links (handled by `DeepLinkService`) including QR-scanned invite links.

Screens declare their own route constants: `path` for the child segment and `fullPath` for the absolute one. Navigation passes models with GoRouter's `extra` rather than through path parameters — e.g. `context.go(AccountDetailScreen.fullPath, extra: account)`.

Key route hierarchy:
- `/login_screen`, `/registration_screen`, `/2fa_screen`, `/reset_password` — auth flow (mobile and desktop variants)
- `/home_screen` — authenticated shell, with `/account_detail_screen` (and its nested `/account_metrics_screen`), `/settings_screen`, `/statistics`, `/budget`, `/invites`, `/logging_screen`, `/transactions_search_desktop_view`, `/transactions_search_statistics`, `/bulk_transactions`, `/reconciliation`

### Platform Awareness

`PlatformContext` (in `lib/data/services/platform/`) is an abstract class with mobile, desktop and web implementations, selected at runtime by `AppPlatformResolver`. Many views have separate mobile and desktop implementations (e.g. `AccountDetailScreen` vs. `AccountDetailDesktop`), and `routing.dart` picks the right one.

### Authentication & Security

`AuthenticationService` manages JWT tokens, biometric auth (via `local_auth` on mobile), and secure storage. `CryptographyService` provides AES encryption for sensitive local data.

### Localization

Translations live in `lib/l10n/*.arb` (`en` is the template, plus `es`, `es_AR`, `it`, `pt`). The generated `app_localizations*.dart` files are **checked into the repo**, so run `flutter gen-l10n` after editing any `.arb` and commit the result. Non-English locales are partially translated and fall back to English for missing keys.

### Key Infrastructure

- **`lib/data/services/api.service.factory.dart`** — HTTP plumbing shared by every service
- **`lib/data/services/caching.dart`** — In-memory cache for API responses
- **`lib/data/services/logger_wrapper.dart`**, **`file_logger_output.dart`** — App-wide logging
- **`lib/data/services/error_notifier_service.dart`** — `NotifierService`, how repositories surface errors to the UI
- **`lib/data/models/`** — Shapes that mirror API responses (e.g. `reconciliation.dart`)
- **`lib/domain/models/`** — Domain models used across the UI
