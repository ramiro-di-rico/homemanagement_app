# Contract: Backend calls used by the import

The import is the only part of this feature that talks to a server. All endpoints are under `{BACKEND_ORIGIN}/homemanagementapi/api/`, except registration, which is on the identity service (Altair). Everything was checked against the backend source on 2026-10-15; see research R3–R8. **No backend change is required.**

| Step | Call | Notes |
|---|---|---|
| Register | `POST identity/api/registration` `{email, password(AES), language}` | 200 = ok. **400** with ASP.NET Identity errors; a body containing `DuplicateUserName` (always, since the username is the email) or `DuplicateEmail` means the email is taken (spec US4-7, FR-026). Client change: `IdentityService.register` returns a result enum instead of `bool` |
| Login | existing `authenticate` flow | Registration does **not** log in: `registration-desktop.dart` calls `register` and then `authenticate` as two steps, and the app records `registered` in between (SP-01). The sign-in may ask for a two-factor code |
| Wait | poll `GET category/v1` and `GET account` | The server creates the Cash account and the 17 default categories **after** registration returns (SP-02). Poll with backoff (up to 30 s) until the seeded categories and an account exist. Until then `GET` returns `[]` and any `POST` answers 404 |
| Currencies | `GET currency` → `[{id, name, value}]` | `name` is the ISO code |
| Categories | `GET category/v1`, `POST category/v1` (200 + created), `PUT category/v1` | `POST` **ignores** isActive/measurable/color and creates the category **inactive**, so every created category is followed by a `PUT` |
| Accounts | `GET account`; `POST account` `{name, accountType, currencyId}` → **201 + `AccountResultDto`**; `PUT account/{id}` `{accountId, name, archive, measurable, isHidden}` → 200 | Client change only: `AccountService.add` must parse and return the body (today it discards it). The account name column is unbounded `text`, so temporary names fit |
| Transactions | `POST transactions/bulk` `{transactions:[…]}` → 200 `[updated accounts]` | Existing endpoint, unchanged |
| Verify | `GET account` | Compare `balance` per mapped account |

## Server behaviour the import must work around: asynchronous provisioning

`UserRegistrationMessageHandler` (`HomeManagementApi/Services/Kafka/`) calls `AddUserAsync` when Altair publishes a `user-registration` event, and only if the API's `UserRegistrationKafka` feature is enabled. `AddUserAsync` saves the user first and the defaults second. So after `POST identity/api/registration` returns:

- the user may not exist on the home-management side for a moment, and its defaults for a little longer;
- a `POST` that lands between the two saves succeeds, and the defaults then arrive as duplicates.

The import therefore writes nothing until the defaults are visible, and fails resumably if they never are.

**Backend setup for a local run.** The event must be processed. In Altair, `UseKafka` is `true` in `appsettings.json` and `false` in the Development files; with it off, the fallback is a webhook that needs an `AppId` the client doesn't send, so against such a backend the user may never be created and the import will stop with "your online account isn't ready yet". Run the stack with Kafka on (the `kafka` service in `../home-management-all/docker-compose.yml`) and the `UserRegistrationKafka` feature enabled before quickstart Q9 to Q15.

## Server behaviour the import must work around: transfer mirroring

`TransactionService.InternalAddTransactionAsync` (`HomeManagement.Business/Features/Transactions/TransactionService.cs:398-457`) is used by both single and bulk add. For each transaction, it looks for one of the user's accounts whose **name equals the transaction's name** (exact match). If it finds one, it creates a mirror transaction there and changes that account's balance. Local mode has no such rule, so importing as-is could add extra transactions and break balance parity (FR-023, SC-005).

**Approach (no backend change)**:

- **Temporary names**: during the import, every server account of the new user carries a temporary, unique name: `"<name> ⟨import <tag>-<localId|default>⟩"`.
- **Transactions**: they are sent while those names are in place, so no transaction name can match an account and nothing is mirrored.
- **Restore**: afterwards each account is renamed to its real name with `PUT account/{id}`. Mirroring only happens when transactions are added, so the real names are safe from then on.
- **Recovery**: the temporary names also make resume exact. An account created by an earlier attempt is found by its temporary name.

```jsonc
// POST transactions/bulk   (accounts currently named e.g. "Savings ⟨import 3fa9c2d1-7⟩")
{ "transactions": [
    { "accountId": 101, "categoryId": 55, "name": "Savings",
      "amount": 1234.5, "date": "2026-09-30T00:00:00.000", "transactionType": 1 } ] }
// 200 → [{ "id": 101, "name": "Wallet ⟨import 3fa9c2d1-4⟩", "balance": -1234.5, ... }]
// then: PUT account/101 { "accountId": 101, "name": "Wallet", "archive": false, "measurable": true, "isHidden": false }
```

Properties of the existing bulk endpoint that the import depends on:

- **Atomic per request.** One `SaveChangesAsync` at the end of `BulkAddTransactions`, so a failed request writes nothing.
- **Restricted to the current user's accounts.** It does not use the unscoped `FindAsync` path of the single-add endpoint.
- **An empty list returns 404.** The client never sends one; accounts without transactions are skipped.

If the import fails and is never resumed, the server accounts keep their temporary names. The user is still in local mode, and resuming fixes them.

The amount field is `amount` from branch `feat/price-to-amount` onward. Before that merges, the client serializes `price`. The import uses whatever `TransactionModel.toJson()` emits.

## Dates

Send the day as an ISO string **without** an offset, which is what `DateTime.toIso8601String()` gives for a local-midnight value (`2026-09-30T00:00:00.000`). The server converts a string with an offset (`...Z` or `+02:00`) to its own local time before taking the date, so it can move the transaction by a day. Details in research R13.
