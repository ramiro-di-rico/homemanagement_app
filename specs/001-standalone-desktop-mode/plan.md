# Implementation Plan: Standalone Desktop Mode

**Branch**: `feat/standalone-desktop-mode` | **Date**: 2026-10-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-standalone-desktop-mode/spec.md`

## Summary

Desktop users can choose "Use without an account" and work with accounts, categories and transactions stored in an encrypted local SQLite database. They can later register and move that data, once, into their new online account.

Technically, the repositories get a data-source seam: interfaces implemented by the existing HTTP services and by new drift-backed local services. A mode-aware delegate routes each call according to `AppModeService`. The router and the desktop UI hide everything server-only while local mode is active. An import service replays local data against the existing API with no backend change. Server accounts carry temporary names while transactions are sent, which prevents the server's automatic transfer pairing. The service then restores the names and archives the local database file. Users can also leave local mode by logging in to an existing account, which keeps the local data on the computer.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.47.6 (stable)

**Primary Dependencies**:
- **Existing**: GetIt (hand-wired DI), go_router, shared_preferences, path_provider, http.
- **New runtime**:
  - drift 2.35.2
  - drift_flutter 0.3.1
  - sqlite3 3.7.0, pinned, with the `sqlite3mc` build-hook source
  - flutter_secure_storage 10.3.4 (11.x needs win32 ^6, which conflicts with file_picker 10.x; see research R1)
- **New dev**: drift_dev 2.35.1, build_runner 2.16.2.
- All are ≥7 days old; see [research.md](./research.md) R1–R2.

**Storage**:
- **Local mode**: one SQLite file encrypted with SQLite3MultipleCiphers, in `getApplicationSupportDirectory()`. Key in the OS keyring.
- **Online mode**: unchanged (backend API).
- **Mode flag**: SharedPreferences.

**Testing**: `flutter test`.
- **Local data sources**: drift in-memory database.
- **Import service**: hand-written fake remote data sources implementing the new interfaces (no mocking library in the repo).
- **Login, home and router guard**: widget tests, following `test/views/login_view_test.dart`.

**Target Platform**: Linux, Windows and macOS desktop builds (`PlatformType.Desktop`). Web and mobile are unaffected and never see local mode.

**Project Type**: Flutter client app. No backend changes; `../homemanagement-api` is only used to verify behaviour and to run a local backend for testing.

**Performance Goals**:
- Local CRUD and balance refresh feel instant (<100 ms for 1,000 transactions across 5 accounts).
- The import of 5 accounts, 20 categories and 1,000 transactions finishes in under 2 minutes (SC-004).

**Constraints**:
- Zero network calls in local mode (FR-004).
- The app never runs on an unencrypted database (FR-014).
- The local file is never overwritten or wiped automatically.
- The import is idempotent and resumable (FR-021).

**Scale/Scope**:
- Single user, single local dataset per OS user, up to around 10⁴ transactions.
- About 6 new files in `lib/data/local/`, 5 interfaces, about 12 modified views and services.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the **unfilled template**, so there are no ratified principles to gate on. The repo's own rules from `CLAUDE.md` and `.claude/skills/` are used as the gate instead:

| Gate | Status |
|---|---|
| Views call repositories, not services. New logic goes in repositories/services. `lib/domain/use_cases/` stays empty | ✅ Import orchestration is a service plus a `ChangeNotifier` repository for progress. The six views that call `TransactionService` directly only get *hidden* in local mode, not rewired |
| DI hand-registered in `main.dart`; no `injectable` annotations | ✅ |
| Desktop variants are separate widget trees (`!isDesktop ? Mobile() : Desktop()`) | ✅ Only desktop widgets change |
| New user-facing text goes through `.arb` + `flutter gen-l10n`; generated files never hand-edited | ✅ Required for all new strings |
| New public route must be allowlisted in the guard (`flutter-add-route` skill) | ✅ Guard change specified in [contracts/data-sources.md](./contracts/data-sources.md) |
| Light and dark themes are both maintained (`flutter-theme-and-styling`) | ✅ The local-mode banner must use theme colours |
| No mocking library assumed | ✅ Fakes via interfaces |
| Org rule: dependency freshness ≥7 days | ✅ All pinned versions comply; build_runner 2.17.x and sqlite3 3.7.1 avoided |

Post-design re-check: ✅. No violations, so Complexity Tracking stays empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-standalone-desktop-mode/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R11 decisions
├── data-model.md        # Phase 1: local schema, import state machine
├── quickstart.md        # Phase 1: validation guide
├── contracts/
│   ├── data-sources.md  # Client seam, AppModeService, router guard
│   └── backend-import.md# Endpoints used by the import (no backend change)
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart                         # MODIFY: async main, read appMode, open DB, register delegates
├── myapp.dart                        # MODIFY: pass AppModeService to router
├── routing.dart                      # MODIFY: local-mode guard + /home_screen/local_import route
├── data/
│   ├── local/                        # NEW
│   │   ├── local_database.dart       #   drift @DriftDatabase, tables, migrations, seed
│   │   ├── local_database.g.dart     #   generated (committed, like app_localizations*.dart)
│   │   ├── local_database_opener.dart#   key from secure storage, sqlite3mc setup, PRAGMA cipher check
│   │   ├── local_account.service.dart
│   │   ├── local_category.service.dart
│   │   ├── local_currency.service.dart
│   │   └── local_transaction.service.dart
│   ├── services/
│   │   ├── sources/                  # NEW: interfaces + ModeAware* delegates
│   │   ├── app_mode.service.dart     # NEW
│   │   ├── local_import.service.dart # NEW: steps 1–6 of the import state machine
│   │   ├── account.service.dart      # MODIFY: implements AccountDataSource; add() returns created
│   │   ├── category.service.dart     # MODIFY: implements CategoryDataSource
│   │   ├── currency.service.dart     # MODIFY: implements CurrencyDataSource
│   │   ├── transaction.service.dart  # MODIFY: implements TransactionDataSource
│   │   └── identity.service.dart     # MODIFY: register() → RegistrationResult
│   └── repositories/
│       ├── account/category/currency/transaction repos  # MODIFY: depend on interfaces
│       └── local_import.repository.dart                 # NEW: progress ChangeNotifier
├── ui/features/
│   ├── authentication/views/login-desktop.dart          # MODIFY: "Use without an account"
│   ├── authentication/views/registration-desktop.dart   # MODIFY: emailTaken; route to import
│   ├── home/views/home-desktop.dart                     # MODIFY: actions + initState loads by mode
│   ├── dashboard/views/dashboard_desktop.dart           # MODIFY: hide metric widgets
│   ├── accounts/views/account-list-desktop.dart         # MODIFY: hide CSV/main accounts
│   ├── accounts/views/account-detail-desktop.dart       # MODIFY: hide metrics
│   ├── accounts/views/widgets/add_transaction_sheet_desktop.dart # MODIFY: hide voice/receipt/tags
│   ├── settings/views/settings_desktop.dart             # MODIFY: hide server sections
│   └── local_mode/views/                                # NEW: banner, import progress/summary, "cannot open" screen
└── l10n/*.arb                                           # MODIFY + gen-l10n

test/
├── data/local/              # NEW: schema, balances, paging, delete rules, migration smoke
├── data/services/           # NEW: local_import.service (fakes), mode-aware delegates
└── views/                   # NEW: login local option (desktop only), guard redirects, home in local mode

pubspec.yaml                 # MODIFY: deps + hooks.user_defines.sqlite3.source: sqlite3mc
macos/Runner/*.entitlements  # MODIFY: keychain-access-groups
```

**Structure Decision**: the existing `lib/data` / `lib/ui/features` layering is kept. Local persistence gets its own `lib/data/local/` folder, so the drift code and its generated file are isolated. Interfaces and delegates live under `lib/data/services/sources/` next to the HTTP services that implement them.

## Delivery phases (each one is a PR)

| # | Phase | Contents | Depends on |
|---|---|---|---|
| 0 | Spike | `pub get` resolve. Open a sqlite3mc database with a keyring key in a **release** Linux build, check `PRAGMA cipher`, and confirm the file is unreadable without the key. Repeat on Windows and macOS if available | — |
| 1 | Seam (refactor) | Interfaces; HTTP services implement them; repositories depend on interfaces; `AccountService.add` returns the created account. **No behaviour change** | — |
| 2 | Local data | drift schema and seed, opener with encryption, local services, tests | 0, 1 |
| 3 | Mode + entry | `AppModeService`, delegates, async `main`, router guard, login option, "cannot open local data" screen | 2 |
| 4 | Local-mode UI | Hide server-only UI (FR-015), banner (FR-017), "Log in to an existing account" (FR-027), l10n | 3 |
| 5 | Import | `RegistrationResult`, import service (temporary account names, R6) and repository, progress/summary screen, archive and switch | 3 |

Before Phase 1, consider merging `feat/price-to-amount` (research R11).

## Risks

| Risk | Mitigation |
|---|---|
| sqlite3mc not bundled in release builds, or the cipher check fails on one OS | Phase 0 spike gates everything else |
| No Secret Service on a user's Linux desktop | Local mode refuses to start, with a clear message (R2). Document `libsecret` and gnome-keyring in the README |
| Server's transfer mirroring adds extra transactions during the import | All server accounts carry unique temporary names while transactions are sent, then get their real names back (R6). Quickstart Q10 verifies it |
| Import fails and is never resumed, leaving temporary account names online | The user stays in local mode with a Resume banner. Resuming renames them |
| User edits local data after a failed import → edits silently lost | Local writes are locked while an import is pending (FR-022, data-model) |
| Ambiguous network failure mid-import → duplicates | Per-account atomic bulk plus a "server account already has transactions" check (R6) |
| Views holding stale repository data after a mode flip | Delegates plus an explicit reload of the Account, Category and Currency repositories on every mode change (R9) |

## Complexity Tracking

No constitution violations to justify.
