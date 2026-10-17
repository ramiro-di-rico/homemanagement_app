# Research: Account Detail Balance Stays Current

## Root cause

- `account.detail.dart:58` and `account-detail-desktop.dart:55` set `account = widget.account` once.
- The router passes the repository's own instance (`extra: item`), so balance changes reach the screen only while the screen still holds that exact instance.
- `AccountRepository.load()` and `refresh()` clear `_internalAccounts` and refill it with new instances, for example after pull-to-refresh or CSV import. The screen keeps the old one.
- The listener `accountRepository.addListener(refreshState)` already rebuilds the screen. It only re-assigns `transactions`, so a stale `account` stays stale.
- `AccountDetailWidget` is stateless and reads `accountModel.balance` directly, so it needs no change.
- I could not reproduce the problem from code reading alone. The fix below removes the dependency on instance identity, so it works whichever case causes it.

## Decision 1: Resolve the account by id from the repository on each build

- **Decision**: Replace the `late AccountModel account` field with a getter that looks the account up by `widget.account.id` in the repository and falls back to `widget.account`.
- **Rationale**: One source of truth, no listener bookkeeping, and it covers reloads and any future code path that replaces instances. All the existing `account` usages keep working.
- **Alternatives considered**:
  - Re-assign `account` inside `refreshState`: this works but duplicates the lookup in several places and is easy to forget on the next listener.
  - Mutate the existing instance in `load()` instead of replacing it: this changes repository semantics for every consumer, which is a bigger blast radius.
  - Pass an id through the route instead of a model: this is a routing and API change and goes against the repo's convention of passing models through `extra`.

## Decision 2: Add `AccountRepository.getById(int id)`

- **Decision**: Add a method that looks in `_internalAccounts`, so hidden accounts are included, and returns `null` if the account is not found.
- **Rationale**: This avoids copying the whole list on every build, which `getAllAccounts()` does.
- **Alternatives considered**: Call `getAllAccounts().firstWhere(...)` in each screen. This works but copies the list each time and repeats the lookup.

## Decision 3: Missing account fallback

- **Decision**: If the account can't be found, for example it was deleted, fall back to `widget.account` so the screen doesn't crash.
- **Rationale**: This satisfies the spec's edge case about not crashing and not showing another account's data.
