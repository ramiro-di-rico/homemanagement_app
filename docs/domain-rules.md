# Domain rules

Business rules that aren't obvious from reading the code in isolation — the "why", not the "what". This complements CLAUDE.md (architecture) and is meant to be added to incrementally: whenever a bug or feature turns on a non-obvious domain rule, write it here instead of only in a commit message or PR description, so both humans and AI assistants working on this repo can find it later.

Keep entries short: one rule, one reason, one pointer to where it's enforced in code.

## Accounts

- Accounts have a **main/child** relationship (`MainAccountModel.childAccountCount`) — verify the intended rule before changing account creation/deletion flows, and document it here once confirmed.
- Accounts can be **hidden** (`MainAccountModel.isHidden`) — confirm and document what hiding affects (visibility only vs. exclusion from totals/budgets) before relying on this field elsewhere.

## Shared household access

- Access to a household's accounts is granted via **invites** (`lib/domain/models/invite.dart`, `lib/data/repositories/invite.repository.dart`), including QR-scanned deep links (`DeepLinkingService`). Document invite expiry/role rules here once you've confirmed them against the backend.

## Budgets / recurring transactions

- `BudgetRepository` and `RecurringTransactionRepository` both extend `ChangeNotifier` — unusual for this codebase, since most of the app manages state via `setState` in the view rather than a notifier in the repository layer. If you're touching either, check for existing `addListener` call sites before assuming the repository is stateless.
- (Add the actual budget calculation / recurrence scheduling rules here as they come up — not yet documented.)

---
*This file is intentionally sparse to start. Add a section per domain area the first time a rule in it causes confusion or a bug.*
