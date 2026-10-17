# Data Model: Account Detail Balance Stays Current

No new entities and no schema or API changes.

## Account (`AccountModel`, existing)

- The repository holds one list of accounts, `_internalAccounts`. `accounts` is the filtered view the list screen reads.
- `balance` is changed in place by transaction operations and replaced wholesale when accounts are reloaded.

## Added behavior

- `AccountRepository.getById(int id) -> AccountModel?`: returns the repository's current instance for `id`, or `null`.

## Rule

- Screens must not keep a long-lived reference to an `AccountModel` between rebuilds. They resolve it by id through the repository.
