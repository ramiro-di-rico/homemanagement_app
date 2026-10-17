# Feature Specification: Account Detail Balance Stays Current

**Feature Branch**: `fix/account-detail-balance-refresh`

**Created**: 2026-10-16

**Status**: Draft

**Input**: User description: "Account detail screen balance does not refresh when a transaction is added, updated or removed. The detail screens (mobile and desktop) hold a stale copy of the account, so the Balance shown in the account info card is not updated after transaction changes, although the account list shows the updated balance. The detail screens should always reflect the current account balance, including after account list reloads/refreshes (pull-to-refresh, CSV import)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Balance updates after changing a transaction (Priority: P1)

While viewing an account's detail screen, a user adds, edits or deletes a transaction. The Balance shown at the top of the screen changes immediately to reflect the new total, without leaving the screen.

**Why this priority**: This is the reported defect. The balance is the main figure users check after recording a transaction, and a stale value makes the app look wrong and untrustworthy.

**Independent Test**: Open an account with a known balance, add an expense of 10, and confirm the displayed balance drops by 10 without navigating away. Repeat for edit and delete.

**Acceptance Scenarios**:

1. **Given** an account detail screen showing balance B, **When** the user adds an expense of amount X, **Then** the displayed balance becomes B − X.
2. **Given** an account detail screen showing balance B, **When** the user adds an income of amount X, **Then** the displayed balance becomes B + X.
3. **Given** an existing transaction, **When** the user changes its amount or type, **Then** the displayed balance reflects the net difference.
4. **Given** an existing transaction, **When** the user deletes it, **Then** the displayed balance reverses that transaction's effect.
5. **Given** a transfer to another account is added from the detail screen, **When** it completes, **Then** the displayed balance of the viewed account reflects the transfer.

---

### User Story 2 - Balance stays current after the account list is reloaded (Priority: P2)

A user refreshes data (pull-to-refresh) or imports transactions from a CSV file while on the account detail screen. After the reload, the balance shown matches the latest balance, and later transaction changes keep updating it.

**Why this priority**: The same stale-balance symptom reappears after a reload, so a fix covering only User Story 1 would work until the first refresh and then break again.

**Independent Test**: On the detail screen, import a CSV and confirm the balance matches the new total. Then add a transaction and confirm the balance still updates.

**Acceptance Scenarios**:

1. **Given** the detail screen is open, **When** the user imports transactions from a CSV, **Then** the displayed balance matches the account's updated balance.
2. **Given** the detail screen is open and account data has been reloaded, **When** the user adds, edits or deletes a transaction, **Then** the displayed balance still updates.

---

### User Story 3 - Same behavior on desktop and mobile (Priority: P2)

The desktop layout of the account detail screen shows the same up-to-date balance as the mobile layout in all the situations above.

**Why this priority**: Both layouts are shipped and the defect affects both.

**Independent Test**: Run User Stories 1 and 2 on a desktop-width layout and on a mobile layout, and confirm the same results.

**Acceptance Scenarios**:

1. **Given** the desktop account detail view, **When** a transaction is added, edited or deleted, **Then** its balance updates just as on mobile.

---

### Edge Cases

- The account is archived, unarchived or hidden while its detail screen is open: the balance shown stays correct.
- The account is renamed or edited from the detail screen: the balance is not reset to an older value.
- The account is deleted or no longer exists after a reload: the screen does not crash and does not show another account's balance.
- A transaction operation fails: the balance is unchanged and no partial change is displayed.
- Several changes happen in quick succession: the displayed balance ends at the correct final value.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The account detail screen MUST display the account's current balance at all times, not the balance it had when the screen opened.
- **FR-002**: The displayed balance MUST update, without leaving the screen, after a transaction is added, edited or deleted for that account.
- **FR-003**: The displayed balance MUST remain correct after account data is reloaded (pull-to-refresh, CSV import or any other refresh).
- **FR-004**: Transaction changes made after a reload MUST continue to update the displayed balance.
- **FR-005**: The displayed balance MUST match the balance shown for the same account in the account list.
- **FR-006**: The behavior MUST be the same in the mobile and desktop layouts of the account detail screen.
- **FR-007**: Other account information on the detail screen (name, archive state, currency) MUST also reflect the current account state.

### Key Entities

- **Account**: A user's money container with a name, type, currency, archive/hidden state and a running balance. The balance changes whenever one of its transactions is added, edited or removed, or when it is the target of a transfer.
- **Transaction**: An income or expense (or transfer) of a given amount on an account. Each one affects the account balance.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After adding, editing or deleting a transaction, the balance on the detail screen shows the correct new value in 100% of cases, with no manual refresh or navigation needed.
- **SC-002**: The balance on the detail screen and in the account list are identical for the same account in 100% of checked scenarios.
- **SC-003**: The balance is correct on the first transaction change after a refresh or CSV import, with no stale value seen.
- **SC-004**: The mobile and desktop layouts pass the same acceptance scenarios.

## Assumptions

- The up-to-date balance is already maintained in one shared place that the account list reads from. This fix is about the detail screens reading from it, not about recalculating balances.
- The balance value returned by the backend after a transaction change is correct.
- Reports of new stale-balance problems on screens other than account detail are out of scope.
- No visual redesign is intended. The balance card looks the same and only its value becomes current.
