# Review findings: Standalone Desktop Mode

**Reviewed**: `feat/standalone-desktop-mode` against `master`, up to `95611f0` (T001-T046, T048, T050, T051 done).
**Date**: 2026-10-19
**Scope**: committed code, spec set (`spec.md`, `plan.md`, `data-model.md`, `contracts/`, `tasks.md`), and backend assumptions checked against `homemanagement-api` (79f4f80) and Altair (7b77859).

## How to use this file

- Each finding has an ID (`RF-xx`), a severity, where it is, what goes wrong, how to fix it, and the test that proves the fix.
- **Severity**: `High` means data loss or a stranded user. `Med` means wrong behaviour the user will see. `Low` means a smaller defect or cleanup.
- **Status**: `Confirmed` was checked by reading the code. `Plausible` was reasoned from the code but not reproduced.
- Line numbers are at `95611f0` and may shift. The function names are the stable reference.
- Before implementing a finding, verify it against the current code. If the code disagrees, the code wins: note it here and skip the finding.
- When you implement one, add a task for it in `tasks.md` (suggested placement is given per finding) and tick the box here.

## Baseline at review time

| Check | Result |
| --- | --- |
| `flutter test` | 169 of 169 pass |
| `flutter analyze` | 6 new infos vs master, no new errors or warnings (4 are `use_build_context_synchronously`) |
| `flutter build web --release` | Builds |
| APK, macOS | Not verified (no Android SDK or Mac on the review machine) |
| New dependencies | All at least 7 days old when pinned in T001 |

Uncommitted at review time: `linux/flutter/generated_plugins.cmake`, `windows/flutter/generated_plugins.cmake` (`jni` added) and `macos/Flutter/GeneratedPluginRegistrant.swift` (`path_provider_foundation` removed). These come from a different Flutter SDK resolution. Do not commit them with feature work.

## Summary

| ID | Sev | Status | Title | Suggested placement |
| --- | --- | --- | --- | --- |
| RF-01 | High | Plausible | Double-click on "Use without an account" can lock the data out | Before T052 |
| RF-02 | High | Confirmed | "Local data can't be opened" screen is a dead end | Before T052 |
| RF-03 | High | Confirmed | A missing database file is silently replaced by an empty one | Before T052 |
| RF-04 | Med | Confirmed | Failed local writes are shown as success (account delete, category add) | US2 follow-up |
| RF-05 | Med | Confirmed | `guardWrite` maps every `SqliteException` to "not saved" | US2 follow-up |
| RF-06 | Med | Confirmed | Category name uniqueness is ASCII-only | US2 follow-up, before T065 |
| RF-07 | Med | Confirmed | Online data stays cached in repositories after a mode switch | Before T053 |
| RF-08 | Med | Confirmed | Startup is unguarded: any error other than `LocalDataUnavailableException` gives no window | Before T052 |
| RF-09 | Med | Confirmed | Server calls still reachable in local mode (FR-004) | With T055-T058 |
| RF-10 | Med | Plausible | Language and theme preferences are not loaded in local mode | With T058 |
| RF-11 | Low | Confirmed | `NotifierService.notify` does not clear a pending localized message | Any time |
| RF-12 | Low | Confirmed | Check-then-write sequences run outside a transaction | US2 follow-up |
| RF-13 | Low | Confirmed | Encryption self-check is weak and runs after the file is created | US2 follow-up |
| RF-14 | Low | Confirmed | `suggested()` differs from the server | US2 follow-up |
| RF-15 | Low | Confirmed | "Deactivate" category has no visible effect, and can't be undone | US2 follow-up |
| RF-16 | Low | Confirmed | Category sheets: unhandled online errors and double submit | US2 follow-up |
| RF-17 | Med | Plausible | macOS keychain entitlement with ad-hoc signing | Before release |
| RF-18 | Low | Confirmed | Test gaps and weak assertions | Alongside the fixes |
| RF-19 | Low | Confirmed | Code cleanups | Any time |
| SP-01 | High | Confirmed | Registration gap can burn the email (US4) | Spec change before T063 |
| SP-02 | High | Confirmed | Server creates the defaults asynchronously (US4) | Spec change before T065 |
| SP-03 | High | Confirmed | `PUT category/v1` never works from the client (online too) | New task before T065 |
| SP-04 | Med | Confirmed | Smaller US4 design gaps | Spec change before T065 |
| SP-05 | Med | Confirmed | `leaveLocalMode()` reload before login throws (T053) | T053 |
| DR-01 | Med | Confirmed | Tasks marked done with weaker evidence than stated | tasks.md |
| DR-02 | Low | Confirmed | Stale references in the docs | Docs |
| DR-03 | Low | Confirmed | Online behaviour changes not listed in the spec | spec.md, PR |
| UI-01..10 | Mixed | | UI and UX improvements | See section |

---

## Code findings

### RF-01: Double-click on "Use without an account" can lock the data out

- [x] Fixed in T076

- **Severity**: High. **Status**: Plausible (code path confirmed, not reproduced).
- **Where**:
  - `lib/ui/features/authentication/views/login-desktop.dart`, `_useWithoutAccount()` and the button at ~line 204
  - `lib/data/services/app_mode.service.dart`, `enterLocalMode()` (~line 83) and `_open()` (~line 112)
  - `lib/data/local/local_database_opener.dart`, `_readOrCreateKey()` (~lines 88-100)
- **Problem**: the button stays enabled while local mode opens, and `enterLocalMode()` has no guard against a second call. On first run, two calls can both read `null` from the keyring, both generate a key and both write it. The keyring keeps the last key written, while the database file may be created with the other key. Every later launch fails with `unreadable`, so the data is permanently locked out. The first Linux keyring prompt makes the gap between clicks long enough to hit. Even without the key race, the first `LocalDatabase` and its isolate are leaked.
- **Fix**:
  1. Single-flight in the service:

     ```dart
     Future<void>? _entering;

     Future<void> enterLocalMode() {
       return _entering ??= _enterLocalMode().whenComplete(() => _entering = null);
     }

     Future<void> _enterLocalMode() async {
       // current body of enterLocalMode()
     }
     ```

  2. In the view, add a `bool _enteringLocal` state flag. Disable the button and show a small `CircularProgressIndicator` while it is true, and reset it in a `finally`.
  3. In `_readOrCreateKey`, read back after writing and use the stored value:

     ```dart
     await storage.write(key: localDatabaseKeyName, value: key);
     final stored = await storage.read(key: localDatabaseKeyName);
     if (stored == null || stored.isEmpty) {
       throw LocalDataUnavailableException(LocalDataUnavailableReason.keyringUnavailable);
     }
     return stored;
     ```

- **Test**:
  - `test/data/services/mode_aware_data_sources_test.dart`: call `enterLocalMode()` twice without awaiting, and assert the opener ran once.
  - `test/views/login_desktop_local_option_test.dart`: tap twice, and assert one call and a disabled button while it is pending.

### RF-02: "Local data can't be opened" screen is a dead end

- [x] Fixed in T077

- **Severity**: High. **Status**: Confirmed.
- **Where**:
  - `lib/ui/features/local_mode/views/local_data_unavailable_screen.dart` (~lines 25-73)
  - `lib/myapp.dart` (the `startupError` branch)
  - `lib/data/services/app_mode.service.dart`, `init()` (~line 63)
- **Problem**: Retry is the only action, and this screen replaces the whole router. For `keyMissing`, `notEncrypted` and `unreadable`, Retry can never succeed, so the app is unusable, online included. The only way out is hand-editing the shared_preferences file. The text always tells the user to unlock the keyring, which is wrong for those three reasons. Clarification Q3 accepted losing the data, not losing the app.
- **Fix**:
  1. Add `Future<void> leaveLocalModeKeepingData()` to `AppModeService`. It sets `appMode=online`, sets `_isLocal = false` and clears `_startupError`. It must not touch, rename or delete the file. T053 needs the same thing, so share it with T053's `leaveLocalMode()`.
  2. Add a secondary action, "Use an online account instead", that calls it. `MyApp` then rebuilds into the router and the login screen.
  3. Show text for each `LocalDataUnavailableReason`:
     - `keyringUnavailable`: the current text (unlock the keyring and retry).
     - `keyMissing`: "The key that protects your local data is gone, for example after reinstalling the system. The data can't be recovered. The file was kept."
     - `unreadable`, `notEncrypted`: "The local data file can't be read. It was kept and nothing was deleted."
  4. Show Retry only for `keyringUnavailable` (and for `unreadable`, where a retry may help). After a Retry that fails, show a SnackBar so the user can see it ran. Set `autofocus: true` on the primary button.
  5. Add the l10n keys through the `flutter-add-locale-string` skill, in en, es and es_AR.
- **Test**: extend `test/views/local_data_unavailable_screen_test.dart`. Assert the text for each reason, and that "Use an online account instead" leaves the file untouched and reaches the login screen.

### RF-03: A missing database file is silently replaced by an empty one

- [x] Fixed (file check) in T077 (still open: choose a real Linux `APPLICATION_ID` before release)

- **Severity**: High. **Status**: Confirmed.
- **Where**: `lib/data/local/local_database_opener.dart`, `_readOrCreateKey()` and `openLocalDatabase()`, reached from `AppModeService.init()`. Also `linux/CMakeLists.txt:10` (`APPLICATION_ID "com.example.homemanagement_app"`).
- **Problem**: with `appMode=local` saved, a key in the keyring and no file, the opener reuses the key and creates a fresh seeded database without any message. This breaks the edge case "nothing is silently overwritten or wiped". It happens if the file is moved or deleted, or if the application support folder changes. On Linux that folder comes from `APPLICATION_ID`, which is still the `com.example` placeholder, and changing it would make the data "vanish". A key with no file is only legitimate after T067 archives the file, and then `appMode` is already online.
- **Fix**:
  1. Add a parameter `bool mustExist` to `openLocalDatabase`. When it is true and the file doesn't exist, throw `LocalDataUnavailableException(LocalDataUnavailableReason.fileMissing)` (a new reason) before touching the keyring or creating anything.
  2. `AppModeService.init()` opens with `mustExist: true` (the user was already in local mode). `enterLocalMode()` opens with `mustExist: false` (first entry, or re-entry after "Log in to an existing account").
  3. Note: re-entry after FR-027 must still find the old file. That works, because the file still exists.
  4. Give RF-02's screen text for `fileMissing`: "Your local data file wasn't found at <path>." Offer "Start with empty data" (explicit, never automatic) and "Use an online account instead".
  5. Separately, decide on a real `APPLICATION_ID` (Linux) before release. Changing it after users have data means migrating the folder.
- **Test**: an opener test with an injected `supportDirectory` and `FlutterSecureStorage.setMockInitialValues({localDatabaseKeyName: 'k'})`. With `mustExist: true` and no file, it throws `fileMissing` and creates no file.

### RF-04: Failed local writes are shown as success

- [x] Fixed in T079

- **Severity**: Med. **Status**: Confirmed.
- **Where**:
  - `lib/data/repositories/account.repository.dart`, `delete()` (~line 121)
  - `lib/ui/features/accounts/views/account-list-desktop.dart`, `remove()` (~lines 377-395)
  - `lib/ui/features/settings/views/settings-widgets/add_category_sheet.dart` (~lines 90-104)
- **Problem**: `AccountRepository.delete` catches `LocalWriteFailedException`, shows "Your change couldn't be saved" and returns normally. The view then runs `accounts.remove(item)` (on the repository's own list) and shows "X removed". The account disappears until the next reload. This contradicts T044 ("leave the state unchanged") and the low-disk-space edge case. The add-category sheet has the same shape: it closes after a failed save and the typed name is lost.
- **Fix**:
  1. In the repository, keep the notice but rethrow, the same way `AccountHasTransactionsException` is already rethrown:

     ```dart
     } on LocalWriteFailedException {
       notifierService.notifyChangeNotSaved();
       rethrow;
     }
     ```

  2. In `remove()`, remove the duplicate `accounts.remove(item)` (the repository already did it), and catch `LocalWriteFailedException` with nothing to do (the notice is already shown). Add `if (!mounted) return;` after the `await`.
  3. Apply the same pattern to `CategoryRepository.add` and `update`. The sheet only pops on success.
  4. Check every other repository write that catches `LocalWriteFailedException` (account add and update, transaction add, update and delete, category delete), and make sure no caller treats a return as success.
- **Test**: extend `test/data/repositories/local_write_failure_test.dart`. A failed account delete keeps the account in `accounts`, and the view shows no "removed" snackbar.

### RF-05: `guardWrite` maps every `SqliteException` to "not saved"

- [x] Fixed in T080

- **Severity**: Med. **Status**: Confirmed.
- **Where**: `lib/data/local/local_write_guard.dart:17`. Tests: `test/data/local/local_write_failures_test.dart` (~lines 15-21, 115).
- **Problem**: the doc comment says bugs pass through, but every `SqliteException` becomes `LocalWriteFailedException`. Constraint violations, foreign-key errors and SQL errors such as "no such column" all show "couldn't be saved". The T045 bug (currency id 0, a foreign-key violation) was hidden behind that message. The trigger-based tests raise `SQLITE_CONSTRAINT_TRIGGER`, which locks the wrong mapping in.
- **Fix**: only map storage failures. Use the primary result code (`extendedResultCode & 0xff`):

  ```dart
  const _storageFailureCodes = {
    5,  // SQLITE_BUSY
    6,  // SQLITE_LOCKED
    7,  // SQLITE_NOMEM
    8,  // SQLITE_READONLY
    10, // SQLITE_IOERR
    11, // SQLITE_CORRUPT
    13, // SQLITE_FULL
    14, // SQLITE_CANTOPEN
    26, // SQLITE_NOTADB
  };

  final isStorageFailure = cause is FileSystemException ||
      (cause is SqliteException &&
          _storageFailureCodes.contains(cause.extendedResultCode & 0xff));
  ```

  Rethrow everything else.
- **Test**:
  - Keep the real `max_page_count` disk-full test.
  - Replace the trigger tests with a raised I/O-style failure, and add a test that a constraint violation is not mapped.
  - Fix `local_write_failures_test.dart:115`: assert `isA<CategoryNameTakenException>()` instead of `isNot(isA<LocalWriteFailedException>())`.

### RF-06: Category name uniqueness is ASCII-only

- [x] Fixed in T081

- **Severity**: Med. **Status**: Confirmed (a probe showed `lower('Útiles')` returns `'Útiles'`).
- **Where**:
  - `lib/data/local/local_category.service.dart`, `_ensureNameFree()` (~line 67)
  - `lib/data/local/local_database.dart`, `categories_name_lower` index (~line 98)
  - Same limit: the `LIKE` in `local_transaction.service.dart` (~line 42)
- **Problem**: the check compares SQLite `lower(name)` with Dart `name.toLowerCase()`. SQLite (sqlite3mc has no ICU) only lowercases ASCII, so the two disagree for accented names:
  - Adding "Útiles" twice: the check passes, the index rejects the row, and the user sees "couldn't be saved" instead of `categoryNameTaken`.
  - "útiles" and "Útiles" can both exist. The US4 import matches names with Dart lowercasing, maps both to one server category and violates `server_id UNIQUE`, a failure that a retry can't fix (see SP-04).
  - The transaction name filter returns different results from memory (page 1) and from SQLite (later pages).
- **Fix**:
  1. Add a `nameKey` text column to `categories`, set in Dart as `name.trim().toLowerCase()`, with the unique index on `name_key` instead of `lower(name)`.
  2. Compare against `nameKey` in `_ensureNameFree`.
  3. The schema is still version 1 and unreleased. Either change version 1 in place (acceptable only if no one has real data yet, so say so in the commit) or add a version 2 migration that fills `name_key`. Regenerate with `dart run build_runner build --delete-conflicting-outputs`.
  4. Use the same Dart lowercasing in the import matcher (T065).
  5. For the transaction name filter, either store a `name_key` too or document the limit.
- **Test**: in `local_services_test.dart`, "Útiles" then "útiles" throws `CategoryNameTakenException`, and "Útiles" twice throws `CategoryNameTakenException`, not `LocalWriteFailedException`.

### RF-07: Online data stays cached in repositories after a mode switch

- [x] Fixed in T053 (the four repositories and `Caching` reset when the mode flips; the Caching clear on an online logout is not covered)

- **Severity**: Med. **Status**: Confirmed (code path). Needs overlapping ids to show.
- **Where**: `lib/data/repositories/transaction.repository.dart`, `accountsContainer`, `loadFirstPage()` and `getPage()` (~lines 150-197). `lib/main.dart` (~line 204) only registers `invalidateSuggestions`.
- **Problem**: `accountsContainer` and its cached transactions are never cleared on a mode change. A user opens online account 3, logs out, picks "Use without an account" and creates local accounts 1 to 3. Opening local account 3 shows the cached online transactions. With 20 or more cached, no local fetch happens at all. Editing or deleting one hits a different local row with the same id. T053 has the same gap in the other direction.
- **Fix**:
  1. Add `void reset()` to `TransactionRepository`, `AccountRepository`, `CategoryRepository` and `CurrencyRepository`. It clears every in-memory list, container, page and cache, then calls `notifyListeners()`.
  2. In `AppModeService`, notify only when `isLocal` actually changes, or expose a `modeChanged` listenable.
  3. In `main.dart`, replace the single `invalidateSuggestions` listener with one listener that resets all four repositories.
  4. Check `lib/data/services/caching.dart` for entries keyed by URL that could outlive a logout, and clear them on logout too.
- **Test**: a repository test that loads online fake data, switches to local, and asserts the first page comes from the local database.

### RF-08: Startup is unguarded

- [x] Fixed in T078

- **Severity**: Med. **Status**: Confirmed.
- **Where**: `lib/main.dart` (~lines 56-57), `AppModeService.init()` (only catches `LocalDataUnavailableException`).
- **Problem**:
  - `await appModeService.init()` runs before `runApp` with no try/catch. A broken `shared_preferences.json` (`FormatException`), `MissingPlatformDirectoryException`, or a `StateError` from `importStates.getSingle()` means no window at all, online users included. On master, the SharedPreferences failure was caught inside `AuthenticationService.init`.
  - Local users also wait on the keyring before any window appears, so a locked secret service shows nothing for seconds.
- **Fix**:
  1. In `_open()`, wrap any non-`LocalDataUnavailableException` error as `LocalDataUnavailableException(LocalDataUnavailableReason.unreadable, cause: e)`.
  2. In `init()`, catch errors from `SharedPreferences.getInstance()` and fall back to online.
  3. Optional: call `runApp` first with a minimal splash and finish `init()` behind it, so the keyring prompt appears with the app window.
- **Test**: an `AppModeService` test where the opener throws a `StateError`. `startupError` is set and nothing escapes.

### RF-09: Server calls still reachable in local mode (FR-004)

- [~] Account detail and the account list are done (T055, T056). Still open: the add-transaction sheet (T057), settings (T058), the kill switch in `ApiServiceFactory`, and signing out the stale user when entering local mode

- **Severity**: Med. **Status**: Confirmed for account detail. Plausible for the stale-user path.
- **Where**:
  - `lib/ui/features/accounts/views/account-detail-desktop.dart` (~line 297), `MetricService.getOverallByAccountId`
  - `lib/data/services/authentication.service.dart` (~lines 33, 141-155), `lib/data/services/api.service.factory.dart` (~lines 170-175)
- **Problem**:
  - T051 made account detail reachable before T056 hides its metrics call, so local mode makes a real request.
  - If an offline auto-login failed before entering local mode, `authenticationService.user` is still loaded. Any leftover server call then sends a stale token, or runs `autoAuthenticate()` (a login POST with the stored password).
- **Fix**:
  1. Do not release local mode until T055-T058 are done.
  2. Add a kill switch as defence in depth: in `ApiServiceFactory` and `HttpApiServiceMixin`, if `GetIt.I<AppModeService>().isLocal`, throw a `LocalModeServerCallException` before building the request. Exempt only the identity and registration calls used by "Create account" (FR-004 allows that flow).
  3. In `enterLocalMode()`, call `authenticationService.logout()` (or an equivalent that clears the in-memory user without touching the saved credentials if T053 needs them).
  4. Log blocked calls with `logger_wrapper` so T059 can see them in the Logging view.
- **Test**: with `isLocal` true, a call through `ApiServiceFactory` throws and no `http.Client` call is made (`MockClient` from `package:http/testing.dart`).

### RF-10: Language and theme preferences are not loaded in local mode

- [x] Fixed in T089. Worse than reported: the T058 language dropdown wrote to a null object, so choosing a language did nothing in local mode, and the theme was never saved.

- **Severity**: Med. **Status**: Plausible.
- **Where**: `lib/data/repositories/user.repository.dart:15`, `identity_user_repository.dart` (~lines 24, 30, 44, 60).
- **Problem**: `UserRepository.preferences` is only loaded by `AuthenticationService.init()`, which local mode skips. `getCurrentLanguage()` returns `''`, so the saved language is ignored, and theme choices are not saved. T058 keeps the language option, but `updateLanguage` calls the server.
- **Fix**: load the preferences in `main` regardless of mode, and make the language and theme setters local-only while `isLocal`. Add this to T058.
- **Test**: in local mode, change the language, restart (re-run `init`), and assert it is kept with no server call.

### RF-11: `NotifierService.notify` does not clear a pending localized message

- [x] Fixed in T082

- **Severity**: Low. **Status**: Confirmed.
- **Where**: `lib/data/services/error_notifier_service.dart`, `notify()` (~lines 17-21) vs `getMessage()` (~lines 36-41).
- **Problem**: a "not saved" notice raised while no `NotifierMixin` widget is listening stays pending. The next `notify('... added successfully')` shows "not saved" with `isError=false` (a green snackbar).
- **Fix**: add `_localizedMessage = null;` in `notify()`.
- **Test**: in `test/views/notifier_localized_message_test.dart`, call `notifyLocalized` then `notify`, and assert the plain message wins.

### RF-12: Check-then-write sequences run outside a transaction

- [x] Fixed in T080

- **Severity**: Low. **Status**: Confirmed.
- **Where**: `local_category.service.dart` `add`, `update`, `delete`. `local_account.service.dart` `delete`. `local_transaction.service.dart` `add`.
- **Problem**: a double submit of a new category name passes both checks, the second insert hits the index, and the user is told "Nothing was changed" although the category was saved. In `add()`, the insert can succeed and the following read fail, which breaks the "Nothing was changed" promise.
- **Fix**: wrap each body in `_db.transaction(() async { ... })` inside `guardWrite`. Combined with RF-05, a unique violation inside a transaction then surfaces as a bug, not as "not saved".

### RF-13: Encryption self-check is weak and runs after the file is created

- [x] Fixed in T090.

- **Severity**: Low. **Status**: Confirmed by probe.
- **Where**: `lib/data/local/local_database_opener.dart` (~lines 65, 70-75).
- **Problem**:
  - `PRAGMA cipher` returns `chacha20` even when no key was set, so it only proves sqlite3mc is the loaded library.
  - Drift runs `onCreate` on the first query, so with a non-sqlite3mc library a plaintext seeded file is written before `notEncrypted` is raised.
  - The key is interpolated into the SQL unescaped. It is safe for base64url keys, but a damaged keyring value with `'` breaks it.
- **Fix**:
  1. In `setup`, use `final result = db.select("PRAGMA key = '$escaped'")` and require the single row to be `ok` (sqlite3mc returns `ok`), otherwise throw. This runs before drift writes anything.
  2. Validate the key with `RegExp(r'^[A-Za-z0-9_\-=]+$')` before use, otherwise raise `unreadable`.
- **Test**: covered by the opener tests in RF-18.

### RF-14: `suggested()` differs from the server

- [x] Fixed in T091.

- **Severity**: Low. **Status**: Confirmed.
- **Where**: `lib/data/local/local_transaction.service.dart` (~lines 58-59).
- **Problem**: the query groups by `name` only (the server groups by name and type), takes `MAX(id)` instead of the latest by date then id, and is capped at `LIMIT 10`, while the UI filters on the client. "rent" suggests nothing if Rent is not among the last 10 names, a back-filled old "Rent" pre-fills old values, and an income and an outcome with the same name collapse into one.
- **Fix**: `ROW_NUMBER() OVER (PARTITION BY name, transaction_type ORDER BY date DESC, id DESC) = 1`, and drop the limit or raise it to match the server.
- **Test**: back-dated row, same name with both types, and more than 10 distinct names.

### RF-15: "Deactivate" category has no visible effect, and can't be undone

- [x] Fixed in T092, in local mode. Online is unchanged on purpose (see the task).

- **Severity**: Low. **Status**: Confirmed.
- **Where**: `lib/ui/features/settings/views/settings-widgets/categories_list_widget.dart` (~lines 147-153, 259-288), and the add-transaction category pickers.
- **Problem**: the pickers don't filter by `isActive` (T046 note), so a deactivated category is still offered. The Active checkbox has `onChanged: (value) {}`, and the edit sheet has no active toggle, so a category can never be reactivated. The "category in use, deactivate instead" edge case is a no-op for the user.
- **Fix**: wire the Active checkbox to `categoryRepository.update(category.copyWith(isActive: v))`, and use only active categories in the add-transaction pickers (keeping the current category when editing an existing transaction).

### RF-16: Category sheets: unhandled online errors and double submit

- [x] Fixed in T093.

- **Severity**: Low. **Status**: Confirmed (catch gap). Plausible (duplicate POST).
- **Where**: `add_category_sheet.dart` (~lines 90-104), `edit_category_sheet.dart` (~lines 100-117).
- **Problem**: online, `ApiServiceFactory` throws a plain `Exception`, which escapes `onPressed`. The sheet stays open with no message, and in the edit sheet `widget.category` stays mutated, so the list shows a name that was never saved. Since the sheet now closes after the `await`, a double click on "Add" sends two POSTs.
- **Fix**: add a `_saving` flag that disables the button, edit a copy of the category instead of `widget.category`, and add a `catch (_)` that shows a generic error. Use the State's `context` after `if (!mounted) return;` to clear the `use_build_context_synchronously` lints.

### RF-17: macOS keychain entitlement with ad-hoc signing

- [ ] Verified on a Mac. **Prepared in T094, not settled:** an opt-in `MACOS_LEGACY_KEYCHAIN` build flag exists and the checks are written down (quickstart Q18, research R2), but nothing has run on a Mac.

- **Severity**: Med if macOS ships. **Status**: Plausible (not verified, T005 only ran on Linux).
- **Where**: `macos/Runner/DebugProfile.entitlements`, `Release.entitlements` (`keychain-access-groups`), `macos/Runner.xcodeproj/project.pbxproj` (`CODE_SIGN_IDENTITY = "-"`, no `DEVELOPMENT_TEAM`).
- **Problem**: `keychain-access-groups` needs a development certificate, so macOS builds may fail to sign or launch, online mode included. flutter_secure_storage 10.3.4 defaults to `usesDataProtectionKeychain: true`, which without a team gives error -34018, surfaced as `keyringUnavailable`.
- **Fix**: build and run on a Mac. Then either set a signing team, or pass `MacOsOptions(usesDataProtectionKeychain: false)` and drop the entitlement.

### RF-18: Test gaps and weak assertions

- [x] Fixed in T095. Most of the gaps were closed earlier by other tasks; the rest are in T095.

- **Severity**: Low. **Status**: Confirmed.
- **Gaps**:
  - `openLocalDatabase` has no tests, although `secureStorage` and `supportDirectory` are injectable. Cover first-run key creation, `keyMissing` when the file exists, `PlatformException` becoming `keyringUnavailable`, a wrong key giving `unreadable`, the file never overwritten, and RF-03's `fileMissing`.
  - `local_database_test.dart` (~lines 43, 52, 55) asserts `isA<Exception>()`. Assert the specific exception.
  - T039's test runs 1,000 operations and ends with about 250 transactions, while SC-003 asks for a dataset of at least 1,000. Seed 1,000 first, and include edits that change the account and the date (US2 scenario 3).
  - No test flips the mode with already-loaded repositories (RF-07), or does a local, online, local round trip.
  - No test covers online `AccountService.add` body parsing or `AccountRepository.add`.
  - Guard test: add `/2fa_screen`, the direct `/reset_password` path, and an invite link.

### RF-19: Code cleanups

- [ ] Done

- **Severity**: Low.
- The balance SQL is written twice (`local_database.dart` ~line 111 and `local_account.service.dart` ~line 17). Keep one.
- `_validName` is duplicated in the account and category services, and `_typeToInt` repeats the encodings in `AccountModel.toJson` and `TransactionModel.toJson`. Move them to `local_mappers.dart`.
- Declare the custom indexes with `@TableIndex` or `@TableIndex.sql` so drift's schema tools and future migrations know them.
- Import `DriftRemoteException` from `package:drift/remote.dart` instead of `package:drift/isolate.dart` in `local_write_guard.dart` (web-safe).
- Replace `appMode.database!` in `_ModeSwitch.current` with an explicit `StateError('Local database is not open')`.
- In `TransactionRepository`, drop the `dataSource ?? transactionService` default, which silently bypasses the seam.
- Update and delete of a missing id succeed silently in the local services. Check the affected row count and throw when it is 0.
- Reads (`fetchAccounts`, `page`) are not guarded, so read I/O errors reach the UI as a raw `DriftRemoteException`.
- Remove the unused imports flagged by analyze in `lib/myapp.dart:2` and `account-list-desktop.dart:12`.

---

## Spec findings (fix the spec before the US4 code)

### SP-01: Registration gap can burn the email

- [x] Fixed: new `registered` status written before the sign-in, `Create account` becomes `Finish moving your local data`, the login opens with the email, `/2fa_screen` is reachable while pending (data-model, spec Assumptions and contract updated; tests in `app_mode_registered_test.dart`, `registration_desktop_local_test.dart`, `local_mode_guard_test.dart`, `post_sign_in_test.dart`, `login_desktop_local_option_test.dart`).

- **Severity**: High. **Status**: Confirmed.
- **Where**: `lib/ui/features/authentication/views/registration-desktop.dart` (~lines 30-55), `AuthenticationService.register` (does not log in). Spec Assumptions ("The existing registration flow already logs the user in on success"), T063-T065.
- **Problem**: the view calls `register`, then `authenticate` as a separate step. If login fails, 2FA is asked (`/2fa_screen` is not in the local allowlist), or the app closes in between, the email is registered and the import status is still `notStarted`. The next "Create account" gets "email taken", and FR-026 forbids moving into an existing account. The email is burned and the new online account is orphaned.
- **Fix**:
  1. Add an import status before `notStarted` begins, for example `registered`, plus `target_email` in `import_states`. Write it right after `register` returns success, before `authenticate`.
  2. While it is set, the "Create account" action opens the login screen with the email pre-filled instead of registration, and a successful login (including 2FA) continues the import.
  3. Allow `/2fa_screen` in local mode while that status is set.
  4. Update `data-model.md`, the spec Assumptions and T063-T065.

### SP-02: Server creates the defaults asynchronously

- [x] Fixed in code: step 1b polls until the seeded categories and an account exist (1 to 5 s backoff, 30 s), writes nothing meanwhile, and fails resumably (`ImportServerNotReadyException`, "isn't ready yet" + Retry). Spec, data-model, contract and quickstart updated, including the backend setup. **Not yet verified against a real backend** (quickstart Q17).

- **Severity**: High. **Status**: Confirmed (call site).
- **Where**: `homemanagement-api/HomeManagementApi/Services/Kafka/UserRegistrationMessageHandler.cs:34` calls `AddUserAsync` after Altair publishes a `user-registration` event.
- **Problem**:
  - Registration returns before the Cash/USD account and the 17 default categories exist. Until then, GET account and GET category return `[]` and any POST returns 404.
  - `AddUserAsync` saves twice (user, then defaults). A POST that lands in between succeeds, and the defaults then arrive as duplicates.
  - In the dev setup Kafka is off, and the webhook fallback (`UsersController.cs:137`) needs an AppId the client doesn't send, so against the local backend in quickstart Q9-Q15 the user may never be created.
- **Fix**:
  1. Add an import step 0b: poll `GET category` and `GET account` (with backoff, for example up to 30 s) until the 17 categories and the Cash account exist. Fail as resumable if they never appear.
  2. Document the backend setup for Q9 (Kafka on, or the webhook with an AppId).
  3. Update the spec Assumptions and `contracts/backend-import.md`.

### SP-03: `PUT category/v1` never works from the client

- [x] Fixed in T083 (code only; run it once against the local backend before T065)

- **Severity**: High (blocks import step 2, and is broken online on master today). **Status**: Confirmed.
- **Where**: `lib/domain/models/category.dart:54` (`UpdateCategoryModel.toJson` sends `categoryId`). Server: `HomeManagement.Business/Features/Categories/CategoryDto.cs` binds `Id`.
- **Problem**: the server looks up category 0 and returns 404. Editing a category online is broken, and the step-2 PUT that sets `isActive`, `icon`, `color` and `measurable` (POST only stores name and icon) would fail too.
- **Fix**: send `'id': categoryId` (keep `categoryId` too if anything else reads it). Run it against the local backend. Add it as its own task before T065, and mention it in the PR as an online fix.

### SP-04: Smaller US4 design gaps

- [x] Done (T088). Each item was checked against the code and the backend; most were already handled by T063/T065. New: exact-name-first category matching, a status refresh after every write, and the recorded decisions in research R12 and R13.

- **Severity**: Med. **Status**: Confirmed.
- **Duplicate email**: Altair returns 400 `DuplicateUserName`, never `DuplicateEmail` (username is the email). T061 and T063 must key on `DuplicateUserName`. Keeping `DuplicateEmail` is harmless.
- **Category resume**: if the POST succeeded but `server_id` wasn't saved, resume matches by name, but only created categories get the follow-up PUT, so that one stays inactive online. Matched defaults also never get the local `isActive`, icon, color and measurable. Fix: PUT every mapped category, idempotently.
- **Case folding**: local uniqueness and import matching must use the same folding (RF-06). Define a tie-break: exact match first.
- **Default account rename**: if the PUT renaming it to the temporary tag succeeds but `default_account_server_id` isn't saved, recovery only looks for local temporary names. Also recover by the `-default⟩` suffix.
- **Balance mismatch**: FR-023 says report, data-model step 7 archives and switches anyway. Decide whether a mismatch still counts as success (FR-024) before T065 and T067.
- **Dates**: the server converts strings with an offset to server-local time before taking the date. The client's offset-less `toIso8601String()` is correct. The `...Z` example in `contracts/backend-import.md` is wrong. Fix the example.
- **`transactions/filter`** is not scoped to the current user unless `userId` is passed. Prefer the balance check, or pass `userId`.
- **Do not use single `POST transactions`** for the import: it searches every user's accounts by name. The bulk endpoint is atomic and mirrors by exact, case-sensitive account name, including archived and hidden accounts, so the temporary-name approach holds.
- **T064**: "categories untouched" has nothing to compare against. Define it as "equal to the seed".
- **T066**: the write lock reads the cached `isImportPending`. T065 and T068 must call `refreshImportStatus()` after every status write.
- **Alternative**: `POST api/users/import` is an existing zip-based, replace-all import. It deletes the defaults first, isn't atomic and ignores `IsHidden`. Evaluate it briefly before writing T065 and record the decision in `research.md`.

### SP-05: `leaveLocalMode()` reload before login throws (T053)

- [x] T053 done: no reload after leaving local mode, reset instead

- **Severity**: Med. **Status**: Confirmed.
- **Where**: T053 text. `authentication.service.dart:100` (`user!.token`).
- **Problem**: T053 reloads the repositories right after leaving local mode. Online with no user, `_getAuthHeaders` calls `getUserToken()`, which throws, and `AccountRepository.load` has no catch.
- **Fix**: on leaving local mode, call `reset()` on the repositories (RF-07) and reload only after a successful login. Share the mode switch with RF-02's `leaveLocalModeKeepingData()`.

---

## Drift between tasks.md and the code

### DR-01: Tasks marked done with weaker evidence than stated

- [ ] tasks.md corrected

- **T045, T046**: the claimed checks of `AccountDetailDesktop` paging and `add_transaction_sheet_desktop` never exercised those widgets. Tests only call `TransactionRepository.loadFirstPage`, and those screens were unreachable in local mode before T051. Make T047 cover paging (`nextPage`) and the desktop add sheet. Fix the dependency note: T047 needs T051, not "Phase 2 only".
- **T015**: account add and edit online were never run against a server. Only `AccountService.add` changed behaviour (`postWithReturn` plus `fromJson`). The notes also say transactions were checked against **production**. Rerun account add and edit against the local backend, and stop testing writes against production.
- **T018**: the never-overwrite and `keyMissing` evidence was a deleted throwaway test. Add the opener tests from RF-18.
- **T039**: see RF-18 (1,000 operations is not a 1,000-transaction dataset).
- **T003**: the note says `analysis_options.yaml` was left uncommitted, but `b7452e6` committed it, along with 7 platform excludes the task didn't ask for. Correct the note.
- **T038**: the strace evidence (45 s, no `AF_INET`) is fine for startup and home. Rerun it after T055-T058 for account detail and settings.

### DR-02: Stale references in the docs

- [ ] Fixed

- `data-model.md` names the table `import_state`. The code has `import_states`.
- `contracts/data-sources.md` gives the delegate constructor as `(remote, local, appMode)`. The code has `(remote, appMode)`.
- `research.md` R2 cites T077, which doesn't exist (it should be T075).
- `checklists/requirements.md` still says "drift + SQLCipher" (it is sqlite3mc).
- R11, `contracts/backend-import.md` and the tasks Notes say the price-to-amount change isn't merged, but master has `5a58f31` and `toJson` sends `amount`.
- T052 and T053 still point at the `home-desktop.dart` AppBar (lines 63-121), and T054 mounts the banner in `HomeDesktop`. Per the T037 note, they belong in `LocalHomeDesktop`.
- T055's "main-accounts toggle" is in `home-desktop.dart` (~lines 34-53), not `account-list-desktop.dart`.
- T054 (FR-017 banner) omits the Registration and Logging screens, which are allowlisted in local mode.
- Quickstart Q6's data path is wrong on a fresh install (it depends on `APPLICATION_ID`, see RF-03).

### DR-03: Online behaviour changes not listed in the spec

- [ ] Listed in spec.md and the PR description

All of these are justified, but they change online or mobile behaviour, so add a "Side fixes" list to `spec.md` and the PR:

- `b048764`: the account sheets save the currency id instead of its list position. `account.sheet.dart` is shared with mobile, so mobile and online change too. Before, online saved USD as 0, ARS as USD's id and EUR as ARS's.
- `AccountRepository.add` now also appends to `_internalAccounts`.
- `CategoryRepository.load` fetches before clearing (this also fixes duplicates when two loads run at once).
- The add-category sheet creates categories active and measurable, and waits for the save before closing (see RF-16).
- The edit-category sheet's name controller moved to `initState`.
- `34886fd`: `NotifierMixin` passes l10n so repository notices are localized (no task ID).
- New build requirements for every desktop build, online included: Linux needs `libsecret-1-dev`, Windows needs ATL. drift, sqlite3 (with its build hook) and secure storage now also go into the APK and web builds. The web build was verified. Check the APK build and size before merge.

---

## UI and UX improvements

### Fix now

- [x] **UI-01 (T076): busy state on "Use without an account"** (`login-desktop.dart`). See RF-01. Disable the button and show a spinner while entering.
- [x] **UI-02 (T077): actionable error screen** (`local_data_unavailable_screen.dart`). See RF-02. Text for each reason, "Use an online account instead", feedback after a failed Retry, autofocus on the main action.
- [~] **UI-03 (T052: the empty state is done; the per-row "Add transaction" button is not): empty state for a first-time local user** (`local_home_desktop.dart`, `account-list-desktop.dart`). With zero accounts, show an icon, "Your data is stored encrypted on this computer only", and a "Create your first account" button that opens `AccountSheetDesktop`. Today the only entry is a small "+", and adding a transaction is hidden in each row's ⋮ menu, which works against SC-001 (first transaction in under 2 minutes). Add a visible "Add transaction" action per account row.
- [x] **UI-04 (T084; the dialog title and confirm label are done in T053): wording, "account" is ambiguous.** In this app "Account/Cuenta" already means a money account ("Add Account" is right there on the local home).
  - Rename `createAccountToSync` to `createOnlineAccount`, text "Create online account" (es: "Crear cuenta online"). The key name promises sync, which FR-025 rules out.
  - "Use without an account" in es: "Usar sin registrarme" (es_AR keeps voseo where it applies).
  - The app already says "Sign in" (`signIn`, "Sign In" on the login screen). Use "Sign in to an existing account", not "Log in".
  - `logInExistingAccountConfirm` needs a dialog title and a confirm label, and should add "Choose 'Use without an account' later to get back to it." (US3 scenario 7).
  - Since T050 is already committed, rename the keys before T052 and T053 start using them, then run `flutter gen-l10n`.
- [ ] **UI-05: "account has transactions" is easy to miss** (`account-list-desktop.dart`, `remove()`). A two-sentence message in a 4-second SnackBar, while the category case gets a dialog. Use a dialog like the category case, with an "Archive" action, or at least `SnackBar(duration: Duration(seconds: 8), action: SnackBarAction(label: l10n.archive, onPressed: ...))`.
- [~] **UI-06 (T084: wording and the Spanish comma done; the disk-space hint is not): Spanish and copy nits.**
  - es: drop the comma in "...sus transacciones, o archívala."
  - "system keyring" is Linux and macOS vocabulary. On Windows it's Credential Manager. Consider "the system's credential store" ("almacén de credenciales del sistema").
  - `changeNotSaved` could hint at the cause: "...Check that there's free disk space."

### Later

- [~] **UI-07 (T054: colours, icon and action done; the extra text and the Local chip are not): local-mode banner (T054).** Use `colorScheme.secondaryContainer` and `onSecondaryContainer`, an offline icon, "Your data is stored only on this computer", and the create-online-account action. Add a small "Local" chip in the AppBar so the status stays visible when the banner is dismissed or scrolled.
- [ ] **UI-08: local home layout.** The account list is fixed at 330 px. Let it fill the available height.
- [ ] **UI-09: desktop interactions.**
  - Add a right-click context menu on transaction rows. Swipe is the only way to duplicate or delete, and `SlidableAction` has no label or tooltip.
  - Confirm before deleting transactions and categories in local mode, since there is no server copy (`areYouSureDelete` already exists).
  - Enter submits in the category sheets (`onSubmitted`).
- [ ] **UI-10: theme and localization debt on the local first-run path.**
  - `notifier_mixin.dart` uses `Colors.redAccent` and `Colors.greenAccent` snackbar backgrounds (about 3:1 and 1.6:1 contrast in the light theme). Use `colorScheme.errorContainer` and a success color from the theme. Follow `.claude/skills/flutter-theme-and-styling/SKILL.md`.
  - Balances on the local home use `greenAccent` and `redAccent` text (`account-list-desktop.dart` ~lines 189-191), about 1.5:1 on light cards. Use theme-aware income and expense colors.
  - Hardcoded English on the first-run path: login ("Sign In", "Create one"), the account sheet ("Account Name", "Cash", "Is Measurable"), the category sheets ("Category name", "Pick a color", "Add", "Update"), and repository notices ("Account X added successfully"). Move them to l10n (`notifyLocalized` for the repository notices).

---

## Suggested order

1. RF-01, RF-02, RF-03, RF-08 (data safety and startup), before T052 builds on the login and home screens.
2. UI-04 key renames, before T052 and T053 use the T050 keys.
3. RF-07 and SP-05 together with T053.
4. RF-09 and RF-10 together with T055-T058. Do not release local mode before these.
5. RF-04, RF-05, RF-06, RF-11, RF-12 to RF-16 as a US2 follow-up batch.
6. SP-01 to SP-04 and SP-03's code fix, before T063 and T065.
7. DR-01 to DR-03 and RF-17 to RF-19 before the PR.


---

## Verification log (2026-10-20, after group A)

Every finding was checked against the code at `95611f0` before any change. Method: reading the code, short throwaway probes where a claim needed a run, and reading the backend source (`homemanagement-api`, Altair). The backend was not run.

**Where the review was only partly right**

- **RF-01**: the double open and the leaked database reproduce. In the opener, two concurrent calls both failed with "database is locked", which the user would see as an error. The permanent key lockout did not reproduce (a later open succeeded), so that part stays "plausible". The fix covers both anyway.
- **RF-13**: `PRAGMA cipher` does return `chacha20` with no key (confirmed), but the encryption itself is real, and the only way to hit the weak check is a build without sqlite3mc, which the build hook prevents. Not changed.
- **RF-09**: the account detail call is real; the stale-user path is only plausible. Handled with T055 to T058 as planned.
- **SP-04**, duplicate email: Altair registers through `UserManager.CreateAsync`, so `DuplicateUserName` is expected, but this was not run. T063 already handles both codes.
- **RF-17**: not verifiable without a Mac.

**Found while fixing**

- RF-05 and RF-12: when the disk fills inside a transaction, SQLite rolls back by itself and drift reports `CouldNotRollBackException`, which hides the real error. The guard now looks through it.
- RF-01: the login button stayed busy behind its error dialog until the dialog closed.
- RF-06: schema 1 allowed "Útiles" and "útiles" together, so the migration keeps both rows with distinct keys.

**Not done yet (group B and later)**: RF-07 with T053; RF-09 and RF-10 with T055 to T058; UI-03 with T052; SP-01, SP-02 and SP-04 as spec edits before T063; RF-14 to RF-16, RF-18 (the rest), RF-19, DR-01 to DR-03, UI-05, UI-07 to UI-10 as a follow-up batch; RF-13 deferred; RF-17 needs a Mac.
