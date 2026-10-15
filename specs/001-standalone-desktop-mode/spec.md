# Feature Specification: Standalone Desktop Mode

**Feature Branch**: `feat/standalone-desktop-mode`

**Created**: 2026-10-15

**Status**: Draft

**Input**: User description: "Standalone desktop mode: allow using the app on desktop (Linux/Windows/macOS, not web) without registering or a backend. Data is stored locally in an encrypted SQLite database (drift). In local mode the user can create, edit and delete accounts, categories and transactions; balances are the sum of transactions (accounts start at 0); currencies come from a hardcoded list. Backend-dependent features (metrics dashboard widgets, statistics, budget, reminders, recurring, invitations, bulk transactions, search, CSV import/export, voice/receipt capture, main accounts) are hidden. Entry point is a "Use without an account" option on the desktop login screen. Later, the user can create an account by providing an email (existing registration flow); after registration the app imports all local accounts, categories and transactions to the new server user (currencies mapped by code, local ids remapped to server ids — backend POST account will return the created account), verifies balances, keeps the local DB as a timestamped backup, and switches to normal online mode. No two-way sync."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start using the app without an account (Priority: P1)

A person installs the desktop app and wants to track their money right away, without registering, without an internet connection, and without their data leaving their computer. From the login screen they choose "Use without an account" and land on a simplified home screen where they can start working immediately. The next time they open the app, it goes straight back to their local data.

**Why this priority**: This is the entry point to the whole feature. Without it, nothing else in local mode is reachable.

**Independent Test**: On a desktop computer with no network connection, open the app, choose "Use without an account", close the app, reopen it, and confirm it returns to the local home screen without asking for credentials.

**Acceptance Scenarios**:

1. **Given** the app is opened on a desktop computer and the user is not logged in, **When** the login screen appears, **Then** a "Use without an account" option is visible alongside the existing log-in and create-account options.
2. **Given** the login screen on the web version or on a phone, **When** it appears, **Then** the "Use without an account" option is not shown.
3. **Given** the user chooses "Use without an account", **When** the home screen opens, **Then** no network request is required and no login error, expired-session message or server error is shown.
4. **Given** the user has been using local mode and closes the app, **When** they open it again, **Then** they land directly on the local home screen with all their data intact.

---

### User Story 2 - Manage accounts, categories and transactions locally (Priority: P1)

In local mode the user creates accounts (for example "Wallet" in ARS, "Savings" in USD), manages their categories, and records income and expense transactions. Each account's balance always equals the sum of its transactions, and everything persists between sessions.

**Why this priority**: This is the value of local mode. Being able to start without managing anything would be pointless.

**Independent Test**: In local mode, create two accounts with different currencies, add, rename and remove categories, record several income and expense transactions, edit one and delete one, restart the app, and confirm everything, including balances, is as left.

**Acceptance Scenarios**:

1. **Given** local mode, **When** the user creates an account by choosing a name, a currency from the built-in list and an account type, **Then** it appears in the account list with a balance of 0.
2. **Given** an account, **When** the user records an income of 100 and an expense of 30, **Then** the account balance shows 70.
3. **Given** an existing transaction, **When** the user changes its amount, type, account or date, or deletes it, **Then** every affected account balance updates immediately to the new sum of its transactions.
4. **Given** local mode, **When** the user adds, renames or deletes a category, **Then** the change is reflected wherever categories are chosen, for example when adding a transaction.
5. **Given** an account, **When** the user renames, hides, archives or deletes it, **Then** it behaves the same as in online mode.
6. **Given** an account with many transactions, **When** the user opens its detail screen, **Then** transactions are listed most recent first and further pages load as the user scrolls.
7. **Given** local data, **When** the app is closed and reopened, **Then** all accounts, categories, transactions and balances are unchanged.

---

### User Story 3 - A home screen showing only what works offline (Priority: P2)

In local mode the user only sees features that work without a server. Menu entries and dashboard panels that depend on the server are not shown at all, rather than shown and broken. These include metrics and charts, statistics, budget, reminders, recurring transactions, invitations, bulk entry, transaction search, CSV import and export, voice and receipt capture, and main accounts.

**Why this priority**: Without this, local mode is usable but full of error messages and dead buttons. It is important for quality but not needed to prove the core flow.

**Independent Test**: In local mode, go through every menu entry, the home screen, the account detail screen, the add-transaction form and the settings screen, and confirm that none of them triggers a server request or shows a server error.

**Acceptance Scenarios**:

1. **Given** local mode, **When** the home screen is shown, **Then** the user sees their accounts and balances, and none of the server-computed panels (balance breakdown, overview, balance history chart, upcoming recurring transactions).
2. **Given** local mode, **When** the user looks at the top menu, **Then** only Settings and a "Create account" action are available. Search, bulk transactions, invitations, statistics, budget, reminders and logout are not shown.
3. **Given** local mode, **When** the user opens the add-transaction form, **Then** voice dictation and receipt scanning are not offered.
4. **Given** local mode, **When** the user tries to open a server-only screen by any other path, for example a stale link, **Then** they are returned to the local home screen.
5. **Given** local mode, **When** the user opens Settings, **Then** category management and appearance and language options are available, and server-only sections such as profile, security and invitations are hidden.
6. **Given** local mode, **When** any screen is shown, **Then** a clear indication says the user is working locally, with a way to create an account.

---

### User Story 4 - Create an account and bring local data along (Priority: P2)

After using the app locally for a while, the user decides to create an online account, for example to use the app on another device. They choose "Create account", register with their email through the normal registration flow, and the app moves all their local accounts, categories and transactions into the new online account. When it finishes, the app is in normal online mode, every balance matches what they had locally, and their local data is kept as a backup file.

**Why this priority**: This is the bridge to online mode and the reason local mode doesn't strand users. It depends on Stories 1 and 2 existing first.

**Independent Test**: With local data that includes several accounts in different currencies, categories and transactions, choose "Create account", register a new email, and confirm the app ends up online with the same accounts, categories, transactions and balances, and that a backup file of the local data exists.

**Acceptance Scenarios**:

1. **Given** local mode with data, **When** the user chooses "Create account" and completes registration, **Then** the app automatically starts moving the local data to the new online account and shows progress.
2. **Given** the move has finished, **When** the app switches to online mode, **Then** every account, category and transaction exists online, linked to the same account and category as before, with the same amounts, dates, names and types.
3. **Given** the move has finished, **When** the app compares balances, **Then** every online account balance equals the local balance. If any differ, the user is told which accounts differ.
4. **Given** the move has finished successfully, **When** the user looks at their computer, **Then** the local data is preserved as a backup file whose name includes the date, and the app no longer reads or writes it.
5. **Given** the move fails partway, for example because the connection drops, **When** the user retries, **Then** it continues from where it stopped without creating duplicates, and the app stays in local mode with all local data intact until the move fully succeeds.
6. **Given** local mode with no data at all, **When** the user creates an account, **Then** registration completes and the app switches to online mode without a move step.
7. **Given** the user wants to create an account with an email that is already registered, **When** registration reports the email is taken, **Then** [NEEDS CLARIFICATION: Should the user be able to log in to that existing account and move their local data into it, merging with what is already there, or must they register a new email?]

---

### Edge Cases

- **Category already exists online.** A local category name may match a category the new online account already has, for example a default category created at registration. The local category is matched to the existing online one by name, ignoring case, rather than duplicated.
- **Currency missing online.** A currency a local account uses may not exist on the server. The move checks all currencies before it starts, and if any can't be matched it stops before changing anything and tells the user which ones.
- **App closed during the move.** On the next launch the app is still in local mode, and the user can resume the move.
- **Same account name twice.** Two local accounts may share a name. Each is moved as a separate account, and transactions stay with the correct one.
- **Returning to local mode later.** If a user who has moved to online mode later logs out and chooses "Use without an account" again, they start with a new, empty local dataset. The earlier backup is not touched or loaded.
- **Category in use.** A user may try to delete a category that is used by transactions. The behaviour matches online mode: either blocked with a message, or the transactions keep a reference to it.
- **Account with transactions.** Deleting an account that has transactions behaves the same as online mode.
- **Local data cannot be opened.** If the local data can't be opened, for example because the protection key is unavailable, the user sees a clear message explaining the situation. Nothing is silently overwritten or wiped.
- **Low disk space.** If disk space runs out, or the data can't be saved, the user is told that the change was not saved.

## Requirements *(mandatory)*

### Functional Requirements

**Entering and staying in local mode**

- **FR-001**: The desktop app MUST offer a "Use without an account" option on the login screen, on desktop operating systems only (Linux, Windows, macOS). It MUST NOT appear on web or mobile.
- **FR-002**: Choosing "Use without an account" MUST open the app without registration, login or network access.
- **FR-003**: The app MUST remember that local mode is active and reopen into local mode on later launches until the user moves to an online account.
- **FR-004**: In local mode the app MUST NOT make any request to the server, including background or startup requests. The only exception is the explicit "Create account" flow.

**Local data management**

- **FR-005**: Users MUST be able to create, rename, hide, archive and delete accounts in local mode. Each account has a name, a currency from a built-in list, and an account type (cash or bank account).
- **FR-006**: Users MUST be able to create, edit and delete categories in local mode. A first-time local user MUST start with a small default set of categories.
- **FR-007**: Users MUST be able to create, edit, duplicate and delete income and expense transactions in local mode. Each transaction has a name, an amount, a date, a type (income or expense), an account and a category.
- **FR-008**: An account's balance MUST always equal the sum of its income transactions minus the sum of its expense transactions. A new account's balance is 0.
- **FR-009**: Balances shown MUST update immediately after any transaction is created, edited or deleted.
- **FR-010**: An account's transactions MUST be viewable most recent first, loading in pages.
- **FR-011**: The add-transaction form MUST continue to suggest previously used transaction names, based on local history.
- **FR-012**: The built-in currency list MUST identify currencies by their standard three-letter code, so they can be matched to the server's currencies.
- **FR-013**: All local data MUST persist across app restarts and computer restarts.
- **FR-014**: Local data MUST be stored encrypted, so that copying the data file to another computer does not expose its contents. Opening the app on the same computer and user account MUST NOT require the user to enter a password.

**What is shown in local mode**

- **FR-015**: In local mode the app MUST hide every feature that depends on the server. That includes:
  - the dashboard metrics panels, meaning the balance breakdown, the overview and the balance history chart
  - recurring transactions
  - statistics, budget and reminders
  - invitations
  - bulk transactions
  - transaction search
  - CSV import and export
  - voice dictation and receipt scanning
  - main accounts
  - the profile and security sections of settings
  - per-account metrics on the account detail screen
- **FR-016**: Trying to reach a hidden screen in local mode MUST redirect the user to the local home screen.
- **FR-017**: The app MUST show a persistent indication that the user is working locally, with an action to create an online account.

**Moving to an online account**

- **FR-018**: Users MUST be able to start online account creation from local mode, using the existing registration flow (email and password).
- **FR-019**: After registration and login succeed, the app MUST move all local accounts, categories and transactions to the new online account. Every transaction MUST stay linked to the same account and category it had locally.
- **FR-020**: Before changing anything online, the move MUST check that every local currency can be matched to a server currency by code. If any cannot, it MUST stop and tell the user which ones.
- **FR-021**: The move MUST show progress, and MUST be resumable after a failure or app closure without creating duplicate accounts, categories or transactions.
- **FR-022**: Until the move has fully succeeded, the app MUST stay in local mode, and the local data MUST stay intact and editable.
- **FR-023**: After the move, the app MUST compare each online account balance with its local balance. If any differ, it MUST report the affected accounts to the user.
- **FR-024**: After a successful move, the app MUST keep the local data as a backup file whose name includes the date of the move. It MUST stop reading from or writing to that file, and MUST switch to normal online mode.
- **FR-025**: There MUST be no ongoing synchronization between local data and the online account. The move happens once.
- **FR-026**: The behaviour when the chosen email is already registered MUST follow the clarification in User Story 4, scenario 7.

### Key Entities

- **Local Account**: a place where money is held, such as a wallet or a bank account.
  - Name, currency, type (cash or bank), and whether it is hidden or archived.
  - Its balance is derived from its transactions and is not entered by the user.
  - Once moved, it carries a link to its online counterpart.
- **Local Category**: a label used to classify transactions.
  - Name, icon, color, and whether it is active.
  - Once moved, it carries a link to its online counterpart.
- **Local Transaction**: a single income or expense.
  - Name, amount, date, type, owning account and category.
  - Once moved, it carries a link to its online counterpart.
- **Currency**: an entry in the fixed built-in list, identified by its three-letter code, with a symbol and a display name.
- **App Mode**: whether the app is currently local or online, plus the progress of an in-flight move.
- **Local Data Backup**: the preserved, no longer used copy of the local data after a successful move. Its name includes the date.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can go from opening the app for the first time to recording their first transaction in local mode in under 2 minutes, without registering and without a network connection.
- **SC-002**: With the network disconnected, a user can go through every screen reachable in local mode without seeing a single server or connection error.
- **SC-003**: After any create, edit or delete, 100% of account balances equal the sum of their transactions. This is checked across a test dataset of at least 1,000 transactions in at least 5 accounts.
- **SC-004**: Moving a dataset of 5 accounts, 20 categories and 1,000 transactions to a new online account completes in under 2 minutes on a normal home connection.
- **SC-005**: After a move, 100% of accounts, categories and transactions exist online exactly once, and 100% of online balances match the local balances.
- **SC-006**: A move interrupted at any point, then resumed, ends with zero duplicate records online.
- **SC-007**: Someone without access to the original computer and user account cannot read the local data file.

## Assumptions

- **Platforms.** Local mode is for desktop installs only: Linux, Windows and macOS. Web and mobile are out of scope for this feature.
- **Transaction types.** Transfers between accounts and other server-generated linked transactions are out of scope in local mode. Local transactions are only income or expense.
- **Tags.** [NEEDS CLARIFICATION: Should tags on transactions be supported in local mode and included in the move, or hidden in local mode? Default if unanswered: hidden and not moved.]
- **Encryption key.** The key protecting local data is created automatically and kept in the operating system's secure credential store, so the user never types a password. [NEEDS CLARIFICATION: Is it acceptable that local data becomes unrecoverable if that credential store is lost, for example after reinstalling the operating system, or should the user set a recovery password?]
- **Default categories.** The default local categories mirror those a new online user receives, so the move matches them by name rather than duplicating them.
- **Backend change.** The move depends on the server returning the newly created account, including its identifier, when an account is created.
- **Registration.** The existing registration flow already logs the user in on success. A newly registered account does not require two-factor verification before the move can run.
- **Single profile.** There is one local dataset per computer user. Multiple local profiles are out of scope.
- **No local export.** Local mode does not provide export, import or backup functions of its own beyond the automatic backup made after a move.
