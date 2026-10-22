# Data Model: Standalone Desktop Mode

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Research**: [research.md](./research.md)

Local data lives in one encrypted SQLite file (`homemanagement_local.sqlite`) managed by drift. The rows map 1:1 onto the existing domain models (`AccountModel`, `CategoryModel`, `TransactionModel`, `CurrencyModel` in `lib/domain/models/`), so views and repositories keep working with the same types. Tags are not stored (spec: hidden in local mode).

Schema version starts at **1**. Every later change goes through drift's `MigrationStrategy`. The schema is never recreated destructively.

## Tables

### `currencies` (seeded, read-only)

| Column | Type | Rules |
|--------|------|-------|
| `id` | int, PK | Fixed seed ids: 1 = USD, 2 = ARS, 3 = EUR |
| `name` | text, unique, not null | ISO code. Same value as the server's `Currency.Name` |
| `value` | real, not null | Seed: USD 1, ARS 0, EUR 0, mirroring the server seed. Unused in local mode |

- Seeded in `onCreate` and never edited from the UI.
- The list is exactly the server's seed (`HomeManagement.Database/Seed/CurrencySeed.cs`), so FR-020's currency check always passes for data created locally (see research R5).
- Maps to `CurrencyModel(id, name, value)`.

### `accounts`

| Column | Type | Rules |
|--------|------|-------|
| `id` | int, PK autoincrement | Local id, never sent to the server |
| `name` | text, not null | Trimmed, 1–100 chars. Not unique (server doesn't enforce it either) |
| `account_type` | int, not null | 0 = Cash, 1 = BankAccount (same encoding as `AccountModel.toJson`) |
| `currency_id` | int, FK → `currencies.id`, not null | |
| `measurable` | bool, not null, default true | |
| `archive` | bool, not null, default false | |
| `is_hidden` | bool, not null, default false | |
| `server_id` | int, nullable, unique | Set once the account exists online (import) |
| `transactions_imported` | bool, not null, default false | Import checkpoint (see state machine below) |

- **Balance** is not stored. It is derived on read: `COALESCE(SUM(CASE t.transaction_type WHEN 0 THEN t.amount ELSE -t.amount END), 0)` over the account's transactions (FR-008).
- Maps to `AccountModel`, with `userId = 0` and the derived `balance`.
- **Delete** is blocked while the account has transactions, the same as the server (`AccountDeletionValidator`). The user gets a localized message.

### `categories`

| Column | Type | Rules |
|--------|------|-------|
| `id` | int, PK autoincrement | |
| `name` | text, not null | Trimmed, 1–100 chars. Unique, case-insensitive, among local categories |
| `icon` | text, not null | Material icon name, same set the server uses |
| `color` | text, not null, default `#ffffff` | |
| `measurable` | bool, not null, default true | |
| `is_active` | bool, not null, default true | |
| `server_id` | int, nullable, unique | Set once matched to or created online |

- Seeded on first creation with the server's 17 default categories: same names and icons as `HomeManagement.Database/Seed/CategoryInitializer.cs`, all active and measurable (FR-006). On import they match the server's defaults by name, so nothing is duplicated (research R4).
- Maps to `CategoryModel`, with `userId = 0`.
- **Delete** is blocked while any transaction references the category, and the user is offered "deactivate" instead. This deliberately differs from the server, which cascade-deletes the transactions without fixing balances; see research R7.

### `transactions`

| Column | Type | Rules |
|--------|------|-------|
| `id` | int, PK autoincrement | |
| `account_id` | int, FK → `accounts.id` ON DELETE RESTRICT, not null | |
| `category_id` | int, FK → `categories.id` ON DELETE RESTRICT, not null | |
| `name` | text, not null | 1–200 chars |
| `amount` | real, not null | > 0. The sign comes from `transaction_type` |
| `transaction_type` | int, not null | 0 = Income, 1 = Outcome (same as `TransactionModel.toJson`) |
| `date` | datetime, not null | Stored as UTC midnight of the chosen day, matching the server's normalization |
| `created_at` | datetime, not null | Tie-breaker for ordering |

- **Index** `(account_id, date DESC, id DESC)` for paging (FR-010).
- **No `server_id`.** The bulk endpoint doesn't return created ids, and none are needed: no sync follows the import (FR-025). Import progress is tracked per account (`accounts.transactions_imported`).
- Maps to `TransactionModel`. `categoryName` is filled by a join, and `tags` is always empty.
- **No transfer mirroring locally.** A transaction whose name equals another account's name is just a normal transaction (spec assumption: transfers are out of scope). See research R6 for how the import keeps the server from mirroring it.

### `import_state` (single row)

| Column | Type | Rules |
|--------|------|-------|
| `id` | int, PK, always 1 | |
| `status` | int, not null | See state machine |
| `target_email` | text, nullable | The email registered for the move, written as soon as the registration succeeds. Resuming requires the same logged-in user |
| `started_at` | datetime, nullable | |
| `last_error` | text, nullable | Last failure message shown on resume |
| `import_tag` | text, nullable | 8 random hex chars, generated at step 0. Makes temporary account names unique to this import |
| `default_account_server_id` | int, nullable | The server's default "Cash" account when no local account was mapped to it. It is renamed temporarily and restored in step 5 |

## Outside the database

| Key (SharedPreferences) | Values | Purpose |
|---|---|---|
| `appMode` | `online` (default) / `local` | Read at startup and by the router guard (FR-003) |

| Secure storage key | Value | Purpose |
|---|---|---|
| `local_db_key_v1` | 32 random bytes, base64 | SQLCipher key, generated on first local start (FR-014, research R2). Never leaves the OS keyring |

## State transitions

### App mode

```text
             "Use without an account"              import completed (file archived)
 online ───────────────────────────────▶ local ─────────────────────────────────▶ online
   ▲                                       │
   └──── "Log in to an existing account" ──┘  (file kept as is; reopened on the next
         (not offered while import pending)     "Use without an account")
```

### Import (`import_state.status`)

```text
notStarted ──register ok──▶ registered ──login──▶ inProgress ──all steps ok──▶ completed ──▶ file archived, appMode=online
   │                                                   │   ▲
   └── register ok, nothing to move ──▶ switch at once │   │ retry (same email, logged in)
                                                       ▼   │
                                                     failed
```

`registered` is written right after the registration succeeds and **before** the sign-in that follows (SP-01). The sign-in can fail, ask for a two-factor code, or the app can close, and the account already exists: without this status the next "Create account" would say the email is taken, and the move into it would be forbidden (FR-026). While it is set, "Create account" is replaced by "Finish moving your local data", which opens the login with that email typed in, and the two-factor screen is reachable. The enum is stored by index, so `registered` is appended last although it comes first in time.

**Local writes are locked** while the status is `registered`, `inProgress` or `failed`, and also `completed` while the file is still the active one (archiving failed: the data was already sent, so new writes would never reach the account). The `ModeAware*` delegates reject add, update and delete with `LocalDataLockedException` (spec FR-022), so the local data can't drift from what was already sent. Reads still work.

Steps run in order inside `inProgress`. Each one is idempotent, so a retry repeats safely (FR-021):

1. **Preflight**: every local `currencies.name` used by an account exists in `GET currency`. Otherwise abort before any write (FR-020).
1b. **Wait for the server** (SP-02): the server creates a new user's Cash account and default categories **after** registration returns, from a background event, in two saves. Poll `GET category/v1` and `GET account` (1 s, 2 s, 4 s, then every 5 s, for up to 30 s) until every seeded category name is there and the user has an account. Nothing is written meanwhile, because a `POST` that lands between the two saves would show up again as a duplicate when the defaults arrive. If it never gets ready the move fails as `failed`, with nothing changed, and Retry tries again.
2. **Categories**: `GET category/v1` → match by name (case-insensitive) → `POST` the missing ones → `PUT` to set icon, color, measurable and `isActive` (the server ignores those on create, see research R4) → store `server_id`.
3. **Accounts, all under temporary names**. The temporary name is `"<name> ⟨import <import_tag>-<local id>⟩"`, or `"<name> ⟨import <import_tag>-default⟩"` for the server's unmapped default account. See research R6 for why.
   - `GET account`.
   - **Recovery**: map any local account without `server_id` whose temporary name exists on the server (an earlier attempt created it).
   - Map an unmapped local "Cash"/USD account to the server's default "Cash"/USD account if its balance is 0, and `PUT` it to the temporary name.
   - `POST account` with the temporary name for the rest (it returns the created account, 201), storing `server_id` right after each call.
   - If the server's default account is still unmapped, `PUT` it to its temporary name and store `default_account_server_id`.
   - Before step 4, **every** server account of this user has a temporary name.
4. **Transactions, one bulk request per account**: skip accounts with `transactions_imported = true` → send all of that account's transactions (with server ids) in one existing `POST transactions/bulk` → set `transactions_imported = true`. The request is atomic on the server (one `SaveChanges`). No transaction name can equal a temporary account name, so the server creates no mirror transactions. After an ambiguous failure, the client checks whether the server account already has transactions before resending (research R6).
5. **Restore names**: `PUT account/{server_id}` for each mapped account with its real name and local `archive`, `measurable` and `is_hidden` (the create call can't set those), and restore the default account's original name. This is idempotent. Mirroring only happens when transactions are added, so the real names are safe now.
6. **Verify**: compare each server balance with the local derived balance (FR-023), and record any mismatches for the summary screen.
7. **Archive**: close the DB, rename the file to `homemanagement_local.backup-YYYY-MM-DD.sqlite` (with a `-N` suffix if it exists), set `appMode = online`, and clear `Caching` and the repositories' suggestion cache (FR-024). Because the active file is always `homemanagement_local.sqlite`, the rename alone makes the next local session start fresh.
