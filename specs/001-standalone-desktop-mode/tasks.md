---

description: "Task list for Standalone Desktop Mode"
---

# Tasks: Standalone Desktop Mode

**Input**: Design documents from `/specs/001-standalone-desktop-mode/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. The spec doesn't explicitly ask for TDD, but plan.md's *Testing* section defines the test strategy: an in-memory drift database for the local services, hand-written fakes for the import service (the repo has no mocking library), and widget tests for login, home and the guard. Follow `.claude/skills/flutter-write-widget-test/SKILL.md`.

**Organization**: Tasks are grouped by user story (spec.md: US1 P1, US2 P1, US3 P2, US4 P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story the task belongs to (US1–US4)
- Paths are relative to the repo root. `../homemanagement-api` is the sibling backend repo. It is only read or run locally; no backend changes are made.

## Repo conventions every task must follow

- DI is hand-registered in `lib/main.dart`. Never add `@injectable` annotations.
- New user-facing text goes through `lib/l10n/app_en.arb` (template) plus the other `.arb` files, then `flutter gen-l10n`. Never hand-edit `app_localizations*.dart`. See `.claude/skills/flutter-add-locale-string/SKILL.md`.
- Desktop-only changes. Don't touch mobile widget trees.
- Local mode is available only when `GetIt.I<PlatformContext>().getPlatformType() == PlatformType.Desktop`. **Not** the `isDesktop` flag in `lib/myapp.dart`, which also includes Web.
- Match the file-naming convention of the folder you edit.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, platform configuration, and the encryption spike that gates everything else.

- [X] T001 Add dependencies to `pubspec.yaml`:
  - `drift: 2.35.2`, `drift_flutter: 0.3.1`, `sqlite3: 3.7.0` (exact pin; 3.7.1 is <7 days old) and `flutter_secure_storage: 10.3.4` under `dependencies`. (Changed from 11.2.0: 11.x needs `win32 ^6`, which conflicts with `file_picker 10.3.10`. See research R1.)
  - `drift_dev: 2.35.1` and `build_runner: 2.16.2` under `dev_dependencies`.
  - A top-level `hooks: user_defines: sqlite3: source: sqlite3mc` block.
  - Do **not** add `sqlite3_flutter_libs` or `sqlcipher_flutter_libs`.
  - Run `flutter pub get` and confirm it resolves (analyzer 14.3–14.5 expected). Done: resolves with analyzer 14.5.0, drift 2.35.2, drift_dev 2.35.1, drift_flutter 0.3.1, sqlite3 3.7.0, build_runner 2.16.2, flutter_secure_storage 10.3.4.
  - Before adding, re-check that every version is still the newest one ≥7 days old (org rule).
- [X] T002 [P] Add the `keychain-access-groups` entitlement (`$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`) to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` (needed by flutter_secure_storage, research R2).
- [X] T003 [P] Add `lib/data/local/*.g.dart` to `analyzer: exclude:` in `analysis_options.yaml`. That file already has an uncommitted `exclude` block from other work, so extend it rather than replace it, and coordinate with its owner before committing. Done: added to the existing `exclude` block and verified with a temporary error in a `.g.dart` file (ignored) next to one in a normal file (reported). `analysis_options.yaml` is left uncommitted together with its other in-progress changes.
- [X] T004 [P] Document desktop build and runtime prerequisites in `README.md`:
  - Linux: `libsecret-1-dev` to build; `libsecret-1-0` and a Secret Service (gnome-keyring/KWallet) at runtime.
  - Windows: ATL in VS Build Tools.
  - macOS: the keychain entitlement.
  - The sqlite3 build hook downloads from GitHub on the first build (`HTTPS_PROXY`, `url_pattern`).
- [X] T005 Encryption spike on a throwaway scratch branch (not merged):
  - Open a drift database via `driftDatabase(name: 'spike', native: DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory, setup: (db) => db.execute("PRAGMA key = '<hex key from flutter_secure_storage>'")))`.
  - Run `PRAGMA cipher` and check it returns a row.
  - Build `flutter build linux --release` and confirm the sqlite3mc library is under `build/linux/x64/release/bundle/lib/`.
  - Confirm `head -c 16` of the file is not `SQLite format 3`.
  - Record the outcome by replacing the "Unverified (spike)" bullets in `specs/001-standalone-desktop-mode/research.md` R2.
  - **If it fails, stop and revisit R2 (fallback: `source: sqlcipher`).**
  - **Result: PASSED on Linux x64 (release build).** Details, the build fix and the keyring finding are in `research.md` R2. Summary:
    - `PRAGMA cipher` returns `chacha20`. The file header is random bytes. No key or a wrong key is rejected. The right key reopens the data.
    - **A build fix was required and is applied**: `linux/CMakeLists.txt` and `windows/CMakeLists.txt` now install `build/native_assets/<os>/` into the bundle. Without it the release bundle contained no SQLite library. The Windows change matches Flutter's current template but is untested.
    - When run from a snap IDE terminal, libsecret used its file backend instead of the Secret Service. Both stored the key correctly.
    - The spike code was throwaway and has been deleted, and its test keys and files were removed.

**Checkpoint**: Dependencies resolve and encrypted open works in a release build.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**:
- The data-source seam. This is a behaviour-neutral refactor, shippable on its own as PR 1.
- The encrypted local database and its services.
- The app-mode switch.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Seam (refactor, no behaviour change; contracts/data-sources.md)

- [X] T006 [P] Create `abstract interface class AccountDataSource` in `lib/data/services/sources/account_data_source.dart`, with exactly the signatures in `specs/001-standalone-desktop-mode/contracts/data-sources.md`:
  - `fetchAccounts()`
  - `Future<AccountModel> add(AccountModel)`
  - `update`
  - `delete`

  Also define `AccountHasTransactionsException` in the same file.
- [X] T007 [P] Create `abstract interface class CategoryDataSource` in `lib/data/services/sources/category_data_source.dart`:
  - `fetch()`
  - `Future<CategoryModel> add`
  - `update`
  - `delete`

  Also define `CategoryInUseException` in the same file.
- [X] T008 [P] Create `abstract interface class CurrencyDataSource` (`fetchCurrencies()`) in `lib/data/services/sources/currency_data_source.dart`.
- [X] T009 [P] Create `abstract interface class TransactionDataSource` in `lib/data/services/sources/transaction_data_source.dart`:
  - `page`
  - `pageNameFiltering`
  - `suggested`
  - `Future<TransactionWithBalanceModel> add`
  - `update`
  - `delete(int id)`
- [X] T010 Make `AccountService` in `lib/data/services/account.service.dart` implement `AccountDataSource`:
  - Rename `fetchAccounts` only if needed to match the interface.
  - Change `add` to use `apiServiceFactory.postWithReturn('account', …)` and return `AccountModel.fromJson(result)`. The server answers 201 + `AccountResultDto` (research R3), and `_isSuccessfulStatusCode` accepts 2xx.
- [X] T011 [P] Make `CategoryService` in `lib/data/services/category.service.dart` implement `CategoryDataSource`. `add` already returns the created `CategoryModel`. `delete` takes a `CategoryModel`; adapt it if it currently takes an id.
- [X] T012 [P] Make `CurrencyService` in `lib/data/services/currency.service.dart` implement `CurrencyDataSource`.
- [X] T013 [P] Make `TransactionService` in `lib/data/services/transaction.service.dart` implement `TransactionDataSource`. No signature changes for `page`, `pageNameFiltering`, `suggested`, `add`, `update` or `delete`.
- [X] T014 Change the repositories to depend on the interfaces instead of the concrete services:
  - `lib/data/repositories/account.repository.dart` (field type `AccountDataSource`). In `add`, append the **returned** model instead of the input with id 0.
  - `lib/data/repositories/category.repository.dart`
  - `lib/data/repositories/currency.repository.dart`
  - `lib/data/repositories/transaction.repository.dart` (field type `TransactionDataSource`)

  Keep constructor parameter names, so the wiring in `lib/main.dart` still compiles with the HTTP services.

  Done. `TransactionRepository` keeps the concrete `transactionService` for the server-only operations (tags, voice and receipt previews) and gains an optional `dataSource: TransactionDataSource` for add/update/delete/page/suggested. It defaults to `transactionService`. T027 passes the mode-aware delegate as `dataSource`.
- [X] T015 Run a refactor regression: `flutter analyze` and `flutter test` must be green. (Automated part done: no analyzer errors, 70 tests pass. Manual online run on Linux: transactions add/edit/delete checked against production; the account and category paths were covered by analyze and tests only. Use `/snap/bin/flutter`: the `flutter` on PATH is 3.41.7, whose Dart is too old for `sdk: ^3.12.0`.) Then run the app online on Linux: add/edit/delete an account, a category and a transaction. Behaviour is unchanged, and a newly added account now has its real id (it can be edited without a reload).

### Local database (data-model.md)

- [X] T016 Create the drift database in `lib/data/local/local_database.dart`: `@DriftDatabase(tables: [Currencies, Accounts, Categories, Transactions, ImportStates])`, `schemaVersion => 1`. Columns and constraints are copied verbatim from `specs/001-standalone-desktop-mode/data-model.md`.

  **Currencies**
  - `id` int PK; `name` text **unique** not null (ISO code); `value` real not null.

  **Accounts**
  - `id` autoincrement; `name` text not null, **"Trimmed, 1–100 chars. Not unique"**.
  - `account_type` int not null (**0 = Cash, 1 = BankAccount**); `currency_id` FK → currencies not null.
  - `measurable` bool **default true**; `archive` bool **default false**; `is_hidden` bool **default false**.
  - `server_id` int nullable **unique**; `transactions_imported` bool not null **default false**.

  **Categories**
  - `id` autoincrement; `name` text not null, **"Trimmed, 1–100 chars. Unique, case-insensitive"** (unique index on `lower(name)`).
  - `icon` text not null; `color` text not null **default `#ffffff`**.
  - `measurable` bool **default true**; `is_active` bool **default true**; `server_id` int nullable **unique**.

  **Transactions**
  - `id` autoincrement; `account_id` FK → accounts **ON DELETE RESTRICT** not null; `category_id` FK → categories **ON DELETE RESTRICT** not null.
  - `name` text not null **"1–200 chars"**; `amount` real not null **"> 0"** (CHECK constraint).
  - `transaction_type` int not null (**0 = Income, 1 = Outcome**); `date` datetime not null (**stored as UTC midnight**); `created_at` datetime not null.
  - Index on `(account_id, date DESC, id DESC)`.

  **ImportStates**
  - Single row with `id` = 1; `status` int not null; `target_email` text nullable; `started_at` datetime nullable; `last_error` text nullable.

  **Migration and seed**
  - `MigrationStrategy`: `beforeOpen` runs `PRAGMA foreign_keys = ON`.
  - `onCreate` seeds the currencies **(1, 'USD', 1), (2, 'ARS', 0), (3, 'EUR', 0)**.
  - `onCreate` also seeds the **17 default categories with the exact names and icons** from `../homemanagement-api/HomeManagement.Database/Seed/CategoryInitializer.cs`: Various, Rent, Transportation, Supplies, Entertainment, Gift, Clothes, Education, Health, Salary, Bond, Services, Savings, Transfers, Donations, Extraction, Deposit. All active, all measurable.
  - `onCreate` inserts the single `import_states` row with `status = notStarted`.

  Done. `ImportStates` also has `import_tag` and `default_account_server_id` (from data-model.md, needed by T065), which this task's column list omitted. `status` is an `intEnum<ImportStatus>` (notStarted, inProgress, failed, completed). Row classes are named `LocalAccount`, `LocalCategory`, etc. to avoid clashing with domain and drift names. The case-insensitive category index and the paging index are created with `customStatement` in `onCreate`, because drift can't declare expression or DESC indexes.
- [X] T017 Run `dart run build_runner build --delete-conflicting-outputs` and commit the generated `lib/data/local/local_database.g.dart`. Generated code is checked in, the same as the l10n output. The spike showed a full run takes about 39 s because drift_dev analyses every Dart file in the repo; consider a `build.yaml` limiting the drift builders to `lib/data/local/**` and check that the output is unchanged.

  Done. `build.yaml` limits drift_dev to `lib/data/local/**`. The first run compiles the builders (~65 s, cached afterwards), and the analysis itself takes ~3 s. Note that newer build_runner ignores `--delete-conflicting-outputs`.
- [X] T018 Create `lib/data/local/local_database_opener.dart` with `Future<LocalDatabase> openLocalDatabase({required String fileName})`:
  - Read the key `local_db_key_v1` from `FlutterSecureStorage`. If it's absent **and the file doesn't exist**, generate 32 random bytes (`Random.secure()`), base64-encode them and store them. If it's absent **and the file exists**, throw `LocalDataUnavailableException(reason: keyMissing)`. Never create a new key for an existing file.
  - Wrap `PlatformException` from secure storage (e.g. `KeyringLocked`) as `LocalDataUnavailableException(reason: keyringUnavailable)`.
  - Open with `driftDatabase(name: <fileName without extension>, native: DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory, setup: (db) { db.execute("PRAGMA key = '$key';"); }))` where `$key` is the base64url string. This is the form the T005 spike verified; the raw `x'<hex>'` form was not tested. Capture only the key **String** in the closure, because it runs in a background isolate.
  - After opening, run `PRAGMA cipher`. If it is empty, close the database and throw `LocalDataUnavailableException(reason: notEncrypted)`.
  - Never delete or overwrite the file on any error path.

  Done. Two additions beyond the task text: a fourth reason, `unreadable`, for a file that exists but fails to open with the stored key (otherwise a raw `SqliteException` would escape `AppModeService.init()`, which only catches `LocalDataUnavailableException`), and optional `secureStorage` and `supportDirectory` parameters so tests can replace the keyring and the directory. A throwaway test against the real sqlite3mc library confirmed: a new key is stored and the file header is not `SQLite format 3`; reopening with the key works; a missing key on an existing file gives `keyMissing` without writing a key; a wrong key gives `unreadable` and leaves the file size unchanged; a locked keyring gives `keyringUnavailable` and creates no file. That test was not kept, since it needs `path_provider_platform_interface` (not a direct dependency) to fake the temp directory.
- [X] T019 [P] Create `lib/data/local/local_currency.service.dart`: `LocalCurrencyService implements CurrencyDataSource`. It returns the seeded rows as `CurrencyModel(id, name, value)`.
- [X] T020 [P] Create `lib/data/local/local_account.service.dart`: `LocalAccountService implements AccountDataSource`.
  - `fetchAccounts` returns `AccountModel` with `userId = 0` and the **derived** balance `COALESCE(SUM(CASE transaction_type WHEN 0 THEN amount ELSE -amount END), 0)` (FR-008), via one grouped query.
  - `add` trims the name, validates "1–100 chars", inserts, and returns the model with its new id and balance 0.
  - `update` covers rename, hide and archive.
  - `delete` throws `AccountHasTransactionsException` if any transaction references the account.
- [X] T021 [P] Create `lib/data/local/local_category.service.dart`: `LocalCategoryService implements CategoryDataSource`.
  - `fetch` returns all rows, including inactive ones (contract C4).
  - `add` and `update` enforce the case-insensitive unique name with a typed `CategoryNameTakenException`.
  - `delete` throws `CategoryInUseException` if any transaction references the category.
- [X] T022 [P] Create `lib/data/local/local_transaction.service.dart`: `LocalTransactionService implements TransactionDataSource`.
  - `page` and `pageNameFiltering` are ordered by `date DESC, id DESC`, using `page.currentPage` and `page.pageCount` (contract C3). Name filter: case-insensitive `LIKE`. `categoryName` is filled by a join, and `tags` is empty.
  - `add` validates `amount > 0`, normalizes `date` to UTC midnight, sets `created_at`, and returns `TransactionWithBalanceModel(transaction with new id, sourceAccount with post-insert balance, targetAccount: null)` (contract C1).
  - `update` and `delete` are plain row operations.
  - `suggested()` returns the 10 most recent transactions with distinct `name`.
  - Read `TransactionModel`'s amount field as `price` or `amount`, whichever `master` has (research R11).

  Done (T019–T022). Notes:
  - Shared pieces: `LocalDatabase.accountBalance`, `lib/data/local/local_mappers.dart` (row to model, and the date conversion), and `CategoryNameTakenException` in `category_data_source.dart`.
  - Invalid input (empty or too long name, amount <= 0) throws `ArgumentError`. T044 will add `LocalWriteFailedException` for failed writes.
  - Dates are stored as UTC midnight of the chosen day and read back as local midnight of that same day, so views show the day the user picked in any time zone. Only the calendar day of the input is used.
  - drift's `contains` does not escape `%` or `_`, so the name filter uses `like` with an escape character. A test covers it.
  - `suggested()` keeps the latest row (highest id) per exact name and returns the 10 most recent by date.
- [X] T023 [P] Write `test/data/local/local_database_test.dart` against an in-memory database (`NativeDatabase.memory()`, no encryption):
  - The seed has 3 currencies and 17 categories, all active.
  - FK RESTRICT blocks deleting a used account and a used category.
  - The `amount > 0` CHECK holds.
  - The case-insensitive unique category name holds.
- [X] T024 [P] Write `test/data/local/local_services_test.dart` against an in-memory database:
  - Balances after add, edit and delete of income/outcome. Add 100 income, add 30 outcome → 70; edit the outcome to 40 → 60; delete the income → −40 (quickstart Q4).
  - `add` returns the post-insert source balance.
  - Paging order and page size.
  - `suggested` returns distinct names.
  - The account-delete and category-delete exceptions.

### App mode (contracts/data-sources.md; research R9)

- [X] T025 Create `lib/data/services/app_mode.service.dart`: `AppModeService extends ChangeNotifier`.
  - `isLocalAvailable` is `PlatformType.Desktop` only.
  - `isLocal` is backed by the SharedPreferences key `appMode` (`online` default / `local`).
  - `LocalDatabase? database` is set when local.
  - `Future<void> init()` runs at startup: if `appMode == local`, call `openLocalDatabase(fileName: 'homemanagement_local.sqlite')` (the active file name is a constant) and keep any `LocalDataUnavailableException` in a `startupError` field instead of throwing.
  - `Future<void> enterLocalMode()` opens or creates the database, persists `appMode = local`, calls `TransactionRepository.invalidateSuggestions()`, then notifies. Add that public method to `lib/data/repositories/transaction.repository.dart`; it wraps the private `_invalidateSuggestionsCache()`.
  - `bool get isImportPending`: true while `import_states.status` is `inProgress` or `failed`.
  - Leave `completeImport()` as a stub for US4.

  Done. Notes:
  - `AppModeService` takes optional `preferences` and `openDatabase` parameters, so tests can use an in-memory database.
  - `startupError` leaves `isLocal` true on purpose: the app must not fall back to online or touch the file. `myapp.dart` (T033) shows the error screen instead of the router.
  - `isImportPending` is a cached synchronous getter, because the router needs it synchronously. It is read when the database opens, and `refreshImportStatus()` re-reads it after the import changes `import_states`.
  - `enterLocalMode()` throws `StateError` where local mode is unavailable, and leaves the mode unchanged when the database can't be opened.
  - Instead of `AppModeService` calling `TransactionRepository.invalidateSuggestions()`, which would need the repository before it exists, T027 should do `appMode.addListener(transactionRepository.invalidateSuggestions)`. The public method is added to the repository.
- [X] T026 Create `lib/data/services/sources/mode_aware_data_sources.dart` with `ModeAwareAccountDataSource`, `ModeAwareCategoryDataSource`, `ModeAwareCurrencyDataSource` and `ModeAwareTransactionDataSource`. Each takes `(remote, AppModeService)` and forwards every call to `remote`, or to a lazily constructed local service (`LocalXService(appMode.database!)`) when `appMode.isLocal`.
- [X] T027 Wire everything in `lib/main.dart`:
  - Make `main()` `async` and call `WidgetsFlutterBinding.ensureInitialized()`.
  - Create and `await AppModeService(platform).init()`, then register it as a singleton **before** `registerSingletons`.
  - In `registerSingletons`, construct `AccountRepository`, `CategoryRepository`, `CurrencyRepository` and `TransactionRepository` with the `ModeAware*` delegates wrapping the existing HTTP services.
  - Leave the `registerServices` factories (used directly by some views) unchanged.

  Done. `registerDependencies(platform, {appModeService})` registers the service first and creates an un-initialised one (online) when none is passed, so the existing tests that call `registerDependencies(platform)` still work. The transaction repository gets the delegate through its optional `dataSource` parameter. `appModeService.addListener(transactionRepository.invalidateSuggestions)` replaces the call that T025 described. A 100-second launch of the Linux app started cleanly in online mode.
- [X] T028 [P] Write `test/data/services/mode_aware_data_sources_test.dart`. Fake remote implementations record calls. Check that calls go to the fake remote when online and to the local service (in-memory database) when local, and that flipping the mode switches routing without re-creating repositories.

**Checkpoint**: The seam is in place, online behaviour is unchanged, and the local database is encrypted and tested. User stories can start.

---

## Phase 3: User Story 1 - Start using the app without an account (Priority: P1) 🎯 MVP

**Goal**: A "Use without an account" entry on desktop login opens a working local home with zero network calls. Relaunching returns to it.

**Independent Test**: quickstart Q1, Q2, Q3 and Q7. With the network disconnected, choose the option, close and reopen the app: it goes straight to the local home with no errors.

### Tests for User Story 1

- [X] T029 [P] [US1] Extend `test/views/login_view_test.dart`, or add `test/views/login_desktop_local_option_test.dart`:
  - The "Use without an account" button renders for `PlatformType.Desktop`.
  - It is absent for `Web` and `Mobile`.
  - Tapping it calls `AppModeService.enterLocalMode` and navigates to `/home_screen`.
- [X] T030 [P] [US1] Write `test/views/local_mode_guard_test.dart` for the router `redirect` built by `Routing.createRoutes` with a fake `AppModeService(isLocal: true)` and an unauthenticated `AuthenticationService`:
  - `/login_screen` → `/home_screen`.
  - `/home_screen` is allowed.
  - `/public/invites/abc` and `/login_screen?view=reset_password` redirect to `/home_screen` in local mode.
  - Online mode is unchanged (still redirects to login, and invite and reset links still work).

  Done (T029, T030). Notes:
  - T029 is `test/views/login_desktop_local_option_test.dart` (a new file, not an extension of `login_view_test.dart`): the button shows on desktop and is hidden on Web, WebMobile and Mobile. Tapping it enters local mode and opens the home. A locked keyring shows the dialog and stays on the login.
  - T030 is `test/views/local_mode_guard_test.dart`. It resolves each path through the router's own parser, so the real `redirect` runs without building any screen. It covers local mode (login to home, home allowed, invite and reset links to home with no reset state recorded, registration reachable) and online mode (unauthenticated to login, invite still public, reset link still works).
  - T030 does not test the full local allowlist (that is T048) or that `refreshListenable` moves a user already on the login screen: the login button navigates explicitly anyway.
  - Both tests were checked by temporarily disabling the feature (the guard and the `isLocalAvailable` condition), and both fail then.
  - Shared `test/helpers/fake_platform.dart`; the two earlier tests that had their own copy now use it.

### Implementation for User Story 1

- [X] T031 [US1] Add the l10n keys `useWithoutAccount`, `localModeUnavailableTitle`, `localModeKeyringUnavailable`, `localDataCannotBeOpened` and `localDataCannotBeOpenedDetail` to `lib/l10n/app_en.arb`, plus Spanish in `app_es.arb` and `app_es_ar.arb`. `it` and `pt` fall back to English. Then run `flutter gen-l10n`.
- [X] T032 [US1] Update `lib/routing.dart`:
  - `createRoutes` takes `AppModeService` and passes it as `refreshListenable`.
  - In `redirect`, put the local-mode block at the **very top**, before the password-reset state, the `?view=reset_password` query and the `/public/invites/` check, because all of those reach the server (FR-004). When `appModeService.isLocal`: send `/login_screen` to `/home_screen`, and allow `HomeScreen.fullPath` without authentication.
  - Leave the full allowlist (FR-016) to US3, T048.

  Done. Notes:
  - In local mode `/login_screen` and `/public/invites/*` redirect to `/home_screen`, and `/home_screen` is allowed. The password-reset state and `?view=reset_password` checks are skipped entirely in local mode, because they reach the server. Every other path falls through to the existing logic, so registration still works and deep screens such as account detail redirect to login and then home until T051 adds the allowlist.
  - `createRoutes` has a fourth parameter, `AppModeService`. `lib/myapp.dart` passes it from GetIt now (a minimal call-site change). The startup-error screen is still T033.
- [X] T033 [US1] Update `lib/myapp.dart` to resolve `AppModeService` from GetIt and pass it to `Routing.createRoutes`. If `appModeService.startupError != null`, render `LocalDataUnavailableScreen` instead of the router.
- [X] T034 [US1] Create `lib/ui/features/local_mode/views/local_data_unavailable_screen.dart` (the "local data cannot be opened" spec edge case):
  - Explains the reason (keyring locked/unavailable, key missing, not encrypted) using the T031 strings.
  - Offers **Retry**, which re-runs `AppModeService.init()`.
  - Never offers to delete or reset the data.
  - Uses theme colours only (light and dark).

  Done (T033, T034). Notes:
  - `MyApp` now rebuilds on `Listenable.merge([identityUserRepository, appModeService])`. When `startupError` is set it builds a plain `MaterialApp` (same locale, theme and localization setup) around the screen, and goes back to the router once Retry succeeds. The router is still created once per `MyApp` build, not per notification.
  - A locked keyring gets `localModeKeyringUnavailable`. Every other reason (`keyMissing`, `notEncrypted`, `unreadable`) gets the generic `localDataCannotBeOpenedDetail`.
  - Added the `retry` key (en, es, es_AR), since no reusable one existed.
  - Widget test: `test/views/local_data_unavailable_screen_test.dart`. Not run in the real app: forcing the error needs an existing database file with no key in the keyring.
- [X] T035 [US1] Update `lib/ui/features/authentication/views/login-desktop.dart`:
  - When `GetIt.I<AppModeService>().isLocalAvailable`, add a `TextButton(l10n.useWithoutAccount)` next to the "Create one" link (around line 162).
  - On tap, `await enterLocalMode()` then `context.go(HomeScreen.fullPath)`.
  - On `LocalDataUnavailableException(keyringUnavailable)`, show `localModeKeyringUnavailable` in a dialog and stay on login.

  Done. Notes:
  - The button sits on its own line under the "Create one" row, not in it: a third item in that row overflows the 460 px content width. It is disabled while a sign-in is running.
  - Any `LocalDataUnavailableException` shows the dialog, not only `keyringUnavailable`: a locked keyring gets `localModeKeyringUnavailable`, the other reasons get `localDataCannotBeOpenedDetail`. The OK label is Flutter's own localized `okButtonLabel`.
  - `DesktopLoginView` also serves the web, but `isLocalAvailable` is false there, so the button is hidden. The widget test is T029.
  - Not run in the real app yet: tapping the button persists `appMode = local`, and the local home (T036, T037) does not exist, so the next launch would start into a home that still calls the server.
- [X] T036 [US1] Update `lib/ui/features/home/views/home-desktop.dart` `initState`:
  - When `appMode.isLocal`, only call `AccountRepository.load()`, `CurrencyRepository.load()` and `CategoryRepository.load()`.
  - Skip `TagRepository.load()`, `IdentityUserRepository.getUser()`, `BudgetRepository.load()` and the `useMainAccounts` read, and force `useMainAccounts = false`.
- [X] T037 [US1] Update `lib/ui/features/home/views/home-desktop.dart` body: when local, render only `AccountListDesktopView`. Don't build `DashboardDesktop` (`BalanceWidget`, `OverviewWidget` and `BalanceHistoricalChartWidget` all call `MetricService`) or `RecurringTransactionList`, so no server request is made (FR-004).

  Done (T036, T037), with a changed approach: instead of branching inside `HomeDesktop`, local mode has its own widget, `lib/ui/features/local_mode/views/local_home_desktop.dart` (`LocalHomeDesktop`), and `home-desktop.dart` is untouched. `routing.dart` picks it when `appModeService.isLocal`, the same way it already picks mobile or desktop. It loads only accounts, currencies and categories, and shows only `AccountListDesktopView` (centred, max 900 px). Its AppBar has only the title for now.
  - **T052, T054 and T049 now apply to `LocalHomeDesktop`**: add the Settings and "Create account" actions and the banner there, and don't edit `HomeDesktop`'s AppBar.
  - Not run in the real app yet (T038 is the manual FR-004 check).
- [X] T038 [US1] Check FR-004 by hand. Run the Linux debug build with the network disabled, enter local mode, and watch the logs (`lib/data/services/logger_wrapper.dart` output / Logging view) for any HTTP attempt during startup and home load. Fix any caller found.

  Done. Checked with `strace` instead of the Logging view, because a trace shows every network attempt, including ones a repository would swallow. The debug build was launched straight into the local home (the profile already had `appMode = local` from a manual run), and every `connect()` was traced for 45 seconds covering startup, the home load and idle time. Result: 12 `connect()` calls, all `AF_UNIX` (display and D-Bus), and none `AF_INET` or `AF_INET6`, so no DNS lookup and no HTTP. A control run with `curl` confirmed the filter does catch an inet connect. Not covered: actions after the home (opening an account, settings), which are still redirected until T051, and the full user stories.


**Checkpoint**: US1 is fully functional. The MVP can be demoed: offline start, local home, relaunch.

---

## Phase 4: User Story 2 - Manage accounts, categories and transactions locally (Priority: P1)

**Goal**: Full CRUD in local mode, with balances that always equal the transaction sums and data that persists.

**Independent Test**: quickstart Q4 and Q5. Create two accounts in different currencies, manage categories, add/edit/duplicate/delete transactions, restart, and verify everything including balances.

### Tests for User Story 2

- [X] T039 [P] [US2] Write `test/data/repositories/local_repositories_test.dart`. Using `ModeAware*` in local mode on an in-memory database, check that:
  - `TransactionRepository.add` updates `AccountRepository.accounts` balance from the result.
  - `remove` and `update` keep the in-memory balance equal to a fresh `fetchAccounts()` balance.
  - Run this over 1,000 random operations across 5 accounts (SC-003).

  Done. Notes:
  - The random run is seeded (deterministic) and mixes about 50% adds, 25% edits and 25% removes. After every operation it compares each account's balance in `AccountRepository` with a fresh `fetchAccounts()` from the database. It also asserts that each kind of operation ran often enough to matter.
  - Edits and removes only pick transactions the account's page shows, as the UI does: `TransactionRepository.update` looks the old transaction up in the current account's loaded list and throws if it isn't there.
  - The server stand-ins throw if local mode ever reaches them, and `TransactionRepository`'s concrete service (server-only calls) is a throwing fake too.
  - Checked by temporarily breaking `AccountRepository.revertBalance`: the random test fails.

### Implementation for User Story 2

- [X] T040 [US2] Add the l10n keys `accountHasTransactions`, `categoryInUse`, `deactivateCategory`, `categoryNameTaken` and `changeNotSaved` to `lib/l10n/app_en.arb`, `app_es.arb` and `app_es_ar.arb`, then run `flutter gen-l10n`.

  Done. Wording notes: `accountHasTransactions` points the user to deleting the transactions or archiving the account (archive exists in the app). `categoryInUse` points to deactivating. `changeNotSaved` says nothing was changed, which is true because T044 leaves the in-memory state untouched. `it` and `pt` fall back to English (53 and 56 untranslated).

- [X] T041 [US2] In `lib/ui/features/accounts/views/account-list-desktop.dart` (delete action around line 378), catch `AccountHasTransactionsException` from `AccountRepository.delete` and show `l10n.accountHasTransactions` through the existing notifier/snackbar path, instead of a generic error. Also make sure `AccountRepository.delete` in `lib/data/repositories/account.repository.dart` rethrows typed exceptions rather than swallowing them.
- [X] T042 [US2] In `lib/ui/features/settings/views/settings-widgets/categories_list_widget.dart` (delete around line 215), catch `CategoryInUseException`. Show a dialog with `l10n.categoryInUse` and a `l10n.deactivateCategory` action that calls `CategoryRepository.update` with `isActive = false`.
- [X] T043 [US2] In `lib/ui/features/settings/views/settings-widgets/add_category_sheet.dart` and `edit_category_sheet.dart`, catch `CategoryNameTakenException` and show `l10n.categoryNameTaken`.

  Done (T041, T042, T043). Notes:
  - **T041:** `AccountRepository.delete` rethrows `AccountHasTransactionsException` before the generic catch, so there is no second "Failed to delete" notice, and `account-list-desktop.dart` shows `accountHasTransactions` in a snackbar. Other errors behave as before. The view's snackbar is not widget-tested: the repository test covers the typed error, and the full flow needs the account list with its server-backed services.
  - **T042:** the Delete menu item now awaits the delete. On `CategoryInUseException` a dialog offers Cancel or "Deactivate", which updates the category with `isActive = false` and reloads the list (`CategoryRepository.update` doesn't replace the item in its list).
  - **T043:** both sheets await the repository call, show `categoryNameTaken` under the name field on `CategoryNameTakenException`, keep the sheet open, and clear the error when typing. The edit sheet restores the model's old name and colour on that error, because it mutates the shared model before saving.
  - **Two changes beyond the task text.** (1) The add sheet now creates categories active and measurable. It used `CategoryModel.create`, which makes them inactive, and the list's checkboxes are read-only, so a new local category would never appear in the transaction picker (US2 scenario 4). The server ignores both flags on create, so online behaviour doesn't change. (2) The edit sheet sets the name controller in `initState` and no longer in `build`; in `build` it overwrote what the user had typed on every rebuild, for example after picking a colour.
  - Tests: `test/views/category_local_errors_test.dart` (end to end through `CategoriesListWidget`) and a new case in `test/data/repositories/local_repositories_test.dart`. Five of them fail when the three UI changes are stashed.

- [X] T044 [US2] Handle failed local writes (spec edge case "low disk space"):
  - In `lib/data/local/local_account.service.dart`, `local_category.service.dart` and `local_transaction.service.dart`, wrap `SqliteException` and `FileSystemException` thrown by writes as `LocalWriteFailedException`.
  - In `account.repository.dart`, `category.repository.dart` and `transaction.repository.dart`, catch it, show `l10n.changeNotSaved` through `NotifierService`, and leave the in-memory state (lists and balances) unchanged.
  - Add a case to `test/data/local/local_services_test.dart` that writes to a closed database and expects `LocalWriteFailedException`.

  Done. Notes:
  - **Where the exception lives.** `LocalWriteFailedException` is in `lib/data/services/sources/local_write_failed_exception.dart`, next to the other data-source exceptions. `lib/data/local/local_write_guard.dart` has `guardWrite`, which every add, update and delete in the three local services now goes through.
  - **The guard unwraps `DriftRemoteException`.** The app opens its database with `driftDatabase`, in a background isolate, where a `SqliteException` arrives wrapped. A plain `on SqliteException` would never fire in the real app. A test using `NativeDatabase.createInBackground` covers this, and fails without the unwrapping. Input errors (`ArgumentError`) and the typed "in use" and "name taken" exceptions pass through unchanged.
  - **A closed database is not wrapped.** Writing to a closed database throws a plain `StateError`, which can only be a programming error here, and wrapping every `StateError` would hide real bugs. The tests simulate failures with triggers that abort writes, and with a real `SQLITE_FULL` (`PRAGMA max_page_count`), instead of a closed database.
  - **Localized notices from repositories.** Repositories have no `BuildContext`, so `NotifierService` gained `notifyLocalized(builder)` and `notifyChangeNotSaved()`. The view that shows the message (`NotifierMixin`) supplies its `AppLocalizations`, so the notice follows the user's language, and English is the fallback. T066 can reuse this for `importPendingReadOnly`.
  - **In-memory state after a failure.** Add, edit and remove of a transaction, and add and delete of an account or category, throw before changing anything, so the lists and balances stay as they were. Edits of an account or category reload the stored values, because the sheets edit the shared model before saving. Archive and hide undo their toggle.
  - `CategoryRepository` takes an optional `notifierService` (wired in `main.dart`), and `load()` now fetches before clearing so a failed read keeps what is shown.

- [X] T045 [US2] Verify that `lib/ui/features/home/views/shared/account-sheet-dektop.dart` (create) and `account.sheet.dart` (edit from the desktop list) list currencies from `CurrencyRepository` in local mode (USD/ARS/EUR) and save via `AccountRepository.add/update`. Fix any direct `CurrencyService` use you find.
- [X] T046 [US2] Verify that `lib/ui/features/accounts/views/widgets/add_transaction_sheet_desktop.dart` (add/update around lines 473–475, suggestions around line 89) and `lib/ui/features/accounts/views/widgets/transaction.row.info.dart` (duplicate/delete around lines 40 and 183) work in local mode through `TransactionRepository`, and that `AccountDetailDesktop` paging (`loadFirstPage`/`nextPage`) lists most recent first (FR-010). Fix only actual breakages.

  Done (T045, T046). Checked by reading the code paths, then by widget tests (`test/views/local_mode_accounts_and_transactions_test.dart`) on a real local database. Findings:
  - **T045, a real bug fixed.** Both account sheets (`account-sheet-dektop.dart` for create, `account.sheet.dart` for edit) set `currencyId = currencies.indexOf(name)`, the position in the list. Server and local ids start at 1, so picking USD saved id 0 (a foreign-key failure locally), ARS saved USD's id and EUR saved ARS's. They now look the id up by name. This also corrects the same off-by-one online. No direct `CurrencyService`, `AccountService` or `CategoryService` use exists in the UI. The mobile `AccountSheet` has the same fix but no widget test.
  - **T046, a gap fixed.** Each transaction row (`transaction.row.info.dart`) shows tag controls (swipe action, long-press, chips, "Add tag") that call the server and were in no task. They are hidden in local mode. The sheets and row actions otherwise already go through the repositories: add and edit (the row's tap opens the mobile `AddTransactionSheet` in edit mode, which hides voice and receipt there), duplicate (tests: second transaction, balance -8) and delete (balance restored).
  - **Still for later tasks:** the voice and receipt buttons in the add-transaction sheet are T057, and the CSV, metrics and `TransactionService` field of the account screens are T055 and T056.
  - **Observed, not changed (shared with online):**
    1. The add-transaction pickers list every category, active or not (only the bulk screen uses `getActiveCategories`), and the server creates categories inactive, so filtering by `isActive` there would hide online users' new categories. In local mode "Deactivate" therefore has no visible effect in the pickers yet.
    2. A transaction added with an older date is shown at the top of the account's list until it is reloaded, because `TransactionRepository` inserts new items first. The data source itself pages by date and id descending.
    3. In edit mode the desktop account sheet always shows "Cash" and the first currency in its dropdowns, whatever the account has. Saving keeps the real values unless a dropdown is changed.

- [ ] T047 [US2] Run quickstart Q4 and Q5 by hand on a Linux build. Restart the app between steps and confirm persistence (FR-013).

**Checkpoint**: US1 and US2 both work. Local mode is useful on its own.

---

## Phase 5: User Story 3 - A home screen showing only what works offline (Priority: P2)

**Goal**: Every server-only entry point is hidden in local mode, hidden routes redirect home, and a persistent local-mode banner with "Create account" is shown.

**Independent Test**: quickstart Q8. Go through every AppBar action, Settings, account detail and the add-transaction sheet in local mode: no server request and no server error. Hidden routes redirect home.

### Tests for User Story 3

- [X] T048 [P] [US3] Extend `test/views/local_mode_guard_test.dart`. In local mode:
  - These paths stay put: `/home_screen`, `/home_screen/account_detail_screen`, `/home_screen/settings_screen`, `/home_screen/logging_screen`, `/registration_screen`, `/home_screen/local_import`.
  - These redirect to `/home_screen`: `/home_screen/budget`, `/home_screen/invites`, `/home_screen/statistics`, `/home_screen/reconciliation`, `/home_screen/bulk_transactions`, `/home_screen/account_detail_screen/account_metrics_screen`, and both search paths.

  Done, test-first. `test/views/local_mode_guard_test.dart` now also covers the allowlist: six paths that must stay put, and ten that must redirect to `/home_screen` (the nine listed here, plus reminders, plus an unknown path). Four of the "stay" cases (account detail, settings, the log screen and the import screen) failed until T051 was implemented, and pass now. The import path is written as a literal, because the screen arrives with T069.

- [X] T049 [P] [US3] Write `test/views/home_desktop_local_mode_test.dart`. In local mode, the AppBar shows only Settings and "Create account" and "Sign in to an existing account" (the last one is hidden when `isImportPending`). Search, Bulk, Invitations, Statistics, Budget, Reminders and Logout are absent. The local-mode banner is visible.

### Implementation for User Story 3

  Done, in `test/views/local_home_desktop_test.dart` (not under the name given here, because the screen is `LocalHomeDesktop`): the app bar, the pending-import case, the sign-in dialog, and the banner assertion that T054 made possible.

- [X] T050 [US3] Add the l10n keys `localModeBanner` ("You're working locally on this computer"), `createOnlineAccount`, `signInExistingAccount` and `signInExistingAccountConfirm` ("Your local data will stay on this computer and won't be moved to that account.") to `lib/l10n/app_en.arb`, `app_es.arb` and `app_es_ar.arb`, then run `flutter gen-l10n`.

  Done. The keys were renamed after review (UI-04): `createAccountToSync` is now `createOnlineAccount` ("Create online account", because "account" alone also means a money account here), and the "log in" keys are `signInExistingAccount` and `signInExistingAccountConfirm`, which says how to come back ("Use without an account"). The app already says "Sign in", so the wording follows it. `it` and `pt` fall back to English (57 and 60 untranslated).

- [X] T051 [US3] Complete the FR-016 allowlist in `lib/routing.dart`. In local mode, return `null` only for the paths listed in T048. Redirect everything else to `HomeScreen.fullPath`.

  Done. In local mode the router's `redirect` now decides everything: `/login_screen` goes to the home, a path in `_localModeAllowedPaths` is allowed, and any other path, known or not, goes to the home. The set is the six paths from T048, with `/home_screen/local_import` as a literal until T069. Because that block always returns, the password-reset checks that T032 had to skip in local mode are no longer reachable from it, so their `!isLocal` conditions were removed. Online behaviour is unchanged. Account detail is now reachable in local mode, so T047 can be run by hand.

- [X] T052 [US3] Update the AppBar `actions` in `lib/ui/features/home/views/home-desktop.dart` (lines 63–121). When local, show only Settings and a `createOnlineAccount` action that does `context.go(RegistrationScreen.fullPath)`. Also show a `signInExistingAccount` action unless `appMode.isImportPending` (see the next task). Hide Search, Bulk, Invitations, Statistics, Budget, Reminders and Logout.

  Done, in `LocalHomeDesktop` (`lib/ui/features/local_mode/views/local_home_desktop.dart`), as the T037 note says, and not in `HomeDesktop`. The AppBar has "Create online account" (to registration), "Sign in to an existing account" (hidden while `isImportPending`, and the bar rebuilds when that changes) and Settings. Settings opens the screen as it is today: its server-only sections are hidden by T058, and RF-09 and RF-10 still apply there.
  - **Empty state (review UI-03):** with no accounts at all (hidden ones count), the home shows "Your data is stored encrypted on this computer only." and a "Create your first account" button that opens the account sheet. Once an account exists, the list takes over. The review also suggested a visible "Add transaction" button on each account row. That is not done: it would change the account list that online uses too.
  - Tests: `test/views/local_home_desktop_test.dart`. This is also the AppBar half of T049, which stays open until the banner (T054) is there to assert.

- [X] T053 [US3] Implement "Sign in to an existing account" (spec FR-027, US3 scenarios 7–8):
  - **Already in place (review RF-02):** `AppModeService.leaveLocalMode()` exists: it closes the database without touching the file, persists `online`, clears `startupError` and throws while an import is pending. What is left here is the confirmation dialog (title `signInExistingAccount`, body `signInExistingAccountConfirm`, confirm `signIn`), and clearing `Caching` and **resetting the repositories** (RF-07, SP-05) with no reload before login: online with no user, a reload throws.
  - Add `Future<void> leaveLocalMode()` to `lib/data/services/app_mode.service.dart`. It closes the database **without renaming or deleting the file**, persists `appMode = online`, clears `Caching` and `TransactionRepository.invalidateSuggestions()`, notifies, and reloads the Account, Currency and Category repositories. It throws if `isImportPending`.
  - The `signInExistingAccount` AppBar action in `lib/ui/features/home/views/home-desktop.dart` shows a confirmation dialog with `l10n.signInExistingAccountConfirm`. On confirm it calls `leaveLocalMode()`, then `context.go(LoginView.fullPath)`.
  - The next "Use without an account" reopens the same `homemanagement_local.sqlite` with the same key (T018 already reuses an existing file and key).
  - Add cases to `test/data/services/mode_aware_data_sources_test.dart`: after `leaveLocalMode()`, calls go to the remote; after `enterLocalMode()`, the earlier local rows are still there.

  Done. The confirmation dialog is in `LocalHomeDesktop` (title `signInExistingAccount`, the text says the data stays and how to come back, confirm is `signIn`). Confirming calls `AppModeService.leaveLocalMode()` and goes to the login. Cancel changes nothing.
  - **Review RF-07 and SP-05, differently from the original text.** The repositories are not reloaded after leaving: online with no signed-in user that throws. Instead `main.dart` listens to the mode and, only when `isLocal` actually flips, calls the new `reset()` on the account, category, currency and transaction repositories and clears `Caching` (new `Caching.clear()`). Each screen then loads what it needs once it can: the home after a sign-in, `LocalHomeDesktop` when local mode starts. The transaction repository's per-account cache used to survive a switch, so an id that exists in both modes would have shown the other mode's rows.
  - Tests: `test/data/services/mode_switch_reset_test.dart` (the real listener, wired through `registerDependencies`; they fail without it), and in `mode_aware_data_sources_test.dart` that after leaving, calls go to the remote, and entering again finds the earlier local rows in a real file.

- [X] T054 [P] [US3] Create `lib/ui/features/local_mode/views/local_mode_banner.dart`. It's a `MaterialBanner`-style strip using `Theme.of(context).colorScheme` (follow `.claude/skills/flutter-theme-and-styling/SKILL.md`) with `l10n.localModeBanner` and a `createOnlineAccount` button. Mount it at the top of `HomeDesktop`, `AccountDetailDesktop` and `SettingsDesktopView` (`lib/ui/features/settings/views/settings_desktop.dart`) when local, so it's on every local-mode screen (FR-017, US3 scenario 6).

  Done. Notes:
  - **Where it goes:** `LocalModeBanner` implements `PreferredSizeWidget` and is mounted as `AppBar.bottom`, not at the top of each body. That keeps it visible while the page scrolls, needs a one-line change per screen, and means the shared screens (`AccountDetailDesktop`, `SettingsDesktopView`, `LoggingView`) are untouched in layout. Online it reports size zero and draws nothing, and without a registered `AppModeService` it is simply absent.
  - **Screens:** the local home, account detail, settings and, beyond the original list, the log screen (FR-017 says every local-mode screen, and `/home_screen/logging_screen` is on the allowlist). Not on registration: it is where the banner's own button leads, so it would be a button to the screen you are on.
  - **Look (review UI-07):** `colorScheme.secondaryContainer` with `onSecondaryContainer` text, a laptop icon, and "Create online account". Tests check both themes. The review's extra text ("Your data is stored only on this computer") and a "Local" chip were left out: the banner is part of the app bar and never scrolls away, so the chip would repeat it.
  - **Tests:** `test/views/local_mode_banner_test.dart`, and the banner assertion in `local_home_desktop_test.dart`. The account detail and settings mounts are not rendered in a test yet, because those screens still call the server in local mode. They are covered when T056 and T058 make them testable.

- [X] T055 [P] [US3] Update `lib/ui/features/accounts/views/account-list-desktop.dart`. When local, hide CSV export/import (around lines 305 and 351, which use `TransactionService` directly) and the main-accounts toggle.

  Done. In local mode the account menu no longer has "Export transactions", "Download import template" or "Import Transactions": all three go through the server, and the template only exists to feed the import. The `TransactionService` field became a getter that GetIt resolves on use, so local mode never creates it. **The main-accounts toggle is not in this file** (review DR-02): it is in `HomeDesktop`, which local mode doesn't use, so there was nothing to hide.

- [X] T056 [P] [US3] Update `lib/ui/features/accounts/views/account-detail-desktop.dart`. When local, skip `MetricService.getOverallByAccountId` and its panel (around lines 297–343), and hide the CSV and metrics navigation. The field `transactionService = GetIt.I<TransactionService>()` at line 48 must not be used in local mode.

  Done. In local mode `AccountDetailDesktop` skips `MetricService.getOverallByAccountId` and does not build the "most expensive categories" and overview panels (even for a measurable account), and the app-bar menu keeps Edit and Archive but drops "Import Transactions" and "Reconcile statement". `MetricService` and `TransactionService` are now getters, so nothing is created in local mode. There was no "metrics navigation" in this desktop screen to hide. The server-only panels leave the left column with only the account summary.
  - Tests: `test/views/local_mode_account_screens_test.dart` builds both screens **without** registering `MetricService` or `TransactionService`, so a screen that asked GetIt for one would throw: that is the proof of no server call (FR-004). Six tests fail on the old code. They also check that online still offers the CSV items and that the detail lists the most recent transaction first (part of T046 and T047).

- [X] T057 [P] [US3] Update `lib/ui/features/accounts/views/widgets/add_transaction_sheet_desktop.dart`. When local, hide voice dictation, receipt scanning and the tags input.

  Done. `AddTransactionSheetDesktop` hides `VoiceDictationButton` and `DocumentScanButton` in local mode (`_isLocal`, which tolerates `AppModeService` not being registered). There is no tags input in this sheet today, so there was nothing to hide for it. No widget test yet.
- [X] T058 [P] [US3] Update `lib/ui/features/settings/views/settings_desktop.dart`. When local, keep `CategoriesListWidget` plus the appearance and language options. Hide the profile, security/2FA, invitations, main-accounts and user-settings sections, and anything else calling `IdentityUserService`, `UserSettingsService` or `InviteService`.

  Done. In local mode `SettingsDesktopView` drops the authentication, feature-toggle, user-settings and reminder widgets, which all call identity/user-settings/reminder services, and shows the new `LocalPreferencesWidget` (theme and language, kept on the device) above `CategoriesListWidget`. Language used to be saved only through the server, so `IdentityUserRepository.setLocalLanguage` saves it to preferences. Not covered by a widget test yet.
- [ ] T059 [US3] Run quickstart Q8 and Q15 (the part without an import) by hand with the network disabled. Click every remaining control and confirm there's no error toast and no HTTP attempt in the logs.

**Checkpoint**: Local mode is clean. Only working features are visible.

---

## Phase 6: User Story 4 - Create an account and bring local data along (Priority: P2)

**Goal**: Register from local mode, move all local data once into the new account (resumably and without duplicates), verify balances, archive the local file, and switch to online.

**Independent Test**: quickstart Q9–Q15 against a local backend (no backend changes needed).

### Tests for User Story 4

- [X] T060 [P] [US4] Write `test/data/services/local_import_service_test.dart` with hand-written fakes for `AccountDataSource`, `CategoryDataSource`, `CurrencyDataSource` and a fake bulk/verify client, over an in-memory local database. Cover:
  - The happy path, mapping all ids (transactions keep account and category).
  - Default categories matched by name (case-insensitive), not created.
  - A created category followed by an update to active/icon/color/measurable.
  - The local "Cash"/USD account mapped to the server default "Cash". An unmapped server default is renamed temporarily and restored.
  - An unknown currency aborting before any write (FR-020).
  - A failure during step 4, then a retry: no duplicate bulk send, using the "server account already has transactions" check (SC-006).
  - A balance mismatch reported (FR-023).
  - At the moment each bulk request is sent, every fake server account has a temporary name (`⟨import <tag>-…⟩`), so a transaction named like a real account name matches no account. After step 5, all accounts have their real names plus local `archive`, `measurable` and `isHidden`.
  - Resume after an account was created but its `server_id` wasn't stored: the account is found by its exact temporary name, not created twice.
  - Accounts with zero transactions never sent.

  Written, test-first: it does not compile until T065 exists, and none of it has been run. It fixes the API T065 must provide, in `lib/data/services/local_import.service.dart`:
  - `LocalImportService({database, accounts, categories, currencies, transactions})`, with `Future<ImportResult> run({required String email, ImportProgress? onProgress})`. `ImportResult.mismatches` is a list of `ImportMismatch(accountName, localBalance, serverBalance)`.
  - `abstract interface class BulkTransactionClient { Future<void> bulkAdd(List<TransactionModel>); Future<bool> hasTransactions(int serverAccountId); }`
  - `LocalImportService.temporaryName(name, tag, suffix)`, `enum ImportStep` (preflight, categories, accounts, transactions, restoring, verifying) and `typedef ImportProgress = void Function(ImportStep, int done, int total)`.
  - `ImportCurrencyMissingException(codes)` and `ImportWrongUserException`. Any failure leaves `status = failed` and `last_error` set. A run that ends, even with mismatches, sets `status = completed`.
  - The remaining item (writes locked while pending) belongs to T066.
- [X] T061 [P] [US4] Write `test/data/services/identity_service_register_test.dart` using an `http` `MockClient` (from `package:http/testing.dart`, already available through `http`):
  - 200 → `success`.
  - 400 with a body containing `DuplicateEmail` or `DuplicateUserName` → `emailTaken`.
  - Other 400s and 5xx → `failed`.

### Implementation for User Story 4


  Written, test-first: it needs `RegistrationResult` from T063 (in `identity.service.dart`) and has not been run. It swaps the HTTP client with `http.runWithClient`, so `IdentityService` needs no change to be testable.
- [X] T062 [US4] Add the l10n keys `importTitle`, `importProgressCategories`, `importProgressAccounts`, `importProgressTransactions`, `importVerifying`, `importDone`, `importBalanceMismatch`, `importFailed`, `importResume`, `importCurrencyMissing`, `emailAlreadyRegistered`, `importWrongUser` and `importPendingReadOnly` to `lib/l10n/app_en.arb`, `app_es.arb` and `app_es_ar.arb`, then run `flutter gen-l10n`.

  Done, in `en`, `es` and `es_AR` as the task says. `it` and `pt` fall back to English for these keys until they are translated. `importBalanceMismatch` takes `{account}`, `{local}`, `{server}`, `importCurrencyMissing` takes `{currencies}` and `importWrongUser` takes `{email}`.
- [X] T063 [US4] In `lib/data/services/identity.service.dart`, change `register` to return `enum RegistrationResult { success, emailTaken, failed }`. Parse the 400 body for `DuplicateEmail` or `DuplicateUserName` (research R8). First confirm in `../Altair/AltairUserManagement` that `RegisterUserAsync` uses `UserManager.CreateAsync`, and note the result in research.md R8. Update `AuthenticationService.register` in `lib/data/services/authentication.service.dart` to pass the enum through.

  Done. `RegistrationResult` lives in `identity.service.dart`, and `AuthenticationService.register` passes it through. Confirmed in Altair that `RegisterUserAsync` calls `UserManager.CreateAsync` and the controller returns `BadRequest(result.Errors)` (noted in research R8). The two registration screens only compare against `RegistrationResult.success` so far, and T064 adds the `emailTaken` handling.
- [ ] T064 [US4] Update every caller of `register`: `lib/ui/features/authentication/views/registration-desktop.dart` (lines 29–63) and the mobile `registration.dart`.
  - On `emailTaken`, show `l10n.emailAlreadyRegistered` and stay on the screen, in local mode (FR-026).
  - On success in local mode with local data present, go to `LocalImportScreen.fullPath` instead of home.
  - With no local data (only seeds: no accounts, no transactions, categories untouched), call `appMode.completeImport()` directly (US4 scenario 6).

  Partly done. Both registration screens handle `emailTaken`. The post-sign-in hand-off is shared in `user-controls-mixins/post-sign-in.dart` (`goAfterSignIn`) and used by the desktop registration and the 2FA view, so the two-factor path no longer skips it. In local mode it goes to `/home_screen/local_import` when `LocalDatabase.hasUserData()` is true, and otherwise calls `completeImport()`; if that fails it shows `importFailed` and stays put.
  - **Still open**: the route and `completeImport()` now exist (T069, T067). What is left is checking the whole flow by hand (T071).
  - The mobile `registration.dart` only gets the `emailTaken` message. Local mode is desktop-only.
  - `hasUserData` is covered in `test/data/local/local_database_test.dart`. `goAfterSignIn` is covered in `test/views/post_sign_in_test.dart` (online, local with data, local with only the seeds, failed switch). The registration screens themselves are not widget-tested.
- [X] T065 [US4] Create `lib/data/services/local_import.service.dart` implementing the import state machine in `specs/001-standalone-desktop-mode/data-model.md`. It takes `LocalDatabase` plus the remote `AccountService`, `CategoryService`, `CurrencyService`, `TransactionService` (via the interfaces and a small `BulkTransactionClient` interface for fakes) and `AuthenticationService`.
  - **Step 0**: set `import_states.status = inProgress`, `target_email`, `started_at`, and (once) `import_tag` = 8 random hex chars. On resume, require `authenticationService.user.email == target_email`, otherwise fail with `importWrongUser`.
  - **Step 1, preflight**: check currencies by `name`. If any is missing, throw `importCurrencyMissing` listing the codes.
  - Match category names with `categoryNameKey` (trimmed, Dart `toLowerCase()`), the same folding the local uniqueness uses (RF-06), not SQLite's `lower()`.
  - **Step 2, categories**: fetch online categories → match by lower-cased name → `add` the missing ones → `update` each created category with isActive/measurable/icon/color → store `server_id`.
  - **Step 3, accounts under temporary names** (research R6). The temporary name is `"<name> ⟨import <import_tag>-<local id>⟩"`.
    - `fetchAccounts` online.
    - Map local accounts without `server_id` whose temporary name exists online (recovery).
    - Map an unmapped local "Cash"/USD account to the server "Cash"/USD account with balance 0, and `update` it to the temporary name.
    - `add` the rest **with the temporary name**, storing `server_id` right after each call.
    - If the server default account is still unmapped, `update` it to `"<name> ⟨import <import_tag>-default⟩"` and store `default_account_server_id`.
  - **Step 4, transactions**: for each account with `transactions_imported = false` that has transactions, check whether the server account already has transactions (non-zero balance, or a first page of `transactions/filter?accountId=` that isn't empty). If it does, just mark it imported. Otherwise send one existing `bulkAdd(remapped)` (no API change) with `accountId`/`categoryId` replaced by `server_id`, then set `transactions_imported = true`.
  - **Step 5, restore names**: `update` each mapped account with its real name and local `archive`, `measurable` and `is_hidden` (a `PUT account/{id}` with `UpdateAccountDto`), and restore the default account's original name. Idempotent.
  - **Step 6, verify**: compare each mapped server balance with the local derived balance (tolerance 0.005) and collect mismatches.
  - On any exception: `status = failed`, `last_error = message`, rethrow. Expose progress through a callback `(step, done, total)`.

  Done, in `lib/data/services/local_import.service.dart`. It passes the 13 cases of `local_import_service_test.dart` (T060).
  - A matched category is updated only when its icon, color, measurable or active flag differs from the local one. That also repairs a category that was created just before an earlier failure.
  - The step that renames unmapped server accounts renames every pre-existing account that isn't mapped, not only "Cash". The first gets the `default` suffix and is stored as `default_account_server_id`. Any others get `default-<server id>`.
  - One class per file: `LocalImportService` stays in `lib/data/services/local_import.service.dart`. `ImportStep` and `ImportProgress` are in `lib/data/models/import_progress.dart`, with `ImportMismatch` and `ImportResult` in their own files there. `BulkTransactionClient`, `RemoteBulkTransactionClient` and the two exceptions are in `lib/data/services/sources/`.
  - `RemoteBulkTransactionClient` wraps `TransactionService` for production: `bulkAdd`, and `hasTransactions` as a first page of size 1. T068 registers it.
  - `AuthenticationService` is not a constructor argument. The caller passes the signed-in email to `run`.
- [X] T066 [US4] Lock local writes while an import is pending (spec FR-022, data-model "Local writes are locked"):
  - In `lib/data/services/sources/mode_aware_data_sources.dart`, every add, update and delete throws `LocalDataLockedException` when `appMode.isLocal && appMode.isImportPending`. Reads are unaffected.
  - The repositories catch it and show `l10n.importPendingReadOnly` through `NotifierService`.
  - Add cases to `test/data/services/mode_aware_data_sources_test.dart`: writes are rejected while the status is `inProgress` or `failed`, and allowed when it is `notStarted`.
  - Add a case to `test/data/services/local_import_service_test.dart`: fail at step 4 → a write attempt is rejected → resume → the server data equals the local data.

  Done.
  - `_ModeSwitch.writable` throws `LocalDataLockedException` for every add, update and delete when `appMode.isLocal && appMode.isImportPending` (which includes `completed` while the file is still active, see T067). The write methods are `async`, so the lock arrives as a failed future, never a synchronous throw. Reads and the online path are unchanged.
  - `LocalDataLockedException` **extends** `LocalWriteFailedException`: the write was rejected and nothing changed, so every place that already handles "not saved" (repositories, account delete, the category sheets) keeps working with no new catch. Only the notice differs: the repositories now call `NotifierService.notifyWriteRejected(error)`, which shows `importPendingReadOnly` for the lock and the generic "not saved" otherwise.
  - Tests: `mode_aware_data_sources_test.dart` (rejected in `inProgress`, `failed` and `completed`; allowed in `notStarted`; reads still work; online unchanged; leaving local mode refused while locked), `local_write_failure_test.dart` (the notice and unchanged data for accounts, transactions and categories), and `local_import_service_test.dart` (fail at step 4, a write is rejected, resume, server data equals local).
- [X] T067 [US4] Implement `AppModeService.completeImport()` in `lib/data/services/app_mode.service.dart`:
  - Close the database.
  - Rename the file in `getApplicationSupportDirectory()` to `homemanagement_local.backup-YYYY-MM-DD.sqlite`, adding `-N` if it exists.
  - The rename alone makes the next local session start fresh (spec edge case "returning to local mode later"), since the active file name is constant.
  - Set `appMode = online`, call `Caching` clear-all (`lib/data/services/caching.dart`) and `TransactionRepository.invalidateSuggestions()`, and notify.
  - Then reload `AccountRepository`, `CurrencyRepository` and `CategoryRepository`.

  Done, in `AppModeService.completeImport()`. Tests in `test/data/services/app_mode_complete_import_test.dart`.
  - **Order matters.** It closes the database, renames the file (and any `-wal`, `-shm` or `-journal` side files) to `homemanagement_local.backup-YYYY-MM-DD.sqlite`, with `-1`, `-2`... when that name is taken, and only then persists `online`. A crash in between leaves the app in local mode with its file missing (the "data not found" screen, which keeps the backup), and never an online app whose old file could be imported again.
  - If the rename fails, it reopens the database and rethrows, so the app stays local and usable.
  - It throws `StateError` outside local mode, and also while the stored import status is `inProgress` or `failed` (it re-reads the status first, so a caller that just finished the import doesn't need to refresh). `notStarted` is allowed, for a user who had nothing to move.
  - **Review fix:** `isImportPending` is now also true for `completed` while the file is still active. That state means the data was sent but archiving failed, so new local writes would never reach the account. T066's lock and T070's banner must use `isImportPending`, so they cover it too.
  - **Repositories and `Caching` are not cleared here.** The listener in `registerSingletons` already does it when the mode flips (T053), and calls `reset()` rather than reloading, because the user's screens load on open. The task text said "reload"; that listener is the single place for it.
  - New constructor options `supportDirectory` and `now`, for tests, and an `importStatus` getter.
- [X] T068 [US4] Create `lib/data/repositories/local_import.repository.dart`: `LocalImportRepository extends ChangeNotifier`, wrapping `LocalImportService`.
  - Exposes `status`, `step`, `progress`, `mismatches` and `error`.
  - `start()` and `resume()` methods.
  - On success it calls `AppModeService.completeImport()`.
  - Register it in `lib/main.dart` (hand-registered).

  Done, in `lib/data/repositories/local_import.repository.dart`, registered in `registerSingletons`. Tests in `test/data/repositories/local_import_repository_test.dart`.
  - It builds a `LocalImportService` on demand from `AppModeService.database`, using the **remote** services (not the mode-aware delegates, which would read the local data back). The remote category and currency services in `main.dart` are now named variables so both the delegates and the import share them.
  - `start()` and `resume()` are the same call, because the service resumes from what it stored. A call while one is running does nothing.
  - On the first progress report it asks `AppModeService.refreshImportStatus()`, so local writes are locked from then on. A failure refreshes it again, keeping the lock until a retry.
  - **Review fix:** it listens to `AppModeService` and, when a new local session starts, resets its status, error, step, progress and mismatches. The summary of a finished import survives while the app is online. A singleton would otherwise show the last import's `completed` to T069.
  - A success sets `completed` and then calls `completeImport()`. The mismatches stay on the repository for the summary screen.
- [X] T069 [US4] Create `lib/ui/features/local_mode/views/local_import_screen.dart` (`static const path = '/local_import'`, `fullPath = '/home_screen/local_import'`).
  - On open, calls `LocalImportRepository.start()` automatically when the status is `notStarted` (US4 scenario 1). With `inProgress` (an app restart mid-import), it calls `resume()`. With `failed`, it shows Retry and waits.
  - Shows per-step progress from `LocalImportRepository` via `ListenableBuilder`.
  - Shows the summary with any balance mismatches (FR-023), then a "Continue" button to `HomeScreen.fullPath`, which is now online.
  - On failure, shows `importFailed` with **Retry** (calls `resume()`). The app stays local and the data stays intact (FR-022).
  - Register the route as a child of `/home_screen` in `lib/routing.dart`, following `.claude/skills/flutter-add-route/SKILL.md`.

  Done, in `lib/ui/features/local_mode/views/local_import_screen.dart`, with the route under `/home_screen` and the allowlist entry now using `LocalImportScreen.fullPath` (the literals in `routing.dart` and `post-sign-in.dart` are gone). Tests: `test/views/local_import_screen_test.dart`.
  - On open, while local: `notStarted` starts, `inProgress` resumes, `completed` resumes too (archiving had failed), and `failed` waits for Retry. Online, it starts nothing and shows only the summary.
  - Shows four steps (categories, accounts, transactions, balances) with a spinner or check and the "done / total" of the active one. Preflight and restoring names are not shown separately.
  - On success: `importDone`, one `importBalanceMismatch` line per differing account, and Continue to the home (now online).
  - On failure: the message for the error (`importCurrencyMissing` with the codes, `importWrongUser` with the email, otherwise `importFailed`) and Retry. The app stays local. `ImportWrongUserException` now carries `expectedEmail` for that message.
  - New key `continueButton` (en, es, es_AR).
  - **Not covered here:** a user who is not signed in (e.g. after an app restart) gets the generic failure text with Retry. Getting them to sign in is T070.
- [X] T070 [US4] Handle a resumed import:
  - In `lib/ui/features/local_mode/views/local_mode_banner.dart`, when `import_states.status` is `inProgress` or `failed`, show `importResume`. It opens the import screen, or registration/login if unauthenticated.
  - In `lib/routing.dart`, while an import is pending and the user isn't authenticated, allow `/login_screen` in local mode instead of redirecting it home.
  - In `lib/ui/features/authentication/views/user-controls-mixins/authentication-behavior.dart` `successFullAuthentication`, go to `LocalImportScreen.fullPath` when local with an import pending.

  Done.
  - **Banner** (`local_mode_banner.dart`): while `isImportPending` (so `inProgress`, `failed`, and `completed`-but-not-archived), its button reads `importResume` instead of `createOnlineAccount`, and updates by itself when the status changes. The button goes to the import screen when signed in and to **the login** when not. The task said "registration/login": registration is wrong here, because the account already exists and registering again only says the email is taken. `openImportResume(context)` is shared.
  - **Local home** (`local_home_desktop.dart`): the app bar's "Create online account" is replaced the same way while pending, for the same reason. This was not in the task text.
  - **Router**: in local mode `/login_screen` is allowed only when an import is pending and the user is not signed in. Signed in, or with nothing pending, it still goes to the home. Everything else stays as restricted as before.
  - **Sign-in**: `successFullAuthentication` now calls the shared `goAfterSignIn`, so a login, a registration and the two-factor path all decide in one place. `goAfterSignIn` treats a pending import like local data (it continues to the import screen even if the local data looks empty), and no longer fails when no `AppModeService` is registered (the mobile app).
  - Tests: banner, home app bar, guard and `post_sign_in_test.dart`. `successFullAuthentication` itself is not tested directly; it only delegates to `goAfterSignIn`.
- [ ] T071 [US4] Run quickstart Q9–Q15 by hand against a local backend (`../home-management-all` docker compose, `--dart-define=BACKEND_ORIGIN=http://localhost:8088`). Time Q9 with 5 accounts, 20 categories and 1,000 transactions; it must take under 2 minutes (SC-004).

**Checkpoint**: All user stories work on their own and together.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T072 [P] Update `CLAUDE.md` (Architecture → Data Flow / Key Infrastructure) and `AGENTS.md`: describe `lib/data/local/`, the `ModeAware*` delegates, `AppModeService`, and that drift code is generated with `build_runner` and committed.

  Done. `CLAUDE.md` has a new "Standalone (local) mode" section (the `Repository → DataSource → ModeAware* → remote or local` chain, `lib/data/local/`, `AppModeService`, the import, and that drift code is generated and committed), the `build_runner` command under Commands, and entries in Layout, Dependency Injection, Key Infrastructure and Testing. `AGENTS.md` gets two non-negotiables (local mode rules, and generated drift code). The Copilot data-layer instructions get a short matching section. I ran the documented `build_runner` command: it reproduces the committed `local_database.g.dart` with no diff.
- [X] T073 [P] Add a `.claude/skills/` note, or extend `flutter-new-feature/SKILL.md`: a new repository-backed resource must define a data-source interface, and must either get a local implementation or be hidden in local mode.

  Done, in `flutter-new-feature/SKILL.md` (step 2): a repository for a resource shown on the desktop home must depend on a data-source interface, and must either get a `Local*Service` plus a `ModeAware*` delegate (with the `build_runner` step) or be hidden in local mode and kept off `_localModeAllowedPaths`. `.junie/skills/` links to the same file.
- [ ] T074 [P] Park the out-of-scope findings as follow-ups, without fixing them here (`/be-workflow:future-ticket` or GitHub issues):
  - Backend: category delete cascades transactions without fixing balances.
  - Backend: `AccountHasTransactionsException` is unmapped and returns 500 instead of 409.
  - Backend: single `POST transactions` resolves the transfer target by name across all users before the ownership check.
  - Client: `CryptographyService` has a hardcoded AES key and IV.
  - Client: the `TransactionService.filter` query overwrite; `internalAuthenticateV2` uses the wrong URL.

  **Drafted, not filed.** The six items are written up as ready-to-file issues in `specs/001-standalone-desktop-mode/follow-ups.md`, each with where it is, the effect, and a suggested fix. Each was checked against the code. Backend items belong in `ramiro-di-rico/homemanagement-api`, client items in this repo. Filing them publishes them, so it waits for a go-ahead; close this task once they are filed. One correction to the task text: the transfer-target lookup (item 3) is worse than "before the ownership check": it matches **any user's** account by name, so a transaction named "Cash" can be rejected because another user's default "Cash" was found first.
- [ ] T075 Run the full `quickstart.md` (Q1–Q15 plus the performance spot-check), then `flutter analyze`, `flutter test` and `flutter build linux --release`.
  - **Required before release:** repeat Q1, Q4, Q6 and Q7 on a Windows build and a macOS build. That verifies the bundled sqlite3mc library, the keychain entitlement (T002) and Credential Manager (FR-001, SC-007).
  - Time SC-001 (first launch to first local transaction in under 2 minutes, for a first-time user).
  - Check plan.md's goal that local CRUD and balance refresh take under 100 ms with the 1,000-transaction seed.

---

## Phase 8: Review follow-ups

**Source**: [review-findings.md](./review-findings.md). Each item lists the finding it closes. Group A (data safety, before T052) is done. The remaining findings stay in that file with their suggested placement.


  **Partly done. The manual part is not.**
  - **Ran, on Linux:** `pub get`, `build_runner` (the generated drift file is unchanged), `gen-l10n` (no diff), `flutter analyze` (0 errors; the 21 warnings and ~780 hints that remain are in code this feature didn't touch, so "clean" in the quickstart was never true for this repo; the two warnings in this feature's tests were fixed), `flutter test` (337 pass), and `flutter build linux --release`, whose bundle contains `libsqlite3mc.so`.
  - **Covered by automated tests, not by hand:** Q6 (the file isn't plain SQLite) and Q7 (lost key) in `local_database_opener_test.dart`; Q4, Q5, Q8 and Q15 in part by the local-mode screen and data-source tests.
  - **Performance (plan.md goal, <100 ms):** on the real encrypted file with 5 accounts and 1,000 transactions, p95 over 20 runs: add 1.2 ms, update 0.7 ms, delete 0.6 ms, page of 10 0.8 ms, balances for 5 accounts 0.4 ms. Seeding 1,000 transactions took 1.5 s. This measures the data layer, not the screens. SC-001 (first launch to first transaction under 2 minutes) and SC-004 (import under 2 minutes) were **not** timed.
  - **Not done:** Q1-Q3 and Q8-Q15 by hand, the Windows and macOS builds, and anything against a real backend.
  - **Before the import scenarios (Q9-Q15), see `review-findings.md` SP-01 and SP-02**, which are still unchecked: the email can be burned if the app closes between registering and signing in, and the server creates the default categories and Cash account asynchronously, so the import may see none of them right after registering. Both can make Q9 fail or duplicate categories against a real backend. They are not covered by the unit tests.
- [X] T076 RF-01, UI-01 Entering local mode is single-flight and its button shows it is busy:
  - `AppModeService.enterLocalMode()` shares one running call, so a double click can't open the database twice.
  - The opener reads the key back after writing it and uses the stored value.
  - The login button is disabled with a spinner while it opens, and is released before the error dialog is shown.
- [X] T077 RF-02, RF-03, UI-02 The "local data can't be opened" screen is no longer a dead end:
  - Text per reason (new `LocalDataUnavailableReason.fileMissing`): says the data was kept, and a lost key gets no Retry.
  - "Use an online account instead" calls `AppModeService.leaveLocalMode()`, which keeps the file.
  - "Start with empty data" appears only for a missing file, as an explicit choice.
  - A failed Retry says so, and the primary action has focus.
  - At startup the file must exist (`openLocalDatabase(mustExist: true)`), so a missing file is reported and never replaced by an empty one.
  - **Still open from RF-03:** pick a real Linux `APPLICATION_ID` before release, because the application folder depends on it.
- [X] T078 RF-08 Startup can't leave the user without a window: unexpected errors while opening become `unreadable`, and a failing `SharedPreferences` starts the app online.
- [X] T079 RF-04 A failed save is never shown as a success: `AccountRepository.delete` and `CategoryRepository.add` and `update` still show the notice but rethrow, the account list no longer removes the account itself, and the category sheets stay open with what was typed. Other writes still close their sheet, with the notice showing and nothing changed.
- [X] T080 RF-05, RF-12 `guardWrite` maps only storage failures (busy, locked, read-only, I/O, corrupt, full, can't open, not a database) to "not saved", and also looks through drift's `CouldNotRollBackException`, which a full disk causes. Constraint errors and bugs now surface as bugs. Check-then-write sequences run in a transaction, so a double submit is "name taken" and not a failure.
- [X] T081 RF-06 Category names are unique by `name_key`, folded in Dart, because SQLite's `lower()` only handles ASCII. This is schema version 2 with a migration for existing files; names that only differed by accents are both kept.
- [X] T082 RF-11 A plain notice replaces a localized one that was never shown.
- [X] T083 SP-03 `UpdateCategoryModel` sends `id`, the field the server binds. Editing a category used to look for category 0 and fail, **online as well**.
- [X] T084 UI-04, UI-06 String renames and wording (see T050) and the credential-store wording, which also fits Windows.
- [X] T085 RF-18 (part) Tests for the opener (first run, key reuse, lost key, wrong key, locked keyring, missing file), the migration, and the failure paths; the weak `isA<Exception>()` assertions are now specific.
- [X] T086 SP-01 An account registered from local mode is remembered before the sign-in, so a stalled sign-in can't burn the email:
  - New `ImportStatus.registered`, appended to the enum because it is stored by index. `AppModeService.markRegistered(email)` writes it with `target_email`, and `importTargetEmail` exposes it. `registration-desktop.dart` calls it right after `register` succeeds and before `authenticate`.
  - `isImportPending` includes `registered`: writes and leaving local mode are locked, and the banner and home app bar read "Finish moving your local data". That opens the login with the email typed in (`LoginView.pathFor`, `DesktopLoginView(initialEmail:)`), or the import screen when signed in.
  - Router: while pending, registration redirects to the login (signed out) or the import screen (signed in), and `/2fa_screen` is reachable.
  - `goAfterSignIn`: only `registered` with nothing to move switches at once (US4-6). The import screen starts the move from `registered`, and the wrong-user check covers it.
  - **Still a dead end:** nothing lets the user abandon a registered-but-unfinished move (for example after forgetting the password). Leaving local mode is refused on purpose, since it would orphan the account. A decision for later.
  - Tests: `app_mode_registered_test.dart`, `registration_desktop_local_test.dart` (checked to fail without the call), and cases in the guard, post-sign-in, banner, login, import screen and mode-aware tests. Docs: data-model, spec Assumptions, contract, quickstart (Q16).
- [X] T087 SP-02 The import waits for the server to create the new user's defaults:
  - New step 1b in `LocalImportService`, after the currency preflight: poll `GET category` and `GET account` until every seeded category name and at least one account exist, backing off 1, 2, 4, then 5 s, for up to 30 s (`serverReadyTimeout`, and an injectable `delay`). Nothing is written while waiting. Past the timeout it throws `ImportServerNotReadyException`, the status is `failed`, and Retry runs it again.
  - New `ImportStep.serverSetup`, shown on the import screen as "Waiting for your online account to be ready", and the "isn't ready yet" message. Strings in en, es, es_AR.
  - Documented the backend setup (Altair `UseKafka` and the API's `UserRegistrationKafka`) in the contract and the quickstart prerequisites, with Q17.
  - Tests in `local_import_service_test.dart` (ready at once, waits then no duplicates, waits for the account, backoff, timeout then retry, shorter timeout) and `local_import_screen_test.dart`. **Not verified against a real backend.**
- [X] T088 SP-04 Smaller US4 design gaps, each checked against the code and the backend:
  - **Already handled** (now with tests where missing): `DuplicateUserName` is the code Altair returns and both are accepted (T061, T063); every mapped category is updated when it differs, not only created ones (T065); the default account is recovered by its `-default` suffix (new test); dates carry no offset (new test locks the format); the bulk endpoint, not single `POST transactions`, is used; "categories untouched" means equal to the seed (`hasUserData`).
  - **Changed:** category matching takes the exact name first, then the lowest id, so a retry picks the same one; `LocalImportService` tells the app after every status write (`onStateChanged`, wired in `main.dart`) so the write lock never lags behind.
  - **Decided and recorded** (research R12 and R13, spec FR-023, data-model step 6): a balance mismatch is reported but the move still completes and the file is archived; `POST api/users/import` is not used (it deletes first, is not atomic, and ignores `IsHidden`); `transactions/filter` is safe here because it only asks about an account id the server created for this user.
  - **Docs fixed:** the `...Z` date example in the contract, and the duplicate-email code note in R8 and the contract.
  - Tests: category tie-break (with a negative control: two fail on the old logic), default-suffix recovery, status-refresh callback, mismatch still completes, date format.
- [X] T089 RF-10 Theme and language are loaded and saved in local mode:
  - **Cause:** `UserRepository.preferences` was only opened by `AuthenticationService.init()`, which local mode skips. So `setThemeMode` and `setLocalLanguage` wrote through a null `?.` and silently did nothing: the language dropdown added in T058 did not work at all, and nothing was remembered across restarts.
  - **Fix:** `UserRepository.loadPreferences()` and `IdentityUserRepository.loadPreferences()` read the stored preferences (and re-read the theme) without signing in. `main()` calls it before `runApp`, in every mode, and a failure there leaves the defaults instead of blocking the window. Both setters now load the preferences themselves, so they can't be a no-op. A stored theme index that is out of range falls back to the system theme.
  - **Online behaviour change (list it in DR-03):** the saved theme is now restored at startup online too. Before, the repository read it before anything had loaded the preferences, so it always started with the system theme.
  - Tests: `identity_user_repository_local_preferences_test.dart` (survives a restart, no server call, works without loading first, notifies, bad index) and `local_preferences_widget_test.dart`. Three of them fail on the old code. `main()` itself is not tested; it is one guarded call.
  - **Not done:** applying the language to the first-run login screen on a fresh install (no saved choice) still follows the system language.
- [X] T090 RF-13 The encryption check happens before anything is written, and the key is validated:
  - **`applyKey`** (`local_database_opener.dart`) now sets the passphrase in the database's own isolate and requires `PRAGMA key` to answer exactly one row, `ok` (checked against sqlite3mc). A SQLite that doesn't know the pragma answers nothing, so the open fails before drift creates or seeds a plaintext file, and is reported as `notEncrypted`. `PRAGMA cipher` could not tell them apart, since it reports a cipher either way, so it is only a second check now.
  - **The key is validated** against the base64url alphabet before it is used (`^[A-Za-z0-9_\-=]+$`). A damaged keyring value, for example one with a quote, is reported as `unreadable` before any file is touched. It is never replaced, and never appears in the error. Without the check, a quote either broke the statement or, when escaped, silently changed the passphrase.
  - New `keySetup` parameter on `openLocalDatabase`, for tests only (a top-level function, because it runs in the isolate).
  - Tests in `local_database_opener_test.dart`: damaged keys with no file and with an existing one, the key never appearing in the error, generated keys passing, `applyKey` against sqlite3mc and a stand-in plain SQLite, and the opener with a library that refuses the key (no data written). Seven fail on the old behavior.
- [X] T091 RF-14 Local suggestions match what the server offers per name and type:
  - **Query:** one row per (name, type), the latest by date and then id (`ROW_NUMBER() OVER (PARTITION BY name, transaction_type ORDER BY date DESC, id DESC)`), most recent first, with no `LIMIT`. Before, it grouped by name only, took `MAX(id)`, and kept 10 names. That collapsed an income and an outcome with the same name, let a back-dated entry override the current amount and category, and hid any name outside the latest ten, because the sheet filters this list by what is typed.
  - **Still different from the server, on purpose:** the server only suggests names that recur in enough distinct months (default 6) and sends neutral id, account and date. Local suggests every name and type that exists, because a new local dataset would otherwise have none for its first months. The sheet copies only the name, category, amount and type, so the neutral values don't matter. Documented in the method's comment and in `contracts/data-sources.md`.
  - Tests in `local_services_test.dart` (one per name, latest by date not by entry order, same-date tie, both types, 25 names with no cap, case-sensitive names, category name, delete). Three fail on the old query.
- [X] T092 RF-15 A deactivated category stops being offered, and can be switched back on (local mode):
  - **Checkbox:** the Active checkbox on the categories list was `onChanged: (value) {}`. It now calls the new `CategoryRepository.setActive`, which saves first and only then replaces the category in the list, so a failed save (or a pending move, with its own notice) leaves what is shown as it was. The "category in use, deactivate instead" dialog uses the same method, which also fixes it ignoring a failed save and reloading the whole list.
  - **Pickers:** the desktop add-transaction sheet offers only active categories in local mode (`CategoryRepository.selectable`). Editing a transaction keeps the category it already has, even if deactivated since. A new transaction starts on the first active category. Choosing a past transaction whose category was switched off fills the name, amount and type but keeps the current category. If every category is off, all are offered rather than leaving an empty picker.
  - **Online is unchanged, on purpose:** the server creates every category inactive and the app never sends a follow-up update (research R4), so filtering the shared pickers online would hide categories the user just added. The checkbox stays a no-op online. Listed in `follow-ups.md` as item 4.
  - **Not done:** the Measurable checkbox is the same kind of no-op (`onChanged: (value) {}`) and is not in this finding. The mobile sheet is not filtered, since local mode is desktop-only. The edit sheet has no active toggle; the checkbox is the way to reactivate.
  - Tests: `category_active_toggle_test.dart` (toggle both ways, saved, only that field changes, deactivate from the in-use dialog, failed save, pending move, online unchanged, the picker helper) and `add_transaction_sheet_inactive_category_test.dart`. Five checkbox tests and three sheet tests fail on the old code.

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: none. **T005 gates everything after it.**
- **Foundational (Phase 2)**: depends on Phase 1. T006–T015 (the seam) can ship as their own PR before T016+.
- **US1 (Phase 3)**: depends on Phase 2.
- **US2 (Phase 4)**: depends on Phase 2. In practice it's exercised through US1's entry point, but its tests (T039) only need Phase 2.
- **US3 (Phase 5)**: depends on US1 (T032 router, T036–T037 home).
- **US4 (Phase 6)**:
  - The client tasks depend on US1 and US3 (T051 allowlist, T054 banner).
  - T071 needs a locally running backend.
- **Polish (Phase 7)**: after the stories you intend to ship.

### Within a phase

- The interface tasks (T006–T009) come before the implementations (T010–T014).
- T016 → T017 → T019–T022.
- T018 → T025 → T026 → T027.
- l10n key tasks (T031, T040, T050, T062) come before the UI tasks in the same story.
- T063 → T064. T065 → T068 → T069 → T070.
- T026 (delegates) and T065 (import state) → T066 (write lock). T067 depends on T025.

### Parallel opportunities

- **Phase 1**: T002, T003 and T004 together.
- **Phase 2**:
  - T006–T009 together.
  - T011, T012 and T013 together, after their interfaces.
  - T019–T022 together, after T017.
  - T023, T024 and T028 together.
- **US1**: T029 and T030 together.
- **US3**: T048 and T049, then T054–T058 together (different files).
- **US4**: T060 and T061 together.

---

## Parallel Example: Phase 2 local services

```text
Task: "LocalCurrencyService in lib/data/local/local_currency.service.dart" (T019)
Task: "LocalAccountService in lib/data/local/local_account.service.dart" (T020)
Task: "LocalCategoryService in lib/data/local/local_category.service.dart" (T021)
Task: "LocalTransactionService in lib/data/local/local_transaction.service.dart" (T022)
```

## Parallel Example: User Story 3

```text
Task: "Local-mode banner in lib/ui/features/local_mode/views/local_mode_banner.dart" (T054)
Task: "Hide CSV/main accounts in account-list-desktop.dart" (T055)
Task: "Hide metrics in account-detail-desktop.dart" (T056)
Task: "Hide voice/receipt/tags in add_transaction_sheet_desktop.dart" (T057)
Task: "Hide server-only sections in settings_desktop.dart" (T058)
```

---

## Implementation Strategy

### MVP first (US1 + US2, both P1)

1. Phase 1 (with the T005 spike as a go/no-go).
2. Phase 2. Ship the seam (T006–T015) as PR 1 and the local database (T016–T028) as PR 2.
3. US1 (PR 3), then **stop and validate** with quickstart Q1–Q3 and Q7.
4. US2 (PR 3 or 4), and validate Q4–Q5. This is a usable offline app.

### Incremental delivery

5. US3 (PR 5) is the clean offline UI. Release local mode to users after this, because before US3 server-only buttons are still visible.
6. US4: the client import (PR 6). No backend change and no release gate on the backend.
7. Polish.

### Notes

- Consider merging `feat/price-to-amount` before Phase 2. It renames `TransactionModel.price` to `amount` (research R11).
- Commit after each task or logical group. Don't commit the unrelated in-flight `analysis_options.yaml` / `devtools_options.yaml` changes with these tasks unless the T003 edit is coordinated.
