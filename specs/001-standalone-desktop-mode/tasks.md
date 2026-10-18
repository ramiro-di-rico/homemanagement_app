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
- [ ] T027 Wire everything in `lib/main.dart`:
  - Make `main()` `async` and call `WidgetsFlutterBinding.ensureInitialized()`.
  - Create and `await AppModeService(platform).init()`, then register it as a singleton **before** `registerSingletons`.
  - In `registerSingletons`, construct `AccountRepository`, `CategoryRepository`, `CurrencyRepository` and `TransactionRepository` with the `ModeAware*` delegates wrapping the existing HTTP services.
  - Leave the `registerServices` factories (used directly by some views) unchanged.
- [X] T028 [P] Write `test/data/services/mode_aware_data_sources_test.dart`. Fake remote implementations record calls. Check that calls go to the fake remote when online and to the local service (in-memory database) when local, and that flipping the mode switches routing without re-creating repositories.

**Checkpoint**: The seam is in place, online behaviour is unchanged, and the local database is encrypted and tested. User stories can start.

---

## Phase 3: User Story 1 - Start using the app without an account (Priority: P1) 🎯 MVP

**Goal**: A "Use without an account" entry on desktop login opens a working local home with zero network calls. Relaunching returns to it.

**Independent Test**: quickstart Q1, Q2, Q3 and Q7. With the network disconnected, choose the option, close and reopen the app: it goes straight to the local home with no errors.

### Tests for User Story 1

- [ ] T029 [P] [US1] Extend `test/views/login_view_test.dart`, or add `test/views/login_desktop_local_option_test.dart`:
  - The "Use without an account" button renders for `PlatformType.Desktop`.
  - It is absent for `Web` and `Mobile`.
  - Tapping it calls `AppModeService.enterLocalMode` and navigates to `/home_screen`.
- [ ] T030 [P] [US1] Write `test/views/local_mode_guard_test.dart` for the router `redirect` built by `Routing.createRoutes` with a fake `AppModeService(isLocal: true)` and an unauthenticated `AuthenticationService`:
  - `/login_screen` → `/home_screen`.
  - `/home_screen` is allowed.
  - `/public/invites/abc` and `/login_screen?view=reset_password` redirect to `/home_screen` in local mode.
  - Online mode is unchanged (still redirects to login, and invite and reset links still work).

### Implementation for User Story 1

- [ ] T031 [US1] Add the l10n keys `useWithoutAccount`, `localModeUnavailableTitle`, `localModeKeyringUnavailable`, `localDataCannotBeOpened` and `localDataCannotBeOpenedDetail` to `lib/l10n/app_en.arb`, plus Spanish in `app_es.arb` and `app_es_ar.arb`. `it` and `pt` fall back to English. Then run `flutter gen-l10n`.
- [ ] T032 [US1] Update `lib/routing.dart`:
  - `createRoutes` takes `AppModeService` and passes it as `refreshListenable`.
  - In `redirect`, put the local-mode block at the **very top**, before the password-reset state, the `?view=reset_password` query and the `/public/invites/` check, because all of those reach the server (FR-004). When `appModeService.isLocal`: send `/login_screen` to `/home_screen`, and allow `HomeScreen.fullPath` without authentication.
  - Leave the full allowlist (FR-016) to US3, T048.
- [ ] T033 [US1] Update `lib/myapp.dart` to resolve `AppModeService` from GetIt and pass it to `Routing.createRoutes`. If `appModeService.startupError != null`, render `LocalDataUnavailableScreen` instead of the router.
- [ ] T034 [US1] Create `lib/ui/features/local_mode/views/local_data_unavailable_screen.dart` (the "local data cannot be opened" spec edge case):
  - Explains the reason (keyring locked/unavailable, key missing, not encrypted) using the T031 strings.
  - Offers **Retry**, which re-runs `AppModeService.init()`.
  - Never offers to delete or reset the data.
  - Uses theme colours only (light and dark).
- [ ] T035 [US1] Update `lib/ui/features/authentication/views/login-desktop.dart`:
  - When `GetIt.I<AppModeService>().isLocalAvailable`, add a `TextButton(l10n.useWithoutAccount)` next to the "Create one" link (around line 162).
  - On tap, `await enterLocalMode()` then `context.go(HomeScreen.fullPath)`.
  - On `LocalDataUnavailableException(keyringUnavailable)`, show `localModeKeyringUnavailable` in a dialog and stay on login.
- [ ] T036 [US1] Update `lib/ui/features/home/views/home-desktop.dart` `initState`:
  - When `appMode.isLocal`, only call `AccountRepository.load()`, `CurrencyRepository.load()` and `CategoryRepository.load()`.
  - Skip `TagRepository.load()`, `IdentityUserRepository.getUser()`, `BudgetRepository.load()` and the `useMainAccounts` read, and force `useMainAccounts = false`.
- [ ] T037 [US1] Update `lib/ui/features/home/views/home-desktop.dart` body: when local, render only `AccountListDesktopView`. Don't build `DashboardDesktop` (`BalanceWidget`, `OverviewWidget` and `BalanceHistoricalChartWidget` all call `MetricService`) or `RecurringTransactionList`, so no server request is made (FR-004).
- [ ] T038 [US1] Check FR-004 by hand. Run the Linux debug build with the network disabled, enter local mode, and watch the logs (`lib/data/services/logger_wrapper.dart` output / Logging view) for any HTTP attempt during startup and home load. Fix any caller found.

**Checkpoint**: US1 is fully functional. The MVP can be demoed: offline start, local home, relaunch.

---

## Phase 4: User Story 2 - Manage accounts, categories and transactions locally (Priority: P1)

**Goal**: Full CRUD in local mode, with balances that always equal the transaction sums and data that persists.

**Independent Test**: quickstart Q4 and Q5. Create two accounts in different currencies, manage categories, add/edit/duplicate/delete transactions, restart, and verify everything including balances.

### Tests for User Story 2

- [ ] T039 [P] [US2] Write `test/data/repositories/local_repositories_test.dart`. Using `ModeAware*` in local mode on an in-memory database, check that:
  - `TransactionRepository.add` updates `AccountRepository.accounts` balance from the result.
  - `remove` and `update` keep the in-memory balance equal to a fresh `fetchAccounts()` balance.
  - Run this over 1,000 random operations across 5 accounts (SC-003).

### Implementation for User Story 2

- [ ] T040 [US2] Add the l10n keys `accountHasTransactions`, `categoryInUse`, `deactivateCategory`, `categoryNameTaken` and `changeNotSaved` to `lib/l10n/app_en.arb`, `app_es.arb` and `app_es_ar.arb`, then run `flutter gen-l10n`.
- [ ] T041 [US2] In `lib/ui/features/accounts/views/account-list-desktop.dart` (delete action around line 378), catch `AccountHasTransactionsException` from `AccountRepository.delete` and show `l10n.accountHasTransactions` through the existing notifier/snackbar path, instead of a generic error. Also make sure `AccountRepository.delete` in `lib/data/repositories/account.repository.dart` rethrows typed exceptions rather than swallowing them.
- [ ] T042 [US2] In `lib/ui/features/settings/views/settings-widgets/categories_list_widget.dart` (delete around line 215), catch `CategoryInUseException`. Show a dialog with `l10n.categoryInUse` and a `l10n.deactivateCategory` action that calls `CategoryRepository.update` with `isActive = false`.
- [ ] T043 [US2] In `lib/ui/features/settings/views/settings-widgets/add_category_sheet.dart` and `edit_category_sheet.dart`, catch `CategoryNameTakenException` and show `l10n.categoryNameTaken`.
- [ ] T044 [US2] Handle failed local writes (spec edge case "low disk space"):
  - In `lib/data/local/local_account.service.dart`, `local_category.service.dart` and `local_transaction.service.dart`, wrap `SqliteException` and `FileSystemException` thrown by writes as `LocalWriteFailedException`.
  - In `account.repository.dart`, `category.repository.dart` and `transaction.repository.dart`, catch it, show `l10n.changeNotSaved` through `NotifierService`, and leave the in-memory state (lists and balances) unchanged.
  - Add a case to `test/data/local/local_services_test.dart` that writes to a closed database and expects `LocalWriteFailedException`.
- [ ] T045 [US2] Verify that `lib/ui/features/home/views/shared/account-sheet-dektop.dart` (create) and `account.sheet.dart` (edit from the desktop list) list currencies from `CurrencyRepository` in local mode (USD/ARS/EUR) and save via `AccountRepository.add/update`. Fix any direct `CurrencyService` use you find.
- [ ] T046 [US2] Verify that `lib/ui/features/accounts/views/widgets/add_transaction_sheet_desktop.dart` (add/update around lines 473–475, suggestions around line 89) and `lib/ui/features/accounts/views/widgets/transaction.row.info.dart` (duplicate/delete around lines 40 and 183) work in local mode through `TransactionRepository`, and that `AccountDetailDesktop` paging (`loadFirstPage`/`nextPage`) lists most recent first (FR-010). Fix only actual breakages.
- [ ] T047 [US2] Run quickstart Q4 and Q5 by hand on a Linux build. Restart the app between steps and confirm persistence (FR-013).

**Checkpoint**: US1 and US2 both work. Local mode is useful on its own.

---

## Phase 5: User Story 3 - A home screen showing only what works offline (Priority: P2)

**Goal**: Every server-only entry point is hidden in local mode, hidden routes redirect home, and a persistent local-mode banner with "Create account" is shown.

**Independent Test**: quickstart Q8. Go through every AppBar action, Settings, account detail and the add-transaction sheet in local mode: no server request and no server error. Hidden routes redirect home.

### Tests for User Story 3

- [ ] T048 [P] [US3] Extend `test/views/local_mode_guard_test.dart`. In local mode:
  - These paths stay put: `/home_screen`, `/home_screen/account_detail_screen`, `/home_screen/settings_screen`, `/home_screen/logging_screen`, `/registration_screen`, `/home_screen/local_import`.
  - These redirect to `/home_screen`: `/home_screen/budget`, `/home_screen/invites`, `/home_screen/statistics`, `/home_screen/reconciliation`, `/home_screen/bulk_transactions`, `/home_screen/account_detail_screen/account_metrics_screen`, and both search paths.
- [ ] T049 [P] [US3] Write `test/views/home_desktop_local_mode_test.dart`. In local mode, the AppBar shows only Settings and "Create account" and "Log in to an existing account" (the last one is hidden when `isImportPending`). Search, Bulk, Invitations, Statistics, Budget, Reminders and Logout are absent. The local-mode banner is visible.

### Implementation for User Story 3

- [ ] T050 [US3] Add the l10n keys `localModeBanner` ("You're working locally on this computer"), `createAccountToSync`, `logInExistingAccount` and `logInExistingAccountConfirm` ("Your local data will stay on this computer and won't be moved to that account.") to `lib/l10n/app_en.arb`, `app_es.arb` and `app_es_ar.arb`, then run `flutter gen-l10n`.
- [ ] T051 [US3] Complete the FR-016 allowlist in `lib/routing.dart`. In local mode, return `null` only for the paths listed in T048. Redirect everything else to `HomeScreen.fullPath`.
- [ ] T052 [US3] Update the AppBar `actions` in `lib/ui/features/home/views/home-desktop.dart` (lines 63–121). When local, show only Settings and a `createAccountToSync` action that does `context.go(RegistrationScreen.fullPath)`. Also show a `logInExistingAccount` action unless `appMode.isImportPending` (see the next task). Hide Search, Bulk, Invitations, Statistics, Budget, Reminders and Logout.
- [ ] T053 [US3] Implement "Log in to an existing account" (spec FR-027, US3 scenarios 7–8):
  - Add `Future<void> leaveLocalMode()` to `lib/data/services/app_mode.service.dart`. It closes the database **without renaming or deleting the file**, persists `appMode = online`, clears `Caching` and `TransactionRepository.invalidateSuggestions()`, notifies, and reloads the Account, Currency and Category repositories. It throws if `isImportPending`.
  - The `logInExistingAccount` AppBar action in `lib/ui/features/home/views/home-desktop.dart` shows a confirmation dialog with `l10n.logInExistingAccountConfirm`. On confirm it calls `leaveLocalMode()`, then `context.go(LoginView.fullPath)`.
  - The next "Use without an account" reopens the same `homemanagement_local.sqlite` with the same key (T018 already reuses an existing file and key).
  - Add cases to `test/data/services/mode_aware_data_sources_test.dart`: after `leaveLocalMode()`, calls go to the remote; after `enterLocalMode()`, the earlier local rows are still there.
- [ ] T054 [P] [US3] Create `lib/ui/features/local_mode/views/local_mode_banner.dart`. It's a `MaterialBanner`-style strip using `Theme.of(context).colorScheme` (follow `.claude/skills/flutter-theme-and-styling/SKILL.md`) with `l10n.localModeBanner` and a `createAccountToSync` button. Mount it at the top of `HomeDesktop`, `AccountDetailDesktop` and `SettingsDesktopView` (`lib/ui/features/settings/views/settings_desktop.dart`) when local, so it's on every local-mode screen (FR-017, US3 scenario 6).
- [ ] T055 [P] [US3] Update `lib/ui/features/accounts/views/account-list-desktop.dart`. When local, hide CSV export/import (around lines 305 and 351, which use `TransactionService` directly) and the main-accounts toggle.
- [ ] T056 [P] [US3] Update `lib/ui/features/accounts/views/account-detail-desktop.dart`. When local, skip `MetricService.getOverallByAccountId` and its panel (around lines 297–343), and hide the CSV and metrics navigation. The field `transactionService = GetIt.I<TransactionService>()` at line 48 must not be used in local mode.
- [ ] T057 [P] [US3] Update `lib/ui/features/accounts/views/widgets/add_transaction_sheet_desktop.dart`. When local, hide voice dictation, receipt scanning and the tags input.
- [ ] T058 [P] [US3] Update `lib/ui/features/settings/views/settings_desktop.dart`. When local, keep `CategoriesListWidget` plus the appearance and language options. Hide the profile, security/2FA, invitations, main-accounts and user-settings sections, and anything else calling `IdentityUserService`, `UserSettingsService` or `InviteService`.
- [ ] T059 [US3] Run quickstart Q8 and Q15 (the part without an import) by hand with the network disabled. Click every remaining control and confirm there's no error toast and no HTTP attempt in the logs.

**Checkpoint**: Local mode is clean. Only working features are visible.

---

## Phase 6: User Story 4 - Create an account and bring local data along (Priority: P2)

**Goal**: Register from local mode, move all local data once into the new account (resumably and without duplicates), verify balances, archive the local file, and switch to online.

**Independent Test**: quickstart Q9–Q15 against a local backend (no backend changes needed).

### Tests for User Story 4

- [ ] T060 [P] [US4] Write `test/data/services/local_import_service_test.dart` with hand-written fakes for `AccountDataSource`, `CategoryDataSource`, `CurrencyDataSource` and a fake bulk/verify client, over an in-memory local database. Cover:
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
- [ ] T061 [P] [US4] Write `test/data/services/identity_service_register_test.dart` using an `http` `MockClient` (from `package:http/testing.dart`, already available through `http`):
  - 200 → `success`.
  - 400 with a body containing `DuplicateEmail` or `DuplicateUserName` → `emailTaken`.
  - Other 400s and 5xx → `failed`.

### Implementation for User Story 4

- [ ] T062 [US4] Add the l10n keys `importTitle`, `importProgressCategories`, `importProgressAccounts`, `importProgressTransactions`, `importVerifying`, `importDone`, `importBalanceMismatch`, `importFailed`, `importResume`, `importCurrencyMissing`, `emailAlreadyRegistered`, `importWrongUser` and `importPendingReadOnly` to `lib/l10n/app_en.arb`, `app_es.arb` and `app_es_ar.arb`, then run `flutter gen-l10n`.
- [ ] T063 [US4] In `lib/data/services/identity.service.dart`, change `register` to return `enum RegistrationResult { success, emailTaken, failed }`. Parse the 400 body for `DuplicateEmail` or `DuplicateUserName` (research R8). First confirm in `../Altair/AltairUserManagement` that `RegisterUserAsync` uses `UserManager.CreateAsync`, and note the result in research.md R8. Update `AuthenticationService.register` in `lib/data/services/authentication.service.dart` to pass the enum through.
- [ ] T064 [US4] Update every caller of `register`: `lib/ui/features/authentication/views/registration-desktop.dart` (lines 29–63) and the mobile `registration.dart`.
  - On `emailTaken`, show `l10n.emailAlreadyRegistered` and stay on the screen, in local mode (FR-026).
  - On success in local mode with local data present, go to `LocalImportScreen.fullPath` instead of home.
  - With no local data (only seeds: no accounts, no transactions, categories untouched), call `appMode.completeImport()` directly (US4 scenario 6).
- [ ] T065 [US4] Create `lib/data/services/local_import.service.dart` implementing the import state machine in `specs/001-standalone-desktop-mode/data-model.md`. It takes `LocalDatabase` plus the remote `AccountService`, `CategoryService`, `CurrencyService`, `TransactionService` (via the interfaces and a small `BulkTransactionClient` interface for fakes) and `AuthenticationService`.
  - **Step 0**: set `import_states.status = inProgress`, `target_email`, `started_at`, and (once) `import_tag` = 8 random hex chars. On resume, require `authenticationService.user.email == target_email`, otherwise fail with `importWrongUser`.
  - **Step 1, preflight**: check currencies by `name`. If any is missing, throw `importCurrencyMissing` listing the codes.
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
- [ ] T066 [US4] Lock local writes while an import is pending (spec FR-022, data-model "Local writes are locked"):
  - In `lib/data/services/sources/mode_aware_data_sources.dart`, every add, update and delete throws `LocalDataLockedException` when `appMode.isLocal && appMode.isImportPending`. Reads are unaffected.
  - The repositories catch it and show `l10n.importPendingReadOnly` through `NotifierService`.
  - Add cases to `test/data/services/mode_aware_data_sources_test.dart`: writes are rejected while the status is `inProgress` or `failed`, and allowed when it is `notStarted`.
  - Add a case to `test/data/services/local_import_service_test.dart`: fail at step 4 → a write attempt is rejected → resume → the server data equals the local data.
- [ ] T067 [US4] Implement `AppModeService.completeImport()` in `lib/data/services/app_mode.service.dart`:
  - Close the database.
  - Rename the file in `getApplicationSupportDirectory()` to `homemanagement_local.backup-YYYY-MM-DD.sqlite`, adding `-N` if it exists.
  - The rename alone makes the next local session start fresh (spec edge case "returning to local mode later"), since the active file name is constant.
  - Set `appMode = online`, call `Caching` clear-all (`lib/data/services/caching.dart`) and `TransactionRepository.invalidateSuggestions()`, and notify.
  - Then reload `AccountRepository`, `CurrencyRepository` and `CategoryRepository`.
- [ ] T068 [US4] Create `lib/data/repositories/local_import.repository.dart`: `LocalImportRepository extends ChangeNotifier`, wrapping `LocalImportService`.
  - Exposes `status`, `step`, `progress`, `mismatches` and `error`.
  - `start()` and `resume()` methods.
  - On success it calls `AppModeService.completeImport()`.
  - Register it in `lib/main.dart` (hand-registered).
- [ ] T069 [US4] Create `lib/ui/features/local_mode/views/local_import_screen.dart` (`static const path = '/local_import'`, `fullPath = '/home_screen/local_import'`).
  - On open, calls `LocalImportRepository.start()` automatically when the status is `notStarted` (US4 scenario 1). With `inProgress` (an app restart mid-import), it calls `resume()`. With `failed`, it shows Retry and waits.
  - Shows per-step progress from `LocalImportRepository` via `ListenableBuilder`.
  - Shows the summary with any balance mismatches (FR-023), then a "Continue" button to `HomeScreen.fullPath`, which is now online.
  - On failure, shows `importFailed` with **Retry** (calls `resume()`). The app stays local and the data stays intact (FR-022).
  - Register the route as a child of `/home_screen` in `lib/routing.dart`, following `.claude/skills/flutter-add-route/SKILL.md`.
- [ ] T070 [US4] Handle a resumed import:
  - In `lib/ui/features/local_mode/views/local_mode_banner.dart`, when `import_states.status` is `inProgress` or `failed`, show `importResume`. It opens the import screen, or registration/login if unauthenticated.
  - In `lib/routing.dart`, while an import is pending and the user isn't authenticated, allow `/login_screen` in local mode instead of redirecting it home.
  - In `lib/ui/features/authentication/views/user-controls-mixins/authentication-behavior.dart` `successFullAuthentication`, go to `LocalImportScreen.fullPath` when local with an import pending.
- [ ] T071 [US4] Run quickstart Q9–Q15 by hand against a local backend (`../home-management-all` docker compose, `--dart-define=BACKEND_ORIGIN=http://localhost:8088`). Time Q9 with 5 accounts, 20 categories and 1,000 transactions; it must take under 2 minutes (SC-004).

**Checkpoint**: All user stories work on their own and together.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T072 [P] Update `CLAUDE.md` (Architecture → Data Flow / Key Infrastructure) and `AGENTS.md`: describe `lib/data/local/`, the `ModeAware*` delegates, `AppModeService`, and that drift code is generated with `build_runner` and committed.
- [ ] T073 [P] Add a `.claude/skills/` note, or extend `flutter-new-feature/SKILL.md`: a new repository-backed resource must define a data-source interface, and must either get a local implementation or be hidden in local mode.
- [ ] T074 [P] Park the out-of-scope findings as follow-ups, without fixing them here (`/be-workflow:future-ticket` or GitHub issues):
  - Backend: category delete cascades transactions without fixing balances.
  - Backend: `AccountHasTransactionsException` is unmapped and returns 500 instead of 409.
  - Backend: single `POST transactions` resolves the transfer target by name across all users before the ownership check.
  - Client: `CryptographyService` has a hardcoded AES key and IV.
  - Client: the `TransactionService.filter` query overwrite; `internalAuthenticateV2` uses the wrong URL.
- [ ] T075 Run the full `quickstart.md` (Q1–Q15 plus the performance spot-check), then `flutter analyze`, `flutter test` and `flutter build linux --release`.
  - **Required before release:** repeat Q1, Q4, Q6 and Q7 on a Windows build and a macOS build. That verifies the bundled sqlite3mc library, the keychain entitlement (T002) and Credential Manager (FR-001, SC-007).
  - Time SC-001 (first launch to first local transaction in under 2 minutes, for a first-time user).
  - Check plan.md's goal that local CRUD and balance refresh take under 100 ms with the 1,000-transaction seed.

---

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
