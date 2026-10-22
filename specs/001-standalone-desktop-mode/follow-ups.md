# Follow-ups found during standalone desktop mode

**Feature**: [spec.md](./spec.md) | **Task**: T074

Problems seen while building this feature that are **not fixed here**. Each one is
written so it can be filed as an issue as it is. None blocks the feature: local mode
doesn't call the server, and the import avoids the affected endpoints.

Status: drafts, not yet filed.

## Backend (`homemanagement-api`)

### 1. Deleting a category cascades to its transactions without fixing balances

- **Where**: `HomeManagement.Business/Features/Categories/CategoryService.cs`, `DeleteCategoryAsync` (~line 62).
- **Problem**: the category is hard-deleted and its transactions go with it, but the balances of the affected accounts are not corrected.
- **Effect**: after deleting a category that was in use, an account's balance no longer equals the sum of its transactions.
- **Suggested fix**: refuse the delete while the category is used (like accounts with transactions), or recompute the affected balances in the same save. The local mode of the app chose the first: it blocks the delete and offers "deactivate" (research R7).
- **Source**: `research.md` R7.

### 2. `AccountHasTransactionsException` returns 500 instead of 409

- **Where**: `HomeManagementApi/Filters/BusinessExceptionHandlerActionFilter.cs`. The exception is thrown by `AccountDeletionValidator` (`HomeManagement.Business/Features/Accounts/`).
- **Problem**: the filter doesn't map this exception, so deleting an account that has transactions answers 500.
- **Effect**: clients can't tell "not allowed because it has transactions" from a server fault.
- **Suggested fix**: map it to 409 Conflict, like the other business exceptions.
- **Source**: `research.md` R7.

### 3. Single `POST transactions` looks up the transfer target before checking who owns it

- **Where**: `HomeManagement.Business/Features/Transactions/TransactionService.cs`, ~lines 424-442.
- **Problem**: when a transaction's name matches an account name, the target account is found with `webAppDbContext.Accounts.FirstOrDefaultAsync(x => x.Name == transaction.Name)`, across **all users**. The ownership check (`targetAccount.UserId != user.Id`) comes after.
- **Effect**: the first account with that name in the whole database is taken, whoever owns it. If it belongs to someone else, the add fails with `EntityNotFoundException` ("Account N does not belong to user M"), and that message confirms another user's account id. Every user has a default account called "Cash", so a user who types a transaction named "Cash" can have it rejected because another user's "Cash" was found first, even though their own "Cash" exists.
- **Suggested fix**: scope the lookup to the current user's accounts before comparing names.
- **Source**: `review-findings.md` SP-04. The import avoids this endpoint and uses the bulk one.

## Client (`homemanagement_app`)

### 4. `CryptographyService` uses a hardcoded AES key and IV

- **Where**: `lib/data/services/cryptography.service.dart`.
- **Problem**: the key and the IV are the same string literal in the source, and the IV never changes between calls, so the same password always gives the same ciphertext.
- **Effect**: anyone with the app binary has the key. The encryption only hides the password from casual inspection; it is not a security boundary, and the transport relies on HTTPS.
- **Suggested fix**: decide what this is for. If the goal is confidentiality, stop sending the password through it and rely on TLS, or agree a scheme with Altair (the server decrypts it). Changing it needs the same change on the server's decrypter, so it is not a client-only fix.

### 5. `TransactionService.filter` overwrites its paging parameters; `internalAuthenticateV2` uses the wrong URL

- **Where (filter)**: `lib/data/services/transaction.service.dart`, `filter`. When `accountIds` is given, `queryFilter = 'accountIds=...'` **replaces** the `currentPage=...&pageSize=...` that was set on the line before, because it uses `=` instead of `+=`.
- **Effect (filter)**: a search with account filters sends no page or size, so the server's defaults apply and paging doesn't work as the screen expects.
- **Where (sign-in)**: `lib/data/services/identity.service.dart`, `internalAuthenticateV2`. It builds its URL from `authenticateApi` (the v1 path) plus `?api-version=2`, and `authenticateApiV2` is defined but never used.
- **Effect (sign-in)**: depending on how the server routes versions, v2 sign-in may reach the v1 endpoint. Check what the server expects, then use one or the other consistently.
- **Suggested fix**: change `=` to `+=`. For the sign-in, use `authenticateApiV2` if that is the real route, or delete the unused constant.
