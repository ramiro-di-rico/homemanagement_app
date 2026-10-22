# Contract: Data sources (client-internal seam)

Repositories currently depend on concrete HTTP services. This feature puts an interface between them so a remote (HTTP) or local (drift) implementation can be chosen. The method names below are the ones the repositories already call, so the HTTP services implement them without changing behaviour (Phase 1 of the plan is a pure refactor).

The interfaces live in `lib/data/services/sources/`. HTTP implementations are the existing services. Local implementations go in `lib/data/local/`.

```dart
abstract interface class AccountDataSource {
  Future<List<AccountModel>> fetchAccounts();          // balance included
  Future<AccountModel> add(AccountModel account);      // CHANGED: returns created (HTTP: parse 201 body)
  Future update(AccountModel account);
  Future delete(AccountModel account);                 // throws AccountHasTransactionsException
}

abstract interface class CategoryDataSource {
  Future<List<CategoryModel>> fetch();
  Future<CategoryModel> add(CategoryModel category);
  Future update(CategoryModel category);
  Future delete(CategoryModel category);               // local: throws CategoryInUseException
}

abstract interface class CurrencyDataSource {
  Future<List<CurrencyModel>> fetchCurrencies();
}

abstract interface class TransactionDataSource {
  Future<List<TransactionModel>> page(TransactionPageModel page);
  Future<List<TransactionModel>> pageNameFiltering(TransactionPageModel page, String name);
  Future<List<TransactionModel>> suggested();          // local: latest per name and type, not capped (RF-14)
  Future<TransactionWithBalanceModel> add(TransactionModel transaction);
  Future update(TransactionModel transaction);
  Future delete(int id);
}
```

## Behavioural rules both implementations must satisfy

| # | Rule | Why |
|---|------|-----|
| C1 | `TransactionDataSource.add` returns the source account with its **post-insert balance** (`targetAccount` is always null locally) | `TransactionRepository.add` applies balances from the result |
| C2 | `fetchAccounts` balance = Σ income − Σ outcome | FR-008. Server: stored balance; local: derived |
| C3 | `page` orders by date desc, then id desc, page size from the model | FR-010 |
| C4 | `CategoryDataSource.fetch` returns inactive categories too; filtering stays in `CategoryRepository.getActiveCategories` | Same as today |
| C5 | Errors surface as exceptions. Repositories keep notifying through `NotifierService` | Same as today |

## Mode switching

`main.dart` registers one **mode-aware delegate** per interface (e.g. `ModeAwareAccountDataSource(remote, local, appMode)`). On every call it forwards to the local or remote implementation according to `AppModeService.isLocal`. Repositories are constructed once with the delegate. Switching mode (entering local mode, finishing the import) flips the flag and reloads the repositories, with no GetIt re-registration and no app restart.

Out of scope for these interfaces (hidden in local mode instead): metrics, statistics, CSV import/export, bulk add from the UI, tags, voice/receipt previews, reconciliation, transaction search filters.

## `AppModeService` (`lib/data/services/app_mode.service.dart`)

```dart
class AppModeService extends ChangeNotifier {
  bool get isLocal;
  bool get isLocalAvailable;              // PlatformType.Desktop only (not Web)
  Future<void> enterLocalMode();          // opens/creates DB, persists appMode=local
  Future<void> completeImport();          // archives DB, persists appMode=online
  Future<void> leaveLocalMode();          // closes DB (file kept), persists appMode=online; FR-027
  bool get isImportPending;               // import_states.status is inProgress or failed
}
```

## Router guard (`lib/routing.dart`)

When `isLocal` is true:

- `/login_screen` redirects to `/home_screen` (skips auto-login and network), unless an import is in progress and the user isn't authenticated.
- These routes are allowed: `/home_screen`, `/home_screen/account_detail_screen`, `/home_screen/settings_screen`, `/home_screen/logging_screen`, `/registration_screen`, and the new `/local_import`.
- Any other route redirects to `/home_screen` (FR-016).

## Errors the local sources raise (RF-19)

| Exception | When | What the repositories do |
|---|---|---|
| `LocalWriteFailedException` | A write fails because the storage did | Notice "not saved"; nothing changed |
| `LocalDataLockedException` (a `LocalWriteFailedException`) | A write while an import is pending | Notice with the reason |
| `LocalReadFailedException` | A read fails because the storage did | Account, category and transaction loads keep what is shown and show "couldn't be read" |
| `LocalRecordNotFoundException` | An **update** of a row that is gone | Surfaces as a failed update. A **delete** of a missing row is a no-op |
| `AccountHasTransactionsException`, `CategoryInUseException`, `CategoryNameTakenException` | Rules of the data | Handled by the screens that offer the choice |

Anything that is not a storage failure (a bad statement, a constraint) is passed through unchanged: it is a bug, and must not be shown as "not saved" or "couldn't be read".
