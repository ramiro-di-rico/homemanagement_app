# Tasks: Account Detail Balance Stays Current

**Input**: Design documents from `/specs/001-fix-account-detail-balance/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: The plan calls for a repository test, so test tasks are included. The existing test fakes (`FakeAccountRepository`) use `noSuchMethod`, so adding a repository method does not break them.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story the task belongs to (US1, US2, US3)

## Phase 1: Foundational (blocks all stories)

- [X] T001 Add `AccountModel? getById(int id)` to `lib/data/repositories/account.repository.dart`. It searches `_internalAccounts` (so hidden accounts are included) and returns `null` if not found. Do not copy the list.

**Checkpoint**: the repository can return its current instance for an id.

---

## Phase 2: User Story 1 - Balance updates after changing a transaction (Priority: P1) 🎯 MVP

**Goal**: The mobile account detail screen shows the current balance after a transaction is added, edited or deleted.

**Independent Test**: Open an account, add an expense of 10, and see the balance drop by 10 without leaving the screen. Repeat for income, edit and delete.

- [X] T002 [P] [US1] Create `test/repository/account_repository_test.dart`. It uses a hand-written fake that `implements AccountService` (no mocking library). Cover: `getById` returns the same instance that `updateBalance`, `revertBalance` and `setBalance` change; `getById` returns `null` for an unknown id; `getById` finds a hidden account.
- [X] T003 [US1] In `lib/ui/features/accounts/views/account.detail.dart`, replace the `late AccountModel account;` field with a getter: `accountRepository.getById(widget.account.id) ?? widget.account`. Remove the `account = widget.account;` assignments in `initState` and `didUpdateWidget`. Keep the `didUpdateWidget` call to `load()` when the id changes. No other usage of `account` needs to change.

**Checkpoint**: the mobile balance updates after transaction changes.

---

## Phase 3: User Story 2 - Balance stays current after the account list is reloaded (Priority: P2)

**Goal**: After `AccountRepository.load()` or `refresh()` replaces the account instances (pull-to-refresh, CSV import), the detail screen still shows the right balance and keeps updating.

**Independent Test**: On the detail screen, import a CSV and confirm the balance matches. Then add a transaction and confirm it still updates.

- [ ] T004 [US2] Extend `test/repository/account_repository_test.dart`. With the fake service returning new `AccountModel` instances on the second `fetchAccounts()`, assert that after `load()` `getById(id)` returns the new instance (not the old one) with the reloaded balance, and that `updateBalance` afterwards is reflected through `getById`.
- [ ] T005 [US2] Confirm that `_importTransactions` in `account.detail.dart` still calls `accountRepository.refresh()` and that the screen picks up the new balance through the getter from T003. Make no code change unless that fails.

**Checkpoint**: the balance is correct after reloads and keeps updating afterwards.

---

## Phase 4: User Story 3 - Same behavior on desktop and mobile (Priority: P2)

**Goal**: The desktop detail view behaves like mobile.

**Independent Test**: Run the US1 and US2 scenarios on the desktop layout (`flutter run -d linux`).

- [ ] T006 [P] [US3] In `lib/ui/features/accounts/views/account-detail-desktop.dart`, replace `late AccountModel account;` with the same getter (`accountRepository.getById(widget.account.id) ?? widget.account`). Remove the `account = widget.account;` assignments in `initState` and `didUpdateWidget`. Keep the `load()` call when the id changes.

**Checkpoint**: both layouts use the repository as the source of truth.

---

## Phase 5: Polish & Verification

- [ ] T007 Run `flutter analyze` and fix any issue introduced by these changes.
- [ ] T008 Run `flutter test` and confirm the new and existing tests pass.
- [ ] T009 Run the manual scenarios in `specs/001-fix-account-detail-balance/quickstart.md` on mobile and on desktop, including the "refresh, then add a transaction" case.

---

## Dependencies & Execution Order

- T001 blocks T002 to T006.
- US1 (T002, T003) is the MVP and needs only T001.
- US2 (T004, T005) needs T001 and T003. T004 extends the test file from T002, so it runs after T002.
- US3 (T006) needs only T001 and can run in parallel with T003 (different file).
- Polish (T007 to T009) runs last.

## Parallel Opportunities

- After T001: T002, T003 and T006 touch different files and can run together.

## Implementation Strategy

- **MVP**: T001 to T003 fixes the mobile screen. Stop and check the quickstart there if you want an early result.
- **Then**: T004 and T005 for reloads, T006 for desktop, and finally T007 to T009.
