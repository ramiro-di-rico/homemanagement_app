# Implementation Plan: Account Detail Balance Stays Current

**Branch**: `fix/account-detail-balance-refresh` | **Date**: 2026-10-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-fix-account-detail-balance/spec.md`

## Summary

The mobile and desktop account detail screens copy the `AccountModel` once (`account = widget.account` in `initState`) and never read it from `AccountRepository` again. Balance changes are mutated in place on the repository's own instances (`setBalance`, `updateBalance`, `revertBalance`), and `AccountRepository.load()` replaces every instance with new ones. As soon as the screen's copy is no longer the repository's instance, for example after pull-to-refresh or a CSV import, it stops receiving updates. The account list does not have this problem because it reads `accountsRepo.accounts` on every rebuild.

Approach: make `AccountRepository` the single source of truth. Both detail screens resolve the account by id from the repository on every build, falling back to the route's `widget.account` if it is missing. The existing `accountRepository.addListener(refreshState)` already triggers the rebuild.

## Technical Context

**Language/Version**: Dart / Flutter (see `pubspec.yaml`)

**Primary Dependencies**: GetIt (service locator), GoRouter, `ChangeNotifier` repositories. No new dependencies.

**Storage**: N/A (in-memory repository state, backend API)

**Testing**: `flutter test`, with no mocking library available. Follow the `flutter-write-widget-test` skill and use hand-written fakes.

**Target Platform**: Android/iOS, Linux desktop, web (mobile and desktop widget variants)

**Project Type**: Flutter mobile and desktop app

**Performance Goals**: N/A. A by-id lookup over a short account list on each build is negligible.

**Constraints**: No API changes, no visual changes, no change to how balances are computed.

**Scale/Scope**: 2 screens, 1 repository method, plus tests

## Constitution Check

`.specify/memory/constitution.md` is still the unfilled template, so there are no ratified principles to gate on. Result: PASS (no applicable gates). The plan follows the `CLAUDE.md` rules: views read repositories through GetIt, there are no new layers, and no localization is involved.

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-account-detail-balance/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md             # created by /speckit-tasks
```

`contracts/` is skipped: there are no new external interfaces.

### Source Code (repository root)

```text
lib/
├── data/repositories/account.repository.dart              # add getById(int id)
└── ui/features/accounts/views/
    ├── account.detail.dart                                # mobile: account becomes a getter
    └── account-detail-desktop.dart                        # desktop: same change

test/
└── (new) repository/widget test covering getById after load() and balance updates
```

**Structure Decision**: The change is limited to the existing files above and follows the repo's current repository-to-view layering.

## Complexity Tracking

No violations to justify.
