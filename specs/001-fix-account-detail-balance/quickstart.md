# Quickstart: Validate Account Detail Balance

## Prerequisites

- `flutter pub get`
- A backend account with at least one account and some transactions

## Automated

- `flutter analyze`
- `flutter test`, including the new test covering `getById` after `load()` replaces instances and the balance updates from `updateBalance`, `revertBalance` and `setBalance`.

## Manual (run on mobile and on desktop, `flutter run -d linux`)

1. Open an account from the list and note the balance.
2. Add an expense of 10. The balance drops by 10 with no navigation.
3. Add an income. The balance rises accordingly.
4. Edit a transaction's amount. The balance reflects the difference.
5. Delete a transaction. The balance reverses its effect.
6. Pull to refresh, or import a CSV from the menu. The balance matches the account list.
7. Repeat steps 2 to 5 after the refresh or import. The balance still updates (this is the stale-instance case).
8. Go back to the list. The balance there equals the one on the detail screen.
