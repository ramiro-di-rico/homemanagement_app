# Research: Standalone Desktop Mode

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Date**: 2026-10-15. Package ages are checked against the org's 7-day dependency-freshness rule as of this date.

## R1. Local storage engine

- **Decision**: drift **2.35.2** + drift_flutter **0.3.1**, with code generation via drift_dev **2.35.1** + build_runner **2.16.2**. sqlite3 **3.7.0** is added as a direct dependency (needed for the build-hook config and the raw `Database` type in the setup callback) and pinned exactly.
- **Rationale**:
  - Typed schema and queries, a first-class `MigrationStrategy`, and an in-memory database for tests (the repo has no mocking library).
  - sqlite3 3.x bundles a prebuilt, hash-checked SQLite per OS/ABI through a Dart build hook, so no system `libsqlite3` is needed on Linux, Windows or macOS.
  - `sqlite3_flutter_libs` and `sqlcipher_flutter_libs` are end-of-life and **must not** be added.
- **Freshness**:

  | Package | Version | Published | Note |
  |---|---|---|---|
  | drift | 2.35.2 | 2026-10-07 | |
  | drift_dev | 2.35.1 | 2026-09-30 | |
  | drift_flutter | 0.3.1 | 2026-07-11 | |
  | build_runner | 2.16.2 | 2026-10-07 | 2.17.1 (2026-10-14) is too new; 2.17.0 was retracted |
  | sqlite3 | 3.7.0 | 2026-09-30 | 3.7.1 (2026-10-13) is too new, so pin `sqlite3: 3.7.0` |

- **Dependency conflict found during T001**: flutter_secure_storage 11.x depends on `win32 ^6`, but the app's `file_picker 10.3.10` needs `win32 ^5.9`, so `pub get` fails with 11.2.0. Upgrading file_picker (12.x/13.x, a major bump used in 7 files) is out of scope for this feature, so **flutter_secure_storage is pinned to 10.3.4** (newest 10.x, published 2026-09-13). The platform notes in R2 were researched against 11.2.0 and **must be re-confirmed against 10.3.4 in the T005 spike** (libsecret on Linux, keychain entitlement on macOS). Revisit when file_picker is upgraded.
- **Compatibility**: drift_dev 2.35.1 (analyzer `>=13 <15`) and build_runner 2.16.2 (analyzer `>=14.3 <15`) overlap on analyzer 14.3–14.5, and both work with Dart 3.12. This has not been resolved with `pub get` yet; it is the first step of the Phase 0 spike.
- **Build note**: the first build downloads the SQLite binary from GitHub (it honours `HTTPS_PROXY` and is cached in `.dart_tool/hooks_runner/`). Offline CI needs `url_pattern` pointed at a mirror.
- **Alternatives considered**:
  - **sqflite_common_ffi 2.4.3**: no code generation, but raw SQL, hand-written migrations, no compile-time checks.
  - **Hive / Isar**: not relational. The derived balances and the import ordering are much easier in SQL.

## R2. Encryption at rest (FR-014, SC-007)

- **Decision**:
  - **SQLite3MultipleCiphers** via the sqlite3 build hook: `hooks: user_defines: sqlite3: source: sqlite3mc` in `pubspec.yaml`.
  - **The key**:
    - It is a 256-bit random value. It is generated on the first entry into local mode and stored with flutter_secure_storage **10.3.4** (2026-09-13) under `local_db_key_v1`.
    - It is read **before** opening the database and passed as a plain `String` into `DriftNativeOptions(setup: (db) => db.execute("PRAGMA key = ..."))`.
    - The setup callback runs in a background isolate, so it may only capture sendable values.
  - **Self-check**: after opening, `PRAGMA cipher` must return a row. If it doesn't, the database is closed and an error is raised. The app never runs unencrypted.
- **Rationale**:
  - Drift's encryption docs recommend sqlite3mc, which ships a newer SQLite core than the SQLCipher build.
  - sqlite3mc has built-in ciphers, which avoids the unresolved question of how OpenSSL is linked into the prebuilt SQLCipher binaries on Linux and Windows.
  - It is a fresh database, so there's no SQLCipher-format compatibility to preserve.
- **Platform requirements for flutter_secure_storage**:
  - **Linux**: needs `libsecret-1-dev` to build (currently **not installed** on the dev machine) and `libsecret-1-0` plus a running Secret Service (gnome-keyring or KWallet) at runtime. A locked or missing keyring raises a catchable `PlatformException` (e.g. `KeyringLocked`).
  - **macOS**: needs the Keychain Sharing entitlement (`keychain-access-groups`) in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`, which currently have none. Without it, writes look like they succeed but don't persist.
  - **Windows**: needs the C++ ATL components in VS Build Tools.
- **Failure policy**:
  - **Keyring unavailable when entering local mode**: local mode is not entered. The user sees a message explaining that the system keyring must be available or unlocked.
  - **Keyring unavailable on a later launch**: the app shows the "local data cannot be opened" screen (spec edge case). It **never** recreates or overwrites the file.
  - **Lost keyring**: data is unrecoverable, which is an accepted risk (spec clarification Q3).
- **Alternatives considered**:
  - **SQLCipher (`source: sqlcipher`)**: viable, but the OpenSSL linking is unverified.
  - **User passphrase**: rejected by spec clarification Q3.
  - **No encryption**: rejected by FR-014.
- **Spike result (T005, 2026-10-16, Linux x64 release build): PASSED**, after one build fix. Evidence:
  - `PRAGMA cipher` returns a row (`chacha20`), so the self-check works with `source: sqlite3mc`.
  - A row written through drift reads back through drift. After closing, the file header is random bytes (not `SQLite format 3`), and the inserted text is not visible in the file.
  - Opening the file with **no key** or the **wrong key** fails with `SqliteException(26) file is not a database`. Reopening with the right key returns the row.
  - The key round-trips through flutter_secure_storage 10.3.4 across separate process runs.
  - The key was set as a passphrase: `PRAGMA key = '<base64url of 32 random bytes>'`. The raw `x'<hex>'` form was **not** tested, so the opener uses the passphrase form.
  - drift_dev 2.35.1 + build_runner 2.16.2 generate code on Dart 3.12 (about 39 s, because it analyses all ~950 inputs in the repo).
- **Build fix needed (found by the spike)**: the sqlite3 build hook downloads and builds `libsqlite3mc.so` into `build/native_assets/<os>/`, but this project's `linux/CMakeLists.txt` and `windows/CMakeLists.txt` predate Flutter's native-assets install step. Without it, the release bundle has **no SQLite library** and the app fails at the first database call (`Failed to load dynamic library 'libsqlite3mc.so'`). Fixed by adding the template's `install(DIRECTORY "${NATIVE_ASSETS_DIR}" …)` block to both files. Linux is verified (the library is in `bundle/lib/`). **Windows is the same block but not built or run here**; macOS needed no change in the fresh template.
- **Keyring behaviour found by the spike**: when started from a shell inside a snap environment (here IntelliJ's snap; `SNAP_NAME` set), libsecret used its **file backend** (it opened `~/.local/share/keyrings/default.keyring`) instead of the Secret Service. Started with the `SNAP_*` variables removed, it used the Secret Service over D-Bus and stored one item (label `<app-id>/FlutterSecureStorage`, attribute `account=<app-id>.secureStorage`) in the `login` collection. The plugin keeps **all** the app's keys as one JSON item. Both paths worked. A user launching the app normally gets the Secret Service. Developers launching from a snap IDE terminal may see the file backend.
- **Still unverified**: Windows and macOS builds (no machines here), and a Flatpak/Snap-packaged app. T077 keeps the Windows and macOS runs as a release requirement.

## R3. Backend: account creation response

- **Decision**: no backend change. The client's `AccountService.add` parses the response and returns the created `AccountModel`.
- **Evidence**: `POST api/account` already returns **201 Created** with `AccountResultDto(Id, Name, Balance, AccountType, CurrencyId, Measurable, Archive, IsHidden, UserId)`. See `homemanagement-api/HomeManagementApi/Controllers/Accounts/AccountController.cs:73-88`. The client currently discards the body.
- **Impact**: the plan assumed a backend change; it isn't needed. The spec assumption ("the server returns the created account") holds today.

## R4. Backend: what a new user starts with

- **Evidence**: `UserService.AddUserAsync` (`HomeManagement.Business/Features/User/UserService.cs:290-343`) creates:
  - one "Cash" account (Cash, **USD**);
  - **17 categories** from `HomeManagement.Database/Seed/CategoryInitializer.cs`: Various, Rent, Transportation, Supplies, Entertainment, Gift, Clothes, Education, Health, Salary, Bond, Services, Savings, Transfers, Donations, Extraction, Deposit (each with a Material icon);
  - user settings.
- **`POST category/v1` quirks**: it ignores `isActive`, `measurable` and `color`, creates the category **inactive**, and does **not** reject duplicate names.
- **Decision**:
  - The local default categories are seeded with exactly those 17 names and icons. On import they are matched by name (case-insensitive), so nothing is duplicated.
  - Each category created during import is followed by a `PUT category/v1` that sets `isActive`, `measurable`, `icon` and `color`. Otherwise it would be invisible in the online category picker (`getActiveCategories`).
  - The server's default empty "Cash"/USD account is reused for the first local account named "Cash" in USD. Otherwise it stays as an empty account online.

## R5. Currencies

- **Evidence**:
  - Currencies are global. The server seeds `USD` (value 1), `ARS` (0) and `EUR` (0) (`HomeManagement.Database/Seed/CurrencySeed.cs`).
  - `GET api/Currency` returns `[{id, name, value}]`, where `name` is the ISO code.
  - The client's `CurrencyModel(id, name, value)` displays `name`.
- **Decision**: the local hardcoded list is exactly USD, ARS and EUR, with fixed local ids 1–3. On import they map to server ids by `name`. The preflight check (FR-020) stays, in case the server list changes.
- **Alternative rejected**: a larger ISO list. Accounts in currencies the server lacks would always fail the import.

## R6. Backend: transfer mirroring vs. exact import

- **Evidence**:
  - `InternalAddTransactionAsync` (`HomeManagement.Business/Features/Transactions/TransactionService.cs:398-457`) is used by both single and bulk add.
  - It looks for the user's account whose `Name == transaction.Name` (exact). If one exists, it creates a mirror transaction there and updates that account's balance.
  - `BulkAddTransactions` (:364-395) calls it per transaction, matching against the user's accounts loaded at the start, and saves once at the end, so it is atomic per request.
- **Problem**: local mode has no mirroring (transfers are out of scope). Importing a local transaction named like another account would add an extra transaction online and break balance parity (FR-023, SC-005).
- **Decision** (2026-10-16: the user declined a backend change):
  - The import gives every server account a **temporary unique name** (`"<name> ⟨import <tag>-<localId|default>⟩"`) before sending any transaction, sends the transactions through the existing bulk endpoint, then restores the real names with `PUT account/{id}`.
  - Mirroring only happens when transactions are added, so renaming afterwards is safe.
  - The server's account name is unbounded `text`, and `PUT account/{id}` (`UpdateAccountDto(AccountId, Name, Archive, Measurable, IsHidden)`) also lets the import set `archive`, `measurable` and `isHidden`, which `POST account` can't.
- **Resumability without transaction ids**:
  - Accounts: an earlier attempt's account is found by its exact temporary name. That is more reliable than matching by name and currency.
  - Transactions: one bulk request **per account**, checkpointed by `accounts.transactions_imported`. After an ambiguous failure, the client checks whether the freshly created server account already has transactions (via the account's balance and a first page of `transactions/filter`) before resending. Each target account starts empty, so this check is reliable (SC-006).
- **Accepted side effect**: if an import fails and is never resumed, the server accounts keep their temporary names until it is resumed. The user is still in local mode during that time.
- **Alternatives considered**:
  - **A backend opt-out flag on bulk add**: declined by the user.
  - **Replicating mirroring locally and sending only originals**: breaks as soon as the user edits or deletes one side locally.
  - **A dedicated `/import` endpoint**: needs a backend change.

## R7. Delete semantics

- **Server behaviour**:
  - **Account**: delete is blocked when it has transactions (`AccountDeletionValidator`). Today this surfaces as a **500**, because `AccountHasTransactionsException` isn't mapped in `BusinessExceptionHandlerActionFilter`.
  - **Category**: delete is a hard delete with **cascade to its transactions and no balance fix**. That is a server bug.
- **Decision (local)**:
  - Account delete is blocked while it has transactions, the same as online.
  - Category delete is blocked while it is used, and the user is offered "deactivate".
  - The local schema enforces both with `ON DELETE RESTRICT`.
  - Both server bugs are reported for follow-up and not fixed in this feature.

## R8. Registration when the email is taken (FR-026)

- **Evidence**:
  - Identity is a separate service (`Altair/AltairUserManagement/Controllers/UserManagement/RegistrationController.cs`).
  - On failure it returns **400** with ASP.NET Identity `IdentityError`s; a taken email produces the `DuplicateEmail` / `DuplicateUserName` codes. The client's `IdentityService.register` returns only `statusCode == 200`.
- **Decision**: `register` returns `RegistrationResult { success, emailTaken, failed }`, which it gets by parsing the 400 body for those codes. On `emailTaken`, the registration screen asks for a different email and stays in local mode.
- **Which code (SP-04)**: Altair sets `UserName = Email`, so a taken email always yields `DuplicateUserName`; `DuplicateEmail` appears only when Identity's unique-email option is on. The client accepts either, and both are tested.
- **Verified (T063)**: `UserService.RegisterUserAsync` calls `UserManager.CreateAsync`, and `RegistrationController.Register` returns `BadRequest(result.Errors)`, a JSON array of `{code, description}`. So the standard codes are what the client sees. Other 400s (`Invalid Password.`, model state) and 5xx are plain failures.

## R9. Mode switching without rebuilding DI

- **Decision**:
  - One mode-aware delegate per data-source interface ([contracts/data-sources.md](./contracts/data-sources.md)) checks `AppModeService.isLocal` on each call.
  - Repositories keep their single instances. Entering local mode and finishing the import flip the mode and reload the repositories.
- **Rationale**:
  - Views hold repository references in fields (`GetIt.I<...>()` at construction), so `GetIt.reset()` plus re-registration would leave stale instances in live widgets.
  - Restarting the process is not a clean option on desktop.
- **Startup**: `main()` becomes `async`. It reads `appMode` from SharedPreferences and, when local, opens the database before `runApp`, so the first frame already has data.

## R10. Platform gate

- **Evidence**: `myapp.dart:23-25` treats `PlatformType.Web` as desktop for routing.
- **Decision**: local mode availability checks `getPlatformType() == PlatformType.Desktop` specifically (FR-001). The routing `isDesktop` flag stays unchanged.

## R11. Interaction with in-flight work

- **Field rename**: branch `feat/price-to-amount` (commit `fdd2e4e`, not yet on `master`) renames `TransactionModel.price` to `amount`. Local tables use `amount`, and the mapping code follows whichever name `master` has when implementation starts. Merging that branch first avoids touching both names.
- **Exposure**: the unmapped 500 on account delete and the category cascade (R7) only affect online mode.

## R12. Alternative considered: the existing `POST api/users/import`

- **What it is**: a multipart upload of the zip that `GET api/users/export` produces, handled by `UserService.ImportUserDataAsync` (`HomeManagement.Business/Features/User/UserService.cs`, ~lines 136-260).
- **Why it was not used**:
  - It **deletes the user's data first** (`DeleteUserOwnedDataAsync`), including the default categories and account, and then recreates it from the archive.
  - It is **not atomic**: there are three separate `SaveChanges` calls (after the delete, and then per stage), so a failure in the middle leaves the user with part of the data and no way to tell which part.
  - It copies `Archive` but **not `IsHidden`**, so hidden accounts would come back visible.
  - It needs the local data in the archive's own schema (zip of per-account files with a schema version), which is a second format to build and keep in step with the server's, for something that only has to run once.
- **Decision**: keep the per-account bulk import with temporary names (R6). Each request is atomic, a failed step can be retried without duplicates, and nothing is deleted online.

## R13. Smaller import decisions (SP-04)

- **A balance mismatch still completes the move (FR-023, FR-024).** It is reported to the user, and the local file is archived as the backup like any other move. Blocking the switch would not help: the steps are idempotent, so retrying cannot change a mismatch, and the user would be stuck in local mode with no way forward. The backup is what lets them compare.
- **Dates.** The server converts a date string that carries an offset into its own local time before taking the day, which can move it by one. The client sends `DateTime.toIso8601String()` of a local-midnight value, which has no offset (`2026-03-01T00:00:00.000`), so the chosen day is kept. A test checks the format.
- **Category matching.** Names are compared with the same folding the local uniqueness uses (`categoryNameKey`). If the server holds names that differ only by case or accents, the **exact name wins**, then the **lowest id**, so a retry always picks the same one.
- **Recovering a renamed account.** An account renamed to its temporary name by an earlier attempt is found by the `⟨import <tag>-…⟩` suffix, for the local id and for `default`, so a crash between the rename and storing its id leaves nothing behind. The stored `default_account_server_id` is informational: the final step restores every temporary name of this import.
- **`transactions/filter` scope.** The endpoint is not limited to the signed-in user unless given a `userId`. The import only asks about one account id at a time, taken from what the server returned when it created that account for this user, so it can only see that account's transactions.
- **"Categories untouched"** (the no-data shortcut) means equal to the seed: the same 17 names and icons, with default color and active and measurable flags.
- **Lock freshness.** The service tells the app after every status write (`onStateChanged`), so the write lock reads the new status at once instead of at the next progress report.
